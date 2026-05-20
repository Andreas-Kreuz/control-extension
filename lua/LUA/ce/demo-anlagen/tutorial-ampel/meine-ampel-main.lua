clearlog()
print("ce.demo-anlagen.tutorial-ampel.meine-ampel-main")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
local TrafficLight = require("ce.mods.road.TrafficLight")
local Lane = require("ce.mods.road.Lane")
local Intersection = require("ce.mods.road.Intersection")
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

-- Hier kommt der Code
IntersectionSettings.showSignalIdOnSignal = false
IntersectionSettings.showPhaseOnSignal = false

local K1 = TrafficLight:new("K1", 12, TrafficLightModel.JS2_3er_mit_FG)
local K2 = TrafficLight:new("K2", 17, TrafficLightModel.JS2_3er_ohne_FG)
local K3 = TrafficLight:new("K3", 9, TrafficLightModel.JS2_3er_mit_FG)
local K4 = TrafficLight:new("K4", 14, TrafficLightModel.JS2_3er_mit_FG)
local K5 = TrafficLight:new("K5", 16, TrafficLightModel.JS2_3er_mit_FG)
local K6 = TrafficLight:new("K6", 18, TrafficLightModel.JS2_3er_ohne_FG)
local K7 = TrafficLight:new("K7", 11, TrafficLightModel.JS2_3er_mit_FG)
local K8 = TrafficLight:new("K8", 10, TrafficLightModel.JS2_3er_mit_FG)
local K9 = TrafficLight:new("K9", 19, TrafficLightModel.JS2_3er_ohne_FG)
local K10 = TrafficLight:new("K10", 13, TrafficLightModel.JS2_3er_mit_FG)
local K11 = TrafficLight:new("K11", 15, TrafficLightModel.JS2_3er_mit_FG)
local K12 = TrafficLight:new("K12", 24, TrafficLightModel.JS2_3er_ohne_FG)

local F1 = K1:withPedestrian("F1") -- K1 wird später auch als Fussgaenger-Ampel F1 verwendet
local F2 = K3:withPedestrian("F2") -- K3 wird später auch als Fussgaenger-Ampel F2 verwendet
local F3 = TrafficLight:newPedestrianOnly("F3", 20, TrafficLightModel.JS2_2er_nur_FG)
local F4 = TrafficLight:newPedestrianOnly("F4", 21, TrafficLightModel.JS2_2er_nur_FG)
local F5 = K4:withPedestrian("F5")
local F6 = K5:withPedestrian("F6")
local F7 = K7:withPedestrian("F7")
local F8 = K8:withPedestrian("F8")
local F9 = TrafficLight:newPedestrianOnly("F9", 22, TrafficLightModel.JS2_2er_nur_FG)
local F10 = TrafficLight:newPedestrianOnly("F10", 23, TrafficLightModel.JS2_2er_nur_FG)
local F11 = K10:withPedestrian("F11")
local F12 = K11:withPedestrian("F12")
-------------------------------------------------------------------------------
-- Definiere die Fahrspuren fuer die Kreuzung
-------------------------------------------------------------------------------

--   +---------------------------------------------- Neue Fahrspur
--   |        +------------------------------- Name der Fahrspur
--   |        |     +------------------------- Speicher ID - um die Anzahl der Fahrzeuge
--   |        |     |                                        und die Wartezeit zu speichern
--   |        |     |      +------------------ Fahrspur-Ampel - da wartet der Verkehr
--   |        |     |      |           +------ Signal-ID dieser Ampel
--   |        |     |      |           |   +-- Modell kann rot, gelb, gruen und FG schalten
n1 = Lane:new("N1", K1, { "STRAIGHT", "RIGHT" })
n2 = Lane:new("N2", K3, { "LEFT" }) -- zusätzlich in der Phase K2

-- Fahrspuren im Osten
o1 = Lane:new("O1", K4, { "STRAIGHT", "RIGHT" })
o2 = Lane:new("O2", K6, { "LEFT" }) -- zusätzlich in der Phase K5

-- Fahrspuren im Sueden
s1 = Lane:new("S1", K7, { "STRAIGHT", "RIGHT" })
s2 = Lane:new("S2", K8, { "LEFT" }) -- zusätzlich in der Phase K9

-- Fahrspuren im Westen
w1 = Lane:new("W1", K10, { "STRAIGHT", "RIGHT" })
w2 = Lane:new("W2", K12, { "LEFT" }) -- Zusätzlich in der Phase K11

--------------------------------------------------------------
-- Definiere die Phasen und die Kreuzung
--------------------------------------------------------------
-- Eine Phase bestimmt, welche Fahrspuren gleichzeitig auf
-- grün geschaltet werden dürfen, alle anderen sind rot

k1 = Intersection:new("Tutorial 1")
local sgNorthStraightRight = k1:newSignalGroup("sgNorthStraightRight"):addVehicleSignals(K1)
local sgNorthLeft = k1:newSignalGroup("sgNorthLeft"):addVehicleSignals(K2, K3)
local sgEastStraightRight = k1:newSignalGroup("sgEastStraightRight"):addVehicleSignals(K4)
local sgEastLeft = k1:newSignalGroup("sgEastLeft"):addVehicleSignals(K5, K6)
local sgSouthStraightRight = k1:newSignalGroup("sgSouthStraightRight"):addVehicleSignals(K7)
local sgSouthLeft = k1:newSignalGroup("sgSouthLeft"):addVehicleSignals(K8, K9)
local sgWestStraightRight = k1:newSignalGroup("sgWestStraightRight"):addVehicleSignals(K10)
local sgWestLeft = k1:newSignalGroup("sgWestLeft"):addVehicleSignals(K11, K12)
local sgPedNorth = k1:newSignalGroup("sgPedNorth"):addPedestrianSignals(F1, F2)
local sgPedEast = k1:newSignalGroup("sgPedEast"):addPedestrianSignals(F3, F4)
local sgPedSouth = k1:newSignalGroup("sgPedSouth"):addPedestrianSignals(F7, F8)
local sgPedWest = k1:newSignalGroup("sgPedWest"):addPedestrianSignals(F9, F10)
local sgPedNorthSouth = k1:newSignalGroup("sgPedNorthSouth"):addPedestrianSignals(F5, F6)
local sgPedEastWest = k1:newSignalGroup("sgPedEastWest"):addPedestrianSignals(F11, F12)

--- Tutorial 1: Phase 1
local phase1 = k1:newPhase("P1")
phase1:addSignalGroup(sgNorthStraightRight, sgSouthStraightRight, sgPedNorthSouth, sgPedEastWest)

--- Tutorial 1: Phase 2
local phase2 = k1:newPhase("P2")
phase2:addSignalGroup(sgNorthLeft, sgSouthLeft, sgPedEast, sgPedNorthSouth, sgPedEastWest, sgPedWest)

--- Tutorial 1: Phase 3
local phase3 = k1:newPhase("P3")
phase3:addSignalGroup(sgEastStraightRight, sgWestStraightRight, sgPedNorth, sgPedEast, sgPedSouth, sgPedWest)

--- Tutorial 1: Phase 4
local phase4 = k1:newPhase("P4")
phase4:addSignalGroup(sgEastLeft, sgWestLeft, sgPedNorth, sgPedSouth)
k1:addStaticCam("Richtung Norden")
k1:addStaticCam("Richtung Ost")
k1:addStaticCam("Übersicht")

local ControlExtension = require("ce.ControlExtension")
local crossingCeModule = require("ce.mods.road.CeRoadModule")
ControlExtension.addModules(crossingCeModule)

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
