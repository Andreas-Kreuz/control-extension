---
layout: page_with_toc
title: Hub — Entwickler
subtitle: Interner Laufzeitfluss und StatePublisher-Muster des Lua-Hubs
permalink: lua/ce/hub/dev/
feature-img: "/docs/assets/headers/SourceCode.png"
img: "/docs/assets/headers/SourceCode.png"
---

# Hub — Entwickler

## Interner Laufzeitfluss

Der Hub orchestriert alle registrierten Module und StatePublisher in einem festen Ablauf:

1. `ce.ControlExtension` ist der stabile Einstiegspunkt für EEP-Skripte.
2. `ModuleRegistry` registriert die verwendeten Lua-Module.
3. `MainLoopRunner` führt Initialisierung und Zyklus aus.
4. Module registrieren ihre `StatePublisher` über die dafür vorgesehenen BridgeConnectoren.
5. `StatePublisher` lesen Zustand aus Hub- oder Modulbereichen.
6. Änderungen werden über `DataChangeBus` veröffentlicht.
7. `InternalDataStore` kann daraus einen materialisierten Snapshot halten.
8. `ServerEventBuffer` nimmt veröffentlichte Events für die Bridge entgegen.
9. Die Bridge schreibt Austauschdateien und liest Remote-Kommandos.

Design-Entscheidung: Die öffentliche API beschränkt sich auf `ce.ControlExtension`. Interne Pfade unter `ce.hub.*` sind Infrastruktur und gelten nicht als stabile öffentliche API.

## Gemeinsamkeiten der `*StatePublisher`-Klassen

Alle Klassen unter `lua/LUA/ce/**/*StatePublisher.lua` folgen demselben Grundmuster für den Export von Lua- und EEP-Daten in Richtung Web-/Server-Schicht:

### 1. Gemeinsame Schnittstelle

- Jeder StatePublisher exportiert genau ein Lua-Modul mit `name`, `initialize()` und `syncState()`.
- Diese Form wird beim Registrieren im `ce.hub.StatePublisherRegistry` validiert; dort werden genau diese Felder geprüft.

### 2. Registrierung über BridgeConnector-Module

- StatePublisher werden nicht direkt von Fachlogik genutzt, sondern über ein passendes `*BridgeConnector`-Modul beim `StatePublisherRegistry` angemeldet.
- Dadurch bleiben Domänenlogik und Web-Export lose gekoppelt.

### 3. Singleton-artiger Modulzustand

- Jeder StatePublisher ist eine modulweite Tabelle mit lokal gehaltenem Zustand.
- Typisch sind lokale Flags wie `enabled` und `initialized` sowie Caches oder Snapshots für bereits bekannte Objekte.

### 4. Zweiphasiger Lebenszyklus

- `initialize()` ist für einmalige Vorbereitung gedacht, zum Beispiel Initialsuche, Indexaufbau oder das Merken bereits bekannter Objekte.
- `initialize()` wird im regulären Ablauf vom `ce.hub.MainLoopRunner` einmal pro registriertem StatePublisher aufgerufen.
- `syncState()` wird danach ebenfalls vom `MainLoopRunner` in jedem Zyklus ausgeführt.
- Viele StatePublisher sind trotzdem idempotent aufgebaut und behalten ein lokales `initialized`-Flag, damit zusätzliche oder direkte Aufrufe keinen ungewollten Effekt haben.

### 5. Adapter zwischen EEP/Fachmodulen und API-Daten

- Die StatePublisher lesen ihren Zustand entweder direkt über EEP-Funktionen oder über fachliche Registries oder Modelle des Projekts.
- Dabei formen sie interne Zustände in flache, webtaugliche Tabellen mit stabilen Kennungen wie `id` oder `name` um.
- Änderungen des Zustandes werden über `DataChangeBus.fire*()` bekanntgemacht. Dabei wird immer ein eindeutiger Identifier übergeben.

### 6. Ereignisgetriebener Export

- Der eigentliche Datentransport läuft primär über Events.
- Die meisten StatePublisher senden ihre Ergebnisse über `ce.hub.publish.DataChangeBus`, meist als `fireListChange(...)`, teilweise auch granularer wie `fireDataAdded(...)` oder `fireDataChanged(...)`.
- Auch dort, wo `syncState()` nominal Daten zurückgeben kann, ist der Event-Strom in der Praxis meist der relevante Ausgabekanal.

### 7. Rückgabewerte sind Nebenkanal oder Kompatibilitätsschicht

- Viele StatePublisher geben bewusst `{}` oder nur kommentierte Platzhalter zurück.
- Das passt zur Verwendung im `MainLoopRunner`: Die Rückgabewerte von `syncState()` werden dort nicht weiterverarbeitet, während die aktuellen StatePublisher ihre Nutzdaten überwiegend schon während `syncState()` per Event veröffentlichen.
- Wenn ein StatePublisher doch Tabellen zurückgibt, müssen sie nur serialisierbare Werte enthalten; Funktionen oder nicht-string-/nicht-number-Schlüssel sind unzulässig.

### 8. API-orientierte Datenform

- Exportierte Listen enthalten nach Möglichkeit ein eindeutiges Feld (`id` oder `name`), weil Web-Clients und Änderungsereignisse damit arbeiten.
- Mehrere StatePublisher erzeugen nicht nur reine Zustandslisten, sondern auch Settings- oder Metadatenlisten, damit die Web-Oberfläche Fachmodule einheitlich darstellen und fernsteuern kann.

Zusammengefasst sind `*StatePublisher` keine isolierten Datenklassen, sondern zustandsbehaftete Adapter mit einheitlichem Lebenszyklus: über BridgeConnectoren registrieren, vom `StatePublisherRegistry` verwalten, vom `MainLoopRunner` initialisieren und dann zyklisch Zustand lesen und Änderungen über die Event- und Server-Infrastruktur veröffentlichen.

---

Informationen für Anwender: [README.md](README.md)
