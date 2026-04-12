# Den Kompatibilitätslayer für alte `ak`-Skripte nutzen

Dieses Dokument richtet sich an Anwender, die ihre bestehende EEP-Anlage mit `ak`-Code **nicht vollständig umschreiben** wollen. Der Kompatibilitätslayer erlaubt es, die meisten `require("ak.road....")`- und `require("ak.public-transport....")`-Aufrufe unverändert zu lassen und trotzdem die Control Extension zu nutzen.

## Was der Kompatibilitätslayer leistet

Die Dateien unter `LUA/ak/road/` und `LUA/ak/public-transport/` sind Weiterleitungsdateien. Sie leiten jeden `require`-Aufruf intern an die entsprechenden `ce`-Module weiter. Dein bestehender Code wird damit ohne inhaltliche Änderungen ausgeführt.

Abgedeckte Module:

| Dein bisheriger `require`                              | leitet intern weiter nach                        |
| ------------------------------------------------------ | ------------------------------------------------ |
| `ak.road.TrafficLight`                                 | `ce.mods.road.TrafficLight`                      |
| `ak.road.TrafficLightModel`                            | `ce.mods.road.TrafficLightModel`                 |
| `ak.road.TrafficLightState`                            | `ce.mods.road.TrafficLightState`                 |
| `ak.road.Crossing`                                     | `ce.mods.road.Intersection` (compat-Wrapper)     |
| `ak.road.CrossingSequence`                             | `ce.mods.road.IntersectionSequence`              |
| `ak.road.Lane`                                         | `ce.mods.road.Lane`                              |
| `ak.road.LaneSettings`                                 | `ce.mods.road.LaneSettings`                      |
| `ak.road.AxisStructureTrafficLight`                    | `ce.mods.road.AxisStructureTrafficLight`          |
| `ak.road.LightStructureTrafficLight`                   | `ce.mods.road.LightStructureTrafficLight`        |
| `ak.road.Bus`                                          | `ce.mods.road.Bus`                               |
| `ak.road.TramSwitch`                                   | `ce.mods.road.TramSwitch`                        |
| `ak.public-transport.Line`                             | `ce.mods.transit.Line` (compat-Wrapper)          |
| `ak.public-transport.LineRegistry`                     | `ce.mods.transit.LineRegistry`                   |
| `ak.public-transport.LineSegment`                      | `ce.mods.transit.LineSegment`                    |
| `ak.public-transport.RoadStation`                      | `ce.mods.transit.RoadStation`                    |
| `ak.public-transport.Platform`                         | `ce.mods.transit.Platform`                       |
| `ak.public-transport.StationQueue`                     | `ce.mods.transit.StationQueue`                   |
| `ak.public-transport.StationQueueEntry`                | `ce.mods.transit.StationQueueEntry`              |

Diese `require`-Zeilen kannst Du unverändert in Deinem Skript belassen.

## Was Du trotzdem ändern musst

Der Kompatibilitätslayer deckt nur die fachlichen Bausteine ab. Die Infrastruktur-Module — also alles, was das Framework selbst startet und registriert — existieren nicht mehr unter `ak.*` und müssen manuell umgestellt werden.

### 1. Einstiegspunkt: `ModuleRegistry` auf `ControlExtension` umstellen

```lua
-- alt
local ModuleRegistry = require("ak.core.ModuleRegistry")

-- neu
local ControlExtension = require("ce.ControlExtension")
```

Dazu die Methodennamen anpassen:

| Alt                                  | Neu                                       |
| ------------------------------------ | ----------------------------------------- |
| `ModuleRegistry.registerModules(…)`  | `ControlExtension.addModules(…)`          |
| `ModuleRegistry.runTasks(…)`         | `ControlExtension.runTasks(…)`            |
| `ModuleRegistry.deactivateServer()`  | `ControlExtension.deactivateServer()`     |
| `ModuleRegistry.activateServer()`    | `ControlExtension.activateServer()`       |

### 2. Modul-Wrapper austauschen

Diese alten Wrapper-Module gibt es unter `ak.*` nicht mehr:

| Alt                                              | Neu                                      |
| ------------------------------------------------ | ---------------------------------------- |
| `require("ak.core.CoreLuaModule")`               | nicht mehr nötig (in `ce` eingebaut)     |
| `require("ak.data.DataLuaModule")`               | nicht mehr nötig (in `ce` eingebaut)     |
| `require("ak.road.CrossingLuaModul")`            | `require("ce.mods.road.CeRoadModule")`   |
| `require("ak.public-transport.PublicTransportLuaModul")` | `require("ce.mods.transit.CeTransitModule")` |

### 3. Nicht abgedeckte Einzelmodule

Einige wenige Module haben keinen Compat-Eintrag und müssen direkt umgebogen werden:

| Alt                                                      | Neu                                                         |
| -------------------------------------------------------- | ----------------------------------------------------------- |
| `require("ak.scheduler.Scheduler")`                      | `require("ce.hub.scheduler.Scheduler")`                     |
| `require("ak.public-transport.RoadStationDisplayModel")` | `require("ce.mods.transit.models.RoadStationDisplayModel")` |

## Typisches Skript mit Kompatibilitätslayer

So sieht ein Skript aus, das den Compat-Layer nutzt. Die `ak.road.*`-Zeilen wurden unverändert übernommen; nur die Infrastruktur-Zeilen wurden angepasst:

```lua
-- Diese Zeilen bleiben unverändert:
local TrafficLight     = require("ak.road.TrafficLight")
local TrafficLightModel = require("ak.road.TrafficLightModel")
local Crossing         = require("ak.road.Crossing")
local CrossingSequence = require("ak.road.CrossingSequence")
local Lane             = require("ak.road.Lane")

-- Scheduler hat keinen Compat-Eintrag, muss direkt auf ce zeigen:
local Scheduler        = require("ce.hub.scheduler.Scheduler")

-- Infrastruktur muss auf ce umgestellt werden:
local ControlExtension = require("ce.ControlExtension")
ControlExtension.addModules(
    require("ce.mods.road.CeRoadModule")
)

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
```

## Hinweis zu `Crossing` und `CrossingSequence`

Die Compat-Datei für `ak.road.Crossing` liefert einen Wrapper, der alle Aufrufe an `ce.mods.road.Intersection` weiterleitet. Das bedeutet: Du kannst weiterhin `Crossing.new(...)` schreiben — es wird intern als `Intersection.new(...)` ausgeführt. Dasselbe gilt für `CrossingSequence`, das intern auf `IntersectionSequence` zeigt. Neue Skripte sollten direkt die `ce`-Namen verwenden.

## Nächste Schritte

Wenn Dein Skript mit dem Compat-Layer stabil läuft und Du irgendwann vollständig auf `ce` umsteigen möchtest, beschreibt [Migrate_ak_to_ce.md](Migrate_ak_to_ce.md) die vollständige Umstellung Schritt für Schritt.
