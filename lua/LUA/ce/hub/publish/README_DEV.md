---
layout: page_with_toc
title: DataChangeBus — Entwickler
subtitle: Interne Architektur und Design-Entscheidungen des Publish-Pakets
permalink: lua/ce/hub/publish/dev/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# DataChangeBus — Entwickler

## Zweck

Dieses Paket kapselt die Erzeugung und Verteilung von externen Datenänderungen innerhalb der Lua-Bibliothek.

Es hat vier Kernaufgaben:

- Vereinheitlichung der Änderungsereignisse für externe Daten
- Verteilung dieser Ereignisse an registrierte Listener
- Bereitstellung einer kleinen API für Produzenten von Datenänderungen
- Initiales Auslösen eines vollständigen Resets für nachgelagerte Empfänger

## Alle Lua-Dateien in `ce/hub/publish`

- [DataChangeBus.lua](./DataChangeBus.lua)

## Architekturübersicht

Das Paket ist bewusst klein gehalten:

1. `DataChangeBus` definiert die Eventtypen
2. `DataChangeBus` nimmt Datenänderungen aus anderen Paketen entgegen
3. `DataChangeBus` verteilt diese Änderungen an alle registrierten Listener
4. `ServerEventBuffer` aus `ce.databridge` zeichnet die verteilten Ereignisse für den späteren Export auf

Wichtig: `ce.hub.publish` enthält keine Fachdaten und keine Dateiausgabe. Es ist nur die interne Drehscheibe für Änderungsereignisse.

## DataChangeBus

Zentrale Ereignisverteiler-Schicht des Pakets.

Verantwortlichkeiten:

- Definition der unterstützten Eventtypen
- Verwaltung registrierter Listener
- Erzeugen einheitlicher Eventobjekte mit `eventCounter`, `type` und `payload`
- Verteilung der erzeugten Eventobjekte an alle Listener
- Bereitstellung spezialisierter Hilfsfunktionen für `DataAdded`, `DataChanged`, `DataRemoved` und `ListChanged`
- Auslösen eines initialen `CompleteReset` beim Laden des Moduls

Wichtig:

- `DataChangeBus` soll die Inhalte von `ceType`, `keyId`, `element` oder `list` nicht fachlich kennen oder interpretieren
- diese Felder werden nur validiert und an Listener weitergereicht
- der einzige Eventtyp, dessen Bedeutung und Payload hier bewusst bekannt sind, ist `CompleteReset`

## Laufzeitfluss

Der reguläre Ablauf für eine Datenänderung ist:

1. Ein Paket wie `ce.hub.data`, `ce.mods.road` oder `ce.mods.transit` ruft eine der `fire*`-Methoden von `DataChangeBus` auf.
2. `DataChangeBus` validiert die Mindeststruktur der Eingabedaten.
3. `DataChangeBus` erhöht den internen `eventCounter`.
4. `DataChangeBus` erzeugt ein Eventobjekt mit Typ und Payload.
5. Alle registrierten Listener erhalten dieses Event über `fireEvent(...)`.
6. `ServerEventBuffer` aus `ce.databridge` puffert das Event für den späteren Export.

Beim Laden des Moduls wird einmal ein `CompleteReset` erzeugt, damit nachgelagerte Empfänger ihren Zustand vollständig neu aufbauen können.

## Design-Entscheidungen

### Bus bleibt generisch

`DataChangeBus` darf keine Fachobjekte interpretieren. Er transportiert, validiert und verteilt nur. Domänenwissen bleibt bei den Produzenten.

### Keine Dateiausgabe

Aufzeichnung und Ausgabe liegen außerhalb des Pakets. `ServerEventBuffer` aus `ce.databridge` übernimmt das.

### Listener werden synchron aufgerufen

Ein fehlerhafter oder langsamer Listener kann den gesamten Änderungsfluss beeinflussen — das ist bewusst einfach gehalten.

### Reset-Verhalten beim Start

`CompleteReset` muss vor dem regulären Eventstrom möglich sein, damit externe Empfänger ihren Zustand sauber initialisieren können. Änderungen hier wirken sich auf Neustarts und Reconnects aus.

## Wichtige Invarianten

- Listener müssen eine Methode `fireEvent(event)` besitzen.
- `eventCounter` muss pro erzeugtem Event genau einmal erhöht werden.
- `ceType`, `keyId`, `element` und `list` bleiben fachlich opaque.
- `ce.hub.publish` verteilt Ereignisse nur weiter; Aufzeichnung und Ausgabe liegen außerhalb.

## Relevante Nachbarn

- `ce.databridge` — `ServerEventBuffer` zeichnet die verteilten Ereignisse auf
- `ce.hub.data`, `ce.mods.road`, `ce.mods.transit` — erzeugen Datenänderungen
- `ce.hub.util.TableUtils` — unterstützt die Debug-Ausgabe

---

Informationen für Anwender: [README.md](README.md)
