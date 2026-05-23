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

### EEP ist nicht vollständig single-threaded

EEP ruft `EEPMain()` im Hauptthread auf. Das Speichern der Anlage (`.anl3`) erfolgt jedoch
auf einem **Hintergrundthread**, der intern einen Schreib-Mutex hält.

EEP-API-Aufrufe aus `EEPMain` (z.B. `EEPStructureGetModelType`, `EEPGetSignal`,
`EEPLoadData`) versuchen, denselben Mutex zu belegen — klassischer Deadlock.

**Folge:** EEP friert dauerhaft ein ("Programm reagiert nicht"), sobald während eines
laufenden Speichervorgangs ein EEP-API-Aufruf aus `EEPMain` erfolgt.

### Warum der erste Speichervorgang funktioniert, der zweite aber nicht

Beim ersten Speichern sind die Registries leer, sodass kaum EEP-API-Aufrufe im kritischen
Fenster stattfinden. Nach dem ersten Speichern wird die `anl3`-Datei erneut eingelesen
(`initFromAnl3`). Früher rief dieser Reload für jede Struktur `applyStaticUpdate` auf —
3 EEP-API-Aufrufe pro Struktur. Bei großen Szenarien bedeutet das zehntausende Aufrufe
in einem einzigen `EEPMain`-Zyklus, genug um den Deadlock beim zweiten Speichern
zuverlässig zu provozieren.

### Lösung 1: Speicherschutz mit `EEPOnBeforeSaveAnl`

Ab EEP 17 steht `EEPOnBeforeSaveAnl()` zur Verfügung. EEP ruft diese Funktion auf,
**bevor** der Hintergrundthread mit dem Schreiben beginnt. Der Hub sperrt damit alle
EEP-API-Aufrufe für die gesamte Dauer des Speichervorgangs:

```text
EEPOnBeforeSaveAnl()  →  savingInProgress = true
                                |
                    CeHubModule.run() kehrt sofort zurück
                    (keine EEP-API-Aufrufe)
                                |
EEPOnSaveAnl(path)    →  savingInProgress = false
                          Anl3-Reload nach 3 Zyklen einplanen
```

Ein Sicherheitstimeout von 300 Zyklen verhindert dauerhaftes Einfrieren, falls
`EEPOnSaveAnl` unerwartet ausbleibt.

Implementiert in `ce/hub/CeHubModule.lua` (`EEPOnBeforeSaveAnl`, `EEPOnSaveAnl`,
`CeHubModule.run`).

### Lösung 2: EEP-API-Aufrufsturm in `initFromAnl3` vermeiden

`StructureDiscovery.initFromAnl3` rief früher für jede Struktur aus der `anl3`-Datei
`applyStaticUpdate` auf — 3 EEP-API-Aufrufe pro Struktur. Da die Registries nach der
initialen Discovery bereits vollständig befüllt sind, wird jetzt der vorhandene Eintrag
aus dem `StructureRegistry` wiederverwendet. `applyStaticUpdate` wird nur noch für
Strukturen aufgerufen, die dort noch nicht vorhanden sind.

Implementiert in `ce/hub/data/structures/StructureDiscovery.lua` (`initFromAnl3`).

### Faustregel für EEP-API-Aufrufe

EEP-API-Aufrufe in Batches (Discovery, Reload) so minimal wie möglich halten.
Vorhandene Registry-Einträge besitzen bereits alle EEP-seitig abgefragten Daten
und müssen nicht erneut abgefragt werden.
