# Lua-Architektur der Control Extension

Dieses Dokument beschreibt die Architektur des Lua-Teils der Control Extension.
Für die übergreifende Architektur aller Bausteine siehe [ARCHITECTURE.md](../../../project-docs/ARCHITECTURE.md).

## Übersicht

Der Lua-Teil besteht aus zwei Schichten:

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
und erfasst dabei reine EEP-Daten. Außerdem orchestriert er die Data Bridge.

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

---

## EEP-Threading und Speicherschutz

### Threading-Modell von EEP

EEP ruft `EEPMain()` im Hauptthread auf. Das Speichern der Anlage (`.anl3`) erfolgt auf
einem **Hintergrundthread**, der intern einen Schreib-Mutex hält. EEP ist also nicht
vollständig single-threaded.

EEP-API-Aufrufe aus dem Hauptthread (z.B. `EEPStructureGetModelType`, `EEPGetSignal`,
`EEPLoadData`) belegen denselben Mutex. Laufen Hauptthread und Speicher-Thread
gleichzeitig, entsteht ein Deadlock — EEP friert dauerhaft ein.

### Der Speicherschutz im Hub

`CeHubModule` sperrt alle EEP-API-Aufrufe für die Dauer eines Speichervorgangs.
Dazu werden zwei EEP-Callbacks genutzt:

- `EEPOnBeforeSaveAnl()` (ab EEP 17) — feuert bevor der Hintergrundthread startet
- `EEPOnSaveAnl(path)` — feuert nachdem der Schreibvorgang abgeschlossen ist

```text
EEPOnBeforeSaveAnl()  →  savingInProgress = true
                                |
                    CeHubModule.run() kehrt sofort zurück
                    (keine EEP-API-Aufrufe im Hauptzyklus)
                                |
EEPOnSaveAnl(path)    →  savingInProgress = false
                          Anl3-Reload nach 3 Zyklen einplanen
```

Ein Sicherheitstimeout von 300 Zyklen hebt die Sperre automatisch auf, falls
`EEPOnSaveAnl` unerwartet ausbleibt.

Implementiert in `ce/hub/CeHubModule.lua`.

### Regeln für EEP-API-Aufrufe

**Regel 1: EEP-API-Aufrufe nur innerhalb von `CeHubModule.run()`**

Alle EEP-API-Aufrufe müssen innerhalb des normalen Hub-Zyklus erfolgen — in Updatern,
Discovery-Funktionen oder Tasks, die von `CeHubModule.run()` ausgelöst werden. Nur dort
greift der Speicherschutz.

EEP-Callbacks (`EEPOnSaveAnl`, `EEPOnBeforeSaveAnl`, `EEPOnSignal_x`, …) dürfen keine
EEP-API-Aufrufe machen, die den Schreib-Mutex belegen könnten.

**Regel 2: Registry-Daten wiederverwenden, nicht neu abfragen**

Beim Anl3-Reload nach jedem Speichern enthält die Registry bereits alle EEP-seitig
abgefragten Daten aus der initialen Discovery. Statische Eigenschaften wie Position,
Rotation und Modelltyp von Strukturen ändern sich zur Laufzeit nicht.

Bestehende Registry-Einträge beim Reload niemals erneut über EEP-API-Aufrufe befüllen.
EEP-API-Aufrufe beim Reload nur für Entitäten machen, die noch nicht in der Registry
vorhanden sind.

**Regel 3: EEP-API-Aufrufe pro Zyklus minimal halten**

Discovery-Funktionen durchlaufen große Indexbereiche (bis 50.000 Strukturen, je 1.000
Signale und Weichen). Das ist für die initiale Discovery unvermeidlich. Bei Reloads und
laufenden Updates gilt:

- Vorhandene Registry-Daten nicht redundant neu abfragen
- Neue Entitäten sofort nach Erkennung registrieren, um Wiederholungen zu vermeiden
- Je mehr EEP-API-Aufrufe pro Zyklus, desto länger das Zeitfenster für einen Deadlock

### Anl3-Reload nach dem Speichern

Nach `EEPOnSaveAnl` plant der Hub einen Anl3-Reload mit 3 Zyklen Verzögerung, damit EEP
die Datei vollständig freigibt, bevor sie gelesen wird. Der Reload befüllt die Registries
mit Metadaten aus der `anl3`-Datei (z.B. `gsbname` für Strukturen), die über die EEP-API
allein nicht zugänglich sind. Dabei gilt Regel 2: bestehende Registry-Einträge werden
wiederverwendet, keine redundanten API-Aufrufe.

Implementiert in `ce/hub/data/structures/StructureDiscovery.lua` (`initFromAnl3`).
