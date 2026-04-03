# Lua-Architektur der Control Extension

Dieses Dokument beschreibt die Architektur des Lua-Teils der Control Extension.
Für die übergreifende Architektur aller Bausteine siehe [ARCHITECTURE.md](../../../project-docs/ARCHITECTURE.md).

## Übersicht

Der Lua-Teil besteht aus zwei unabhängig nutzbaren Schichten:

```text
EEP-Programm (Lua 5.3)
        |
        v
[1] Lua Hub      ce/hub/
        |
        v
[2] Data Bridge  ce/databridge/
```

---

## Lua Hub (`ce/hub/`)

Der Lua Hub ist der Laufzeitkern. Er registriert CeModule, ruft diese in jedem EEP-Zyklus auf
und erfasst dabei reine EEP-Daten.

### Verantwortung

- EEP-Daten (Züge, Signale, Weichen, Strukturen, Gleise, …) über die EEP-API abfragen.
- Diese Daten über DtoFactories in strukturierte Lua DTOs umwandeln.
- DTOs nach `ceType` einsortieren und für die Data Bridge bereitstellen.

### DtoFactories — Regel: nur reine EEP-Daten

Die DtoFactories im Lua Hub erzeugen ausschließlich DTOs mit unverändertem EEP-Datenmaterial.

**Verboten:** CeModule dürfen die DtoFactories des Lua Hub nicht verändern oder erweitern.
Wer Daten kombinieren, filtern oder anreichern möchte, implementiert ein eigenes CeModule
mit eigenen DTOs (siehe unten).

**Grund:** Konsumenten der Lua-Hub-DTOs (Data Bridge, Server) sollen immer das rohe EEP-Bild
erhalten — ohne Nebeneffekte durch Module.

### Lua Store

Der Lua Store hält alle aktuellen Zustände der CeTypes im Speicher.
Module können über den `DataChangeBus` Daten lesen oder schreiben.

---

## CeModule (`ce/mods/`)

Ein CeModule ist ein optionaler Lua-Baustein, der in den Hub eingehängt wird.

### Aufgaben eines CeModuls

- Kann reine EEP-Lua-DTOs aus dem Store lesen.
- Darf eigene, modulspezifische DTOs erzeugen (Erweiterung, Transformation, Kombination).
- Diese modulspezifischen DTOs werden separat in eigenen CeTypes abgelegt —
  **nicht** in den DtoFactories des Lua Hub.

### Kommunikationskanal

CeModule kommunizieren über den `DataChangeBus` oder lesen direkt aus dem Lua Store:

```text
Lua Store (alle aktuellen Zustände)
    ^         |
    |  lesen  | schreiben
    |         v
  CeModule <--> DataChangeBus
```

### Beispiel: Road-Modul (`ce/mods/road/`)

Das Road-Modul liest Signalzustände aus dem Lua Store und erzeugt daraus Ampel-DTOs
(`IntersectionLuaDto`), die separat vom Lua Hub bereitgestellt werden.

---

## Data Bridge (`ce/databridge/`)

Die Data Bridge ist der Transportkanal zwischen Lua und dem Server.

### Aufgaben der Data Bridge

- Nimmt DTOs aus den CeTypes entgegen.
- Schreibt diese als newline-delimited JSON (Kodierung: latin1) in die Datei `events-from-ce`.
- Schreibt Logmeldungen in `log-from-ce`.

### Unabhängigkeit vom Server

Die Data Bridge arbeitet auch ohne laufenden Server:

- `events-from-ce` wird immer geschrieben — unabhängig davon, ob ein Server liest.
- Zusätzliche serverunabhängige Ausgabedateien für andere Konsumenten sind möglich.
- Eingehende Befehlsdateien werden gelesen, auch wenn kein Server sendet.

### Transparenz

Die Data Bridge kennt die Struktur der übertragenen Daten nicht und verändert sie nicht.
Sie ist ein reiner Transportkanal.

### Befehlsempfang (`commands-to-ce`)

Neben dem Datenausgang verwaltet die Data Bridge auch einen Eingangskanal für Befehle:

- `IncomingCommandFileReader.lua` liest die Datei `commands-to-ce` im EEPMain-Zyklus.
- `IncomingCommandExecutor.lua` führt die gelesenen Befehle aus.
- **Erlaubnisliste:** Nur vorab registrierte Befehle werden ausgeführt. Unbekannte Befehle
  werden ignoriert, damit keine beliebigen Eingaben das EEP-Programm beeinflussen können.
- `commands-to-ce` ist ein allgemeiner Eingangskanal — jede Quelle (Server, Nutzer,
  externe Tools) kann Befehle hineinschreiben.

---

## DTO-Typen und Querverweise

Die öffentlichen DTO-Felddefinitionen liegen in:

- `ce/hub/data/**/*.d.lua` — Hub-DTOs (reine EEP-Daten)
- `ce/mods/**/data/*DtoTypes.d.lua` — Modul-DTOs

Jede DtoFactory enthält einen Querverweis auf die zugehörige TypeScript-Definition im Server:

```lua
-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/trains/TrainStaticLuaDto.ts
```

Umgekehrt verweist jede TypeScript-LuaDto-Datei auf ihre Lua-DtoFactory.
