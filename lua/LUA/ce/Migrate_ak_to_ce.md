# Migration von `ak` nach `ce`

Dieses Dokument richtet sich an Anwender, die bisher die alte `ak`-Bibliothek in ihrer EEP-Anlage genutzt haben und nun auf die Control Extension mit `ce` umsteigen wollen.

Die typische Ausgangslage ist:

- In Deinem EEP-`LUA`-Verzeichnis liegen bisher Dateien unter `ak/...`.
- Dein Anlagen-Skript lädt Module wie `ak.core.ModuleRegistry`, `ak.road.CrossingLuaModul` oder `ak.public-transport.*`.
- Jetzt soll dieselbe Anlage mit `ce/...` und `ce.ControlExtension` laufen.

## Was bleibt gleich, was ändert sich?

Gleich bleibt:

- Du arbeitest weiterhin im `LUA`-Verzeichnis Deiner EEP-Installation.
- Dein Anlagen-Skript wird weiterhin über `require("mein-skript")` geladen.
- `EEPMain()` bleibt der zyklische Einstiegspunkt.

Anders ist heute:

- Der öffentliche Einstieg in die Bibliothek ist nicht mehr `ak.core.ModuleRegistry`, sondern `ce.ControlExtension`.
- Alte `*LuaModul`- oder `*LuaModule`-Wrapper wurden durch `*CeModule` ersetzt.
- Frühere `ak`-Bereiche wurden fachlich neu gegliedert, vor allem nach `ce.hub`, `ce.databridge`, `ce.mods.road` und `ce.mods.transit`.

## Der wichtigste Einstiegspunkt

Wenn Dein altes Skript ungefähr so aussah:

```lua
local ModuleRegistry = require("ak.core.ModuleRegistry")

ModuleRegistry.registerModules(
    require("ak.core.CoreLuaModule"),
    require("ak.road.CrossingLuaModul")
)

function EEPMain()
    ModuleRegistry.runTasks(1)
    return 1
end
```

dann sieht derselbe Einstieg heute typischerweise so aus:

```lua
local ControlExtension = require("ce.ControlExtension")

ControlExtension.addModules(
    require("ce.mods.road.CeRoadModule")
)

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
```

Wichtig dabei:

- `ce.ControlExtension` ist die öffentliche API für Deine Anlage.
- Das eingebaute Hub-Modul ist bereits vorhanden.
- `ce.hub.CeHubModule` musst Du nur dann explizit an `addModules(...)` übergeben, wenn Du direkt Hub-Optionen setzen möchtest.

## Typische Umstellung in 4 Schritten

### 1. Einstiegspunkt umstellen

Ersetze:

```lua
local ModuleRegistry = require("ak.core.ModuleRegistry")
```

durch:

```lua
local ControlExtension = require("ce.ControlExtension")
```

und ersetze dann:

- `ModuleRegistry.registerModules(...)` durch `ControlExtension.addModules(...)`
- `ModuleRegistry.runTasks(...)` durch `ControlExtension.runTasks(...)`
- `ModuleRegistry.deactivateServer()` durch `ControlExtension.deactivateServer()`
- `ModuleRegistry.activateServer()` durch `ControlExtension.activateServer()`

### 2. Alte Module austauschen

Bisherige Module sind:

- `ak.core.CoreLuaModule`
- `ak.data.DataLuaModule`
- `ak.road.CrossingLuaModul`
- `ak.public-transport.PublicTransportLuaModul`

Die neuen Module sind:

- `ce.hub.CeHubModule` (ersetzt das bisherige `CoreLuaModule` und das `DataLuaModule`)
- `ce.mods.road.CeRoadModule` (ersetzt das `ak.road.CrossingLuaModul`)
- `ce.mods.transit.CeTransitModule` (ersetzt das `PublicTransportLuaModul`)

Dabei ist der wichtigste Punkt:

- Die Ampelsteuerung wird heute über `ce.mods.road.CeRoadModule` eingebunden.
- Der frühere ÖPNV-Bereich `ak.public-transport` läuft heute über `ce.mods.transit`.

### 3. Häufige `require(...)`-Pfade anpassen

Die Importe von Lua-Dateien bleiben ähnlich, liegen aber heute an anderer Stelle.

Typische Beispiele:

| Alt                                                      | Neu                                                         |
| -------------------------------------------------------- | ----------------------------------------------------------- |
| `require("ak.road.TrafficLight")`                        | `require("ce.mods.road.TrafficLight")`                      |
| `require("ak.road.TrafficLightModel")`                   | `require("ce.mods.road.TrafficLightModel")`                 |
| `require("ak.road.Crossing")`                            | `require("ce.mods.road.Intersection")`                      |
| `require("ak.road.CrossingSequence")`                    | `require("ce.mods.road.IntersectionSequence")`              |
| `require("ak.road.Lane")`                                | `require("ce.mods.road.Lane")`                              |
| `require("ak.public-transport.Line")`                    | `require("ce.mods.transit.Line")`                           |
| `require("ak.public-transport.LineRegistry")`            | `require("ce.mods.transit.LineRegistry")`                   |
| `require("ak.public-transport.RoadStation")`             | `require("ce.mods.transit.RoadStation")`                    |
| `require("ak.public-transport.RoadStationDisplayModel")` | `require("ce.mods.transit.models.RoadStationDisplayModel")` |

Wichtig:

- Im alten Projekt hieß der Bereich `ak.public-transport.*`, nicht `ak.transit.*`.
- Ersetze also nicht blind `ak.` durch `ce.`.

### 4. Erst danach Feinschliff machen

Wenn das Skript wieder lädt, kannst Du danach zusätzliche Umstellungen vornehmen:

- Debug-Ausgaben von Feldzugriffen auf Setter umstellen
- alte Web-/Server-Annahmen prüfen
- Hub-Optionen ergänzen, falls Du sie wirklich brauchst

## Kurzes Vorher/Nachher aus den Anleitungen

Die alten Anleitungen haben beim Ampel-Tutorial etwa so begonnen:

```lua
local Scheduler = require("ak.scheduler.Scheduler")
local TrafficLight = require("ak.road.TrafficLight")
local TrafficLightModel = require("ak.road.TrafficLightModel")
local Crossing = require("ak.road.Crossing")
local CrossingSequence = require("ak.road.CrossingSequence")
local Lane = require("ak.road.Lane")

local ModuleRegistry = require("ak.core.ModuleRegistry")
ModuleRegistry.registerModules(
    require("ak.core.CoreLuaModule"),
    require("ak.road.CrossingLuaModul")
)
```

Die aktuellen Anleitungen zeigen denselben Einstieg heute so:

```lua
local Scheduler = require("ce.hub.scheduler.Scheduler")
local TrafficLight = require("ce.mods.road.TrafficLight")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
local Crossing = require("ce.mods.road.Intersection")
local CrossingSequence = require("ce.mods.road.IntersectionSequence")
local Lane = require("ce.mods.road.Lane")

local ControlExtension = require("ce.ControlExtension")
ControlExtension.addModules(
    require("ce.mods.road.CeRoadModule")
)
```

Wenn Du also aus einem alten Tutorial oder einer alten Anlage umsteigst, dann achte vor allem auf diese drei Änderungen:

1. `ModuleRegistry` wird durch `ControlExtension` ersetzt.
2. `CrossingLuaModul` wird durch `CeRoadModule` ersetzt.
3. `Crossing` und `CrossingSequence` heißen heute `Intersection` und `IntersectionSequence`.

## Öffentlicher Verkehr: alte Namen, neue Namen

Beim Öffentlichen Verkehr ist die Umstellung besonders wichtig, weil die alte Bibliothek andere Paketnamen verwendet hat.

Alte `ak`-Seite:

```lua
local Line = require("ak.public-transport.Line")
local RoadStation = require("ak.public-transport.RoadStation")
local RoadStationDisplayModel = require("ak.public-transport.RoadStationDisplayModel")
```

Neue `ce`-Seite:

```lua
local Line = require("ce.mods.transit.Line")
local RoadStation = require("ce.mods.transit.RoadStation")
local RoadStationDisplayModel = require("ce.mods.transit.models.RoadStationDisplayModel")
```

Auch das Modul fuer die Laufzeit wurde umbenannt:

- alt: `require("ak.public-transport.PublicTransportLuaModul")`
- neu: `require("ce.mods.transit.CeTransitModule")`

## Typische Fehler beim ersten Umstieg

Wenn nach dem Umstellen weiter Fehlermeldungen kommen, liegt es meist an einem dieser Punkte:

- Du hast noch `ak.core.ModuleRegistry` im Skript stehen.
- Du hast `ak.public-transport.*` uebersehen.
- Du hast `ak.road.CrossingLuaModul` noch nicht auf `ce.mods.road.CeRoadModule` umgestellt.
- Du hast nur `ak.` durch `ce.` ersetzt und dabei fachliche Umbenennungen wie `Crossing -> Intersection` uebersehen.
- Du versuchst interne `ce.hub.*`-Dateien direkt als Anwender-Einstieg zu verwenden.

## Praktische Reihenfolge fuer bestehende Anlagen

Wenn Du eine bestehende Anlage umstellst, ist diese Reihenfolge meistens am sichersten:

1. `ak.core.ModuleRegistry` auf `ce.ControlExtension` umstellen.
2. Alte Modul-Wrapper auf `CeRoadModule` und `CeTransitModule` umstellen.
3. Direkte `require(...)`-Pfade fuer Strassenverkehr und OEffentlichen Verkehr anpassen.
4. `EEPMain()` mit `ControlExtension.runTasks(...)` laufen lassen.
5. Erst danach Spezialfaelle wie Debug, Server oder Hub-Optionen anpassen.

## Weiterfuehrende Referenz

Wenn Du nicht nur migrieren, sondern alte Namen technisch exakt gegen neue Namen nachschlagen willst, nutze die Entwickler-Referenz:

- [References_for_old_ak_functions.md](References_for_old_ak_functions.md)
