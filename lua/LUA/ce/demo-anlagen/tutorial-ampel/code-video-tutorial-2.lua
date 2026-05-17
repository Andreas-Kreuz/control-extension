local Intersection = require("ce.mods.road.Intersection")
local Lane = require("ce.mods.road.Lane")
local TrafficLight = require("ce.mods.road.TrafficLight")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

-- Einfache Kreuzung mit zwei Fahrspuren und drei Ampeln
local K1 = TrafficLight:new("K1", 13, TrafficLightModel.JS2_3er_mit_FG)
local K2 = TrafficLight:new("K2", 24, TrafficLightModel.JS2_3er_ohne_FG)
local K3 = TrafficLight:new("K3", 15, TrafficLightModel.JS2_3er_mit_FG)
local K4 = TrafficLight:new("K4", 12, TrafficLightModel.JS2_3er_mit_FG)
local K5 = TrafficLight:new("K5", 17, TrafficLightModel.JS2_3er_ohne_FG)
local K6 = TrafficLight:new("K6", 09, TrafficLightModel.JS2_3er_mit_FG)
local F1 = TrafficLight:newPedestrianOnly("F1", 20, TrafficLightModel.JS2_2er_nur_FG)
local F2 = TrafficLight:newPedestrianOnly("F2", 21, TrafficLightModel.JS2_2er_nur_FG)

lane1 = Lane:new("FS1", K1, { Lane.Directions.STRAIGHT, Lane.Directions.RIGHT })
lane2 = Lane:new("FS2", K2, { Lane.Directions.LEFT })
lane3 = Lane:new("FS3", K5, { Lane.Directions.STRAIGHT, Lane.Directions.RIGHT })
lane4 = Lane:new("FS4", K6, { Lane.Directions.LEFT })

local c = Intersection:new("Einfache Kreuzung", 5)
local sgLane1StraightRight = c:newSignalGroup("sgLane1StraightRight"):addVehicleSignals(K1)
local sgLane2Left = c:newSignalGroup("sgLane2Left"):addVehicleSignals(K2, K3)
local sgLane3StraightRight = c:newSignalGroup("sgLane3StraightRight"):addVehicleSignals(K4, K5)
local sgLane4Left = c:newSignalGroup("sgLane4Left"):addVehicleSignals(K6)
local sgPedSouth = c:newSignalGroup("sgPedSouth"):addPedestrianSignals(K4, K6, F1, F2)
local sgPedNorth = c:newSignalGroup("sgPedNorth"):addPedestrianSignals(K1, K3)
local phase1 = c:newPhase("P1")
phase1:addSignalGroup(sgLane1StraightRight, sgPedSouth)
local phase2 = c:newPhase("P2")
phase2:addSignalGroup(sgLane2Left, sgPedSouth)
local phase3 = c:newPhase("P3")
phase3:addSignalGroup(sgLane3StraightRight, sgLane4Left, sgPedNorth)


-- Modulverwaltung der Lua-Bibliothek laden
local ControlExtension = require("ce.ControlExtension")
ControlExtension.addModules(
    require("ce.mods.road.CeRoadModule")
)

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
