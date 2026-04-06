---
layout: page_with_toc
title: Lua Hub
subtitle: Das Herz von Control Extension für EEP
permalink: lua/LUA/ce/hub/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Was ist der Lua Hub?

Der Lua Hub dient der Sammlung aller Daten aus einer EEP-Anlage.

Seine Aufgaben sind:

1. **Erfassen und Bereitstellen von Daten**
   - Erfassen der Daten beim Anlagenstart
   - Erkennen geänderter Daten im Betrieb
   - Halten der Daten zur späteren Verwendung
   - Bereitstellen der Daten über den DataBus

2. **Steuern der Datenübergabe und Module**
   - Initialisieren und Ausführen von Control Extension Modulen
   - Planen und Ausführen verzögerter Funktionenaufrufe
   - Datenbereitstellung an den Control Extension Server

# Schnellstart

`ce.ControlExtension` ist der stabile Einstiegspunkt für EEP-Skripte — darüber bindest Du die Control Extension in deine EEP-Anlage ein und führst sie in `EEPMain()` zyklisch aus.

Das folgende Beispiel skizziert den minimalen Lua-Code, den du für eine Anlage benötigst.

```lua
local ControlExtension = require("ce.ControlExtension")

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
```

# Öffentliche API

```lua
local ControlExtension = require("ce.ControlExtension")
```

## `ControlExtension.addModules(...)`

Registriert die CeModule, die später ausgeführt werden sollen.

Beispiele für zulässige Module:

- `require("ce.mods.road.CeRoadModule")`
- `require("ce.mods.transit.CeTransitModule")`
- `require("ce.hub.CeHubModule").setOptions({ ... })`

Das Hub-Modul ist bereits eingebaut. Du musst es nur dann explizit an `addModules(...)` übergeben, wenn du seine Optionen direkt im Initialisierungscode setzen möchtest.

## `ControlExtension.initTasks()`

Initialisiert die registrierten Module einmalig.

Diese Funktion ist optional.
Wenn Du sie nicht selbst aufrufst, geschieht die Initialisierung automatisch beim ersten Aufruf von `ControlExtension.runTasks(...)`.

## `ControlExtension.runTasks(cycleCount)`

Führt die registrierten Module zyklisch aus.

Dieser Aufruf gehört in `EEPMain()`.
Der optionale Parameter `cycleCount` steuert, in welchem Abstand I/O-nahe Veröffentlichungen erfolgen:

- `1`: bei jedem EEP-Zyklus
- `5`: ungefähr einmal pro Sekunde
- `0`: bei jedem Zyklus ohne Intervallprüfung

## `ControlExtension.activateServer()`

Aktiviert die Server-Kommunikation wieder, falls sie zuvor deaktiviert wurde.

## `ControlExtension.deactivateServer()`

Deaktiviert die Server-Kommunikation, ohne die übrigen Modulzyklen abzuschalten.

## `ControlExtension.setDebug(boolean)`

Schaltet Debug-Ausgaben für den Laufzeitablauf ein oder aus.

## `ControlExtension.setPauseEepDuringInitialization(boolean)`

Steuert, ob EEP während der ersten Initialisierung der Module kurz pausiert werden soll.

## Kurzes Beispiel

```lua
local ControlExtension = require("ce.ControlExtension")

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
```

## Langes Beispiel

```lua
local ControlExtension = require("ce.ControlExtension")

ControlExtension
    .setDebug(true)
    .activateServer()
    .setPauseEepDuringInitialization(true)
    .addModules(
        require("ce.mods.road.CeRoadModule"),
        require("ce.hub.CeHubModule").setOptions({
            collectedCeTypes = {
                require("ce.hub.CeHubModule").CeTypes.Train,
            },
        })
    )

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
```

# Architektur

Das Zielbild aus Anwendersicht ist bewusst einfach:

1. `ce.ControlExtension` ist die öffentliche Fassade.
2. Über `addModules(...)` registrierst Du die gewünschten Module.
3. `EEPMain()` ruft `runTasks(...)` regelmäßig auf.
4. Die registrierten Module führen ihre Initialisierung und ihre zyklischen Aufgaben aus.

Wichtig ist dabei:

- Du arbeitest gegen `ce.ControlExtension`, nicht gegen interne Hub-Dateien.
- Hub-Module dürfen als Argumente an `addModules(...)` genannt werden.
- Die interne Orchestrierung innerhalb von `ce.hub` ist kein Teil der öffentlichen API.

# Bridge-Anbindung

Die Lua-seitige Anbindung des Hubs an den Web-Server liegt direkt in `ce.hub.HubBridgeConnector`.

## Keine öffentliche API

Die Bridge wird indirekt über `ControlExtension` gesteuert:

- `ControlExtension.activateServer()` — schaltet die Server-Kommunikation ein
- `ControlExtension.deactivateServer()` — schaltet sie aus, ohne die übrigen Module zu stoppen

Direkter Zugriff auf interne Dateien unter `ce.hub.*` ist nicht vorgesehen.

# Unterverzeichnisse

- [data/DTO.md](data/DTO.md) — Alle Datenräume und DTO-Typen der eingebauten Collector
- [eep/README.md](eep/README.md) — EEP-Simulator für Tests ohne EEP
- [scheduler/README.md](scheduler/README.md) — Zeitbasierter Task-Planer
- [util/README.md](util/README.md) — Hilfsfunktionen für persistente Zustandsablage

---

Architekturbeschreibung: [README_DEV.md](README_DEV.md)
