---
layout: page_with_toc
title: Lua Hub
subtitle: Das Herz von Control Extension für EEP
permalink: lua/LUA/ce/hub/
feature-img: '/docs/assets/headers/SourceCode.png'
img: '/docs/assets/headers/SourceCode.png'
---

# Was ist der Lua Hub?

Der Lua Hub ist die interne Laufzeit- und Datenplattform der Control Extension in EEP.

Seine Aufgaben sind:

1. **Module orchestrieren**
   - registrierte `CeModule` initialisieren
   - zyklische Modulaufrufe in `EEPMain()` ausführen
   - zeitversetzte Aufgaben über den Scheduler abarbeiten

2. **EEP-Daten erfassen und veröffentlichen**
   - Discovery und Updates der Hub-Daten ausführen
   - bekannte Zustände in Registries halten
   - Änderungen als DTOs über den Datenbus veröffentlichen

3. **Bridge-Anbindung bereitstellen**
   - Hub- und Modul-Publisher an die Publishing-Infrastruktur anbinden
   - Daten für Server und Web App verfügbar machen

# Schnellstart

`ce.ControlExtension` ist der stabile Einstiegspunkt für EEP-Skripte. Darüber bindest Du die Control Extension in Deine Anlage ein und führst sie in `EEPMain()` zyklisch aus.

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
- `require("ce.hub.CeHubModule").setOptions({ sync = { ... } })`

Das Hub-Modul ist bereits eingebaut. Du musst es nur dann explizit an `addModules(...)` übergeben, wenn Du seine Optionen direkt im Initialisierungscode setzen möchtest.

## `ControlExtension.initTasks()`

Initialisiert die registrierten Module einmalig.

Diese Funktion ist optional. Wenn Du sie nicht selbst aufrufst, geschieht die Initialisierung automatisch beim ersten Aufruf von `ControlExtension.runTasks(...)`.

## `ControlExtension.runTasks(cycleCount)`

Führt die registrierten Module zyklisch aus.

Dieser Aufruf gehört in `EEPMain()`. Der optionale Parameter `cycleCount` steuert, in welchem Abstand I/O-nahe Veröffentlichungen erfolgen:

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

## Beispiel mit Hub-Optionen

```lua
local ControlExtension = require("ce.ControlExtension")
local CeHubModule = require("ce.hub.CeHubModule")

ControlExtension
    .setDebug(true)
    .activateServer()
    .setPauseEepDuringInitialization(true)
    .addModules(
        require("ce.mods.road.CeRoadModule"),
        CeHubModule.setOptions({
            sync = {
                ceTypes = {
                    trains = { mode = "selected" },
                    rollingStocks = { mode = "selected" },
                },
                fields = {
                    trains = {
                        speed = { collect = true },
                        targetSpeed = { collect = true },
                    },
                },
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

## Aktiver Hub-Lebenszyklus

Der aktive Hub-Pfad läuft heute in dieser Form:

1. `MainLoopRunner` ruft `module.init()` für alle registrierten Module auf.
2. `CeHubModule.init()` registriert Publisher und Hub-Funktionen und führt die Initial-Discovery und Initial-Updates aus.
3. `MainLoopRunner` ruft in jedem Zyklus `module.run()` auf.
4. `CeHubModule.run()` führt Discovery und Updates aus und startet danach den Scheduler.
5. Die registrierten `*StatePublisher` rufen nur noch `Publisher.syncState(...)` auf und veröffentlichen Änderungen über `DataChangeBus`.

Damit liegen Discovery und Fetch-Logik heute nicht mehr in den `*StatePublisher.lua`-Dateien, sondern in `CeHubModule`, `Discovery`- und `Updater`-Klassen.

# Bridge-Anbindung

Die Lua-seitige Anbindung des Hubs an den Web-Server liegt in `ce.hub.HubBridgeConnector`.

## Keine öffentliche API

Die Bridge wird indirekt über `ControlExtension` gesteuert:

- `ControlExtension.activateServer()` - schaltet die Server-Kommunikation ein
- `ControlExtension.deactivateServer()` - schaltet sie aus, ohne die übrigen Module zu stoppen

Direkter Zugriff auf interne Dateien unter `ce.hub.*` ist nicht vorgesehen.

# Unterverzeichnisse

- [OPTIONS.md](OPTIONS.md) - Hub-Optionen, Fetch-Policy und Sync-Policy
- [data/README.md](data/README.md) - Hub-Daten, CeTypes und Klassenstruktur
- [data/DTO.md](data/DTO.md) - aktive CeTypes und DTO-Felder des Hubs
- [docs/README.md](docs/README.md) - ergänzende Architekturdokumente
- [eep/README.md](eep/README.md) - EEP-Simulator für Tests ohne EEP
- [scheduler/README.md](scheduler/README.md) - zeitbasierter Task-Planer
- [util/README.md](util/README.md) - technische Hilfsfunktionen

---

Architekturbeschreibung: [README_DEV.md](README_DEV.md)
