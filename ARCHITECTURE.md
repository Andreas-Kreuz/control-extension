# Architektur der Control Extension

Die Control Extension besteht aus vier Bausteinen, die aufeinander aufbauen, aber jeweils eigenständig nutzbar sind. Dieses Dokument beschreibt die übergreifenden Designprinzipien. Detailarchitekturen der einzelnen Teile sind in den jeweiligen Teilarchitekturdokumenten beschrieben.

## Bausteine

```text
EEP-Programm (Lua 5.3)
        |
        v
[1] Lua Hub          lua/LUA/ce/hub/
        |
        v
[2] Data Bridge      lua/LUA/ce/databridge/
        |
        v (Dateien: events-from-ce, log-from-ce)
[3] Control Extension Server    apps/web-server/
        |
        v (Socket.IO / REST-API)
[4] Control Extension Web App   apps/web-app/
```

Gemeinsame TypeScript-Typen und Events zwischen Server und Web App:

```text
apps/web-shared/     <-- gemeinsamer Vertrag
```

---

## Prinzip 1: Unabhängigkeit

Jeder Baustein ist eigenständig nutzbar. Höhere Bausteine sind optional.

### Lua Hub (Baustein 1)

- Unabhängig von Data Bridge, Server und Web App.
- Wer nur Anlagenlogik in Lua schreiben möchte, braucht ausschließlich den Lua Hub.

### Data Bridge (Baustein 2)

- Setzt den Lua Hub voraus.
- Arbeitet unabhängig vom Server: schreibt Logdateien und Event-Dateien (`events-from-ce`) auch dann,
  wenn kein Server läuft.
- Kann zusätzlich serverunabhängige Ausgabedateien für andere Konsumenten schreiben und eingehende
  Befehlsdateien lesen.

### Control Extension Server (Baustein 3)

- Setzt die Data Bridge voraus.
- Arbeitet unabhängig von der Web App: stellt REST-API und Socket.IO-Events bereit, auch wenn keine
  Web App verbunden ist.
- Ziel: Nutzende, die nur die API oder Socket.IO-Events konsumieren möchten, kommen ohne Web App aus.

### Control Extension Web App (Baustein 4)

- Setzt den Server voraus.
- Reiner Konsument von Server-API und Socket.IO-Events.

---

## Prinzip 2: Datenfluss und Datenverarbeitung

Daten durchlaufen die Bausteine in einer klar definierten Richtung. Jede Schicht hat eine
festgelegte Verantwortung für Transformation und Filterung.

### Überblick

```text
EEP-Programm
    |  reine EEP-Daten (Züge, Signale, Weichen, …)
    v
Lua Hub DtoFactories          --> reine Lua DTOs (unverändertes EEP-Datenmaterial)
    |
    +---> CeModule (optional) --> modulspezifische Lua DTOs (Erweiterung / Transformation)
    |
    v
Data Bridge                   --> transparente Übertragung, kein Datenwissen
    |
    v
Server (LuaDto-Empfang)
    |  Selectors: LuaDto  -->  *Dto (web-shared)
    v
web-shared *Dto               --> stabiler Vertrag zwischen Server und Web App
    |
    v
Web App                       --> ggf. view-spezifische Reduktion (View Models)
```

### Datenverarbeitung im Detail

**1. Lua Hub — Erfassung reiner EEP-Daten**

Die DtoFactories im Lua Hub erzeugen ausschließlich DTOs mit unverändertem EEP-Datenmaterial.
Sie transformieren, filtern oder kombinieren keine Daten. Konsumenten (Data Bridge, Server)
erhalten immer das rohe EEP-Bild.

**2. CeModule — Modulspezifische Erweiterung**

Wer Daten transformieren, kombinieren oder filtern möchte, implementiert ein CeModule.
CeModule dürfen die DtoFactories des Lua Hub nicht verändern. Sie erzeugen eigene,
modulspezifische DTOs und stellen diese separat bereit.
Als Kommunikationskanal stehen der Lua-Datenbus und der Lua-Store zur Verfügung,
in dem alle aktuellen Zustände gehalten werden.

**3. Data Bridge — Transparente Übertragung**

Die Data Bridge überträgt Daten, kennt aber deren Struktur nicht und verändert sie nicht.
Sie ist ein reiner Transportkanal.

**4. Server — Tailoring für Konsumenten**

Der Server empfängt Lua DTOs und transformiert sie über Selectors in `*Dto`-Objekte
(definiert in `apps/web-shared`). Dabei gilt:

- Tailoring (Reduktion, Filterung für Clients) findet ausschließlich auf Serverseite statt.
- Die reine Lua-API (`LuaDto`) wird dadurch nicht verändert.
- Ziel des Tailoring: Datenverkehr zwischen Server und Clients minimieren,
  Update-Ereignisse für die Web App reduzieren.

**5. web-shared — Gemeinsamer Vertrag**

`apps/web-shared` enthält die gemeinsamen TypeScript-Typen und Events, die Server und Web App
teilen. Dadurch muss dasselbe Datenmodell nicht doppelt implementiert werden.
Die `*Dto`-Typen in `web-shared` sind der stabile Client-Vertrag — Lua-interne Änderungen
werden durch die Selectors abgefangen, sodass der Client-Vertrag stabil bleibt.

**6. Web App — View-spezifische Datenhaltung**

Die Web App empfängt `*Dto`-Objekte und kann diese für Views lokal halten (View Models).
Ziel: minimale Re-Renders und minimaler Speicherbedarf.

---

## Prinzip 3: Befehlsfluss

Neben dem Datenfluss von Lua zur Web App gibt es einen Rückkanal für Befehle.
Befehle fließen von Konsumenten (Web App, Nutzer, externe Tools) über die Data Bridge
zurück ins EEP-Programm.

### Befehlsfluss im Überblick

```text
Web App
    | Socket.IO CommandEvent
    v
Server  registerCommandMod.ts → eepService.queueCommand()
    |
    +---- schreibt ---> commands-to-ce <--- schreibt --- Nutzer / externe Tools
                              |
                              v
              Data Bridge  IncomingCommandFileReader.lua / IncomingCommandExecutor.lua
                              | prüft gegen registrierte (erlaubte) Befehle
                              | führt aus im EEPMain-Zyklus
                              v
                        EEP-Programm (Lua)
```

### Regeln

**Offener Eingangskanal:** `commands-to-ce` ist ein allgemeiner Eingangskanal.
Der Server ist nur eine mögliche Quelle — Nutzer und externe Tools können dieselbe Datei
direkt beschreiben.

**Erlaubnisliste:** Damit nicht beliebige Befehle ausgeführt werden, müssen erlaubte Befehle
vorab in der Lua-Seite registriert werden. Unbekannte oder nicht registrierte Befehle werden
von der Data Bridge ignoriert.

---

## Teilarchitekturen

| Bereich | Datei |
| --- | --- |
| Lua Hub, CeModule, Data Bridge | [lua/LUA/ce/ARCHITECTURE_LUA.md](lua/LUA/ce/ARCHITECTURE_LUA.md) |
| Control Extension Server | [apps/web-server/ARCHITECTURE_SERVER.md](apps/web-server/ARCHITECTURE_SERVER.md) |
| Gemeinsames Datenmodell (web-shared) | [apps/web-shared/ARCHITECTURE_SHARED.md](apps/web-shared/ARCHITECTURE_SHARED.md) |
| Control Extension Web App | [apps/web-app/ARCHITECTURE_APP.md](apps/web-app/ARCHITECTURE_APP.md) |
