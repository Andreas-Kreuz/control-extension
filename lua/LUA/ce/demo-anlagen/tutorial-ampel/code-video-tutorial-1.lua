local Intersection = require("ce.mods.road.Intersection")
local Lane = require("ce.mods.road.Lane")
local TrafficLight = require("ce.mods.road.TrafficLight")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

-- Einfache Kreuzung mit zwei Fahrspuren und drei Ampeln
local K1 = TrafficLight:new("K1", 13, TrafficLightModel.JS2_3er_mit_FG)
local K2 = TrafficLight:new("K2", 24, TrafficLightModel.JS2_3er_ohne_FG)
local K3 = TrafficLight:new("K3", 15, TrafficLightModel.JS2_3er_mit_FG)

lane1 = Lane:new("FS1", 1, K1, { Lane.Directions.STRAIGHT, Lane.Directions.RIGHT })
lane2 = Lane:new("FS2", 2, K2, { Lane.Directions.LEFT })

local c = Intersection:new("Einfache Kreuzung")
local sgLane1StraightRight = c:newSignalGroup("sgLane1StraightRight"):addVehicleSignals(K1)
local sgLane2Left = c:newSignalGroup("sgLane2Left"):addVehicleSignals(K2, K3)
local phase1 = c:newPhase("P1")
phase1:addSignalGroup(sgLane1StraightRight)
local phase2 = c:newPhase("P2")
phase2:addSignalGroup(sgLane2Left)


-- Modulverwaltung der Lua-Bibliothek laden
local ControlExtension = require("ce.ControlExtension")
ControlExtension.addModules(
    require("ce.mods.road.CeRoadModule")
)

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end

-- Zähler kommen später hier

-- Noch nicht für die Verwendung vorgesehen
phase1.greenTimeSeconds = 5
phase2.greenTimeSeconds = 5
