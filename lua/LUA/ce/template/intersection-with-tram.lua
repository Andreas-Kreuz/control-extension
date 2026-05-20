-----------------------------------------------------------------------------------------------------------------------
-- Diese Skript ist eine kleine Vorlage für das Verwenden von Kreuzungen, WENN DU NOCH KEIN LUA IN DER ANLAGE BENUTZT
-- 1) Kopiere dieses Skript in das LUA-Verzeichnis von EEP
-- 2) Benenne die Kopie um, z.B. "anlage1.lua"
-- 3) Verwende die folgende Zeile im Lua-Editor von EEP, um Deine Kopie in EEP mit der Anlage zu laden
--    require("anlage1")
-----------------------------------------------------------------------------------------------------------------------
-- Diese Zeile lädt den Einstiegspunkt der Lua-Bibliothek
local ControlExtension = require("ce.ControlExtension")
local crossingCeModule = require("ce.mods.road.CeRoadModule")

ControlExtension.addModules(crossingCeModule)

-- Die EEPMain Methode wird von EEP genutzt. Sie muss immer 1 zurückgeben.
function EEPMain()
    -- ControlExtension startet die Aufgaben in allen Modulen bei jedem fünften EEPMain-Aufruf
    ControlExtension.runTasks(5)
    return 1
end

-- Hier kommt eine Kreuzung mit 4 Fahrspuren
--                                |    N   |        |        |
--                                | lane 1 |        |        |
--                                |        |        |        |
--                                |STRAIGHT|        |        |
--                             S1 | +RIGHT |        |        |
--                             K1 |========|========|========| K2
--                                |        |        |        |
--                    K3          |        |        |        |
--  ------------------------------+        +        |        |
--                       |  |                                |
--                       |  |                                |
--                       |  |                                |
--  ----------------------  ------+                          |
--                       |  |                                |
--  W lane 2  LEFT+RIGHT |K5|                                |
--                       |  |                                |
--  ------------------------------+        +        |        |
--                    K6,         |        |        |        |
--                    K7          |        |        |        | S2
--  In lane 2 all cars         K8=|========|========|========|-K9
--  allowed to turn               |        | LEFT   |STRAIGHT|
--  right when lane 3             |        |        |        |
--  is turning left               |        | lane 3 | lane 4 |
--  (Route: RIGHT_TURN_ROUTE)     |        |   S    |    S   |
--

local Lane = require("ce.mods.road.Lane")
local Intersection = require("ce.mods.road.Intersection")
local TrafficLight = require("ce.mods.road.TrafficLight")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

-- Fahrspur-Ampeln (L) regeln den Verkehr der Fahrspur
local L1, L2, L3, L4
-- Ampeln für den Kraftfahrverkehr (K) und Strassenbahnen (S)
local K1, K2, K3, K5, K6, K7, K8, K9, S1, S2
-- Phasen
local phase1, phase2, phase3
-- die Kreuzung
local crossing

-- Nutze einen Speicherslot in EEP um die Einstellungen für Kreuzungen zu laden und zu speichern
crossingCeModule.loadSettingsFromSlot(10)

-- Erzeuge immer erst Deine Ampeln
L1 = TrafficLight:new("L1", 11, TrafficLightModel.Unsichtbar_2er)           -- Signal for Lane 1
L2 = TrafficLight:new("L2", 12, TrafficLightModel.Unsichtbar_2er)           -- Signal for Lane 2
L3 = TrafficLight:new("L3", 13, TrafficLightModel.Unsichtbar_2er)           -- Signal for Lane 3
L4 = TrafficLight:new("L4", 14, TrafficLightModel.Unsichtbar_2er)           -- Signal for Lane 4
K1 = TrafficLight:new("K1", 23, TrafficLightModel.JS2_3er_mit_FG)           -- NORTH STRAIGHT 1 (right)
K2 = TrafficLight:new("K2", 24, TrafficLightModel.JS2_3er_mit_FG)           -- NORTH STRAIGHT 2 (left)
K3 = TrafficLight:new("K3", 25, TrafficLightModel.JS2_3er_mit_FG)           -- EAST STRAIGHT (left)
K5 = TrafficLight:new("K5", 27, TrafficLightModel.JS2_3er_ohne_FG)          -- EAST STRAIGHT (above lane)
K6 = TrafficLight:new("K6", 28, TrafficLightModel.JS2_3er_mit_FG)           -- EAST STRAIGHT (right)
K7 = TrafficLight:new("K7", 29, TrafficLightModel.JS2_2er_OFF_YELLOW_GREEN) -- EAST RIGHT ADDITIONAL (right)
K8 = TrafficLight:new("K8", 30, TrafficLightModel.JS2_3er_mit_FG)           -- SOUTH LEFT (left)
K9 = TrafficLight:new("K9", 31, TrafficLightModel.JS2_3er_mit_FG)           -- SOUTH STRAIGHT (right)

-- Straßenbahn-Ampeln mit Immobilien OHNE echtes Signal
S1 = TrafficLight:new("S1", -1, TrafficLightModel.NONE, "#5528_Straba Signal Halt", "#5531_Straba Signal geradeaus",
                      "#5529_Straba Signal anhalten", "#5530_Straba Signal A")
S2 = TrafficLight:new("S2", -1, TrafficLightModel.NONE, "#5435_Straba Signal Halt", "#5521_Straba Signal geradeaus",
                      "#5520_Straba Signal anhalten", "#5518_Straba Signal A")

-- Erzeuge Kreuzung und Fahrspuren
crossing = Intersection:new("Dein Kreuzungsname")
lane1 = Lane:new("Lane 1 N", L1, { Lane.Directions.STRAIGHT, Lane.Directions.RIGHT })
lane2 = Lane:new("Lane 2 E", L2, { Lane.Directions.LEFT, Lane.Directions.RIGHT })
lane3 = Lane:new("Lane 3 S", L3, { Lane.Directions.LEFT })
lane4 = Lane:new("Lane 4 S", L4, { Lane.Directions.STRAIGHT })

local sgLane1StraightRight = crossing:newSignalGroup("sgLane1StraightRight"):addVehicleSignals(K1, K2)
local sgLane2Left = crossing:newSignalGroup("sgLane2Left"):addVehicleSignals(K6)
local sgLane2Right = crossing:newSignalGroup("sgLane2Right"):addVehicleSignals(K7)
local sgLane3Left = crossing:newSignalGroup("sgLane3Left"):addVehicleSignals(K8)
local sgLane4Straight = crossing:newSignalGroup("sgLane4Straight"):addVehicleSignals(K9)
local sgEastVehicle = crossing:newSignalGroup("sgEastVehicle"):addVehicleSignals(K3, K5)
local sgTramNorthSouth = crossing:newSignalGroup("sgTramNorthSouth"):addTramSignals(S1, S2)
local sgPedEast = crossing:newSignalGroup("sgPedEast"):addPedestrianSignals(K3, K6)
local sgPedNorthSouth = crossing:newSignalGroup("sgPedNorthSouth"):addPedestrianSignals(K1, K2, K8, K9)

-- Lege fest, welche Ampelgruppen für eine Kreuzung gelten
lane1:driveOnDefaultSignalGroups(sgLane1StraightRight)
lane2:driveOnDefaultSignalGroups(sgLane2Left)
lane2:routes("Rechtsabbieger"):driveAlsoOnSignalGroups(sgLane2Right)
lane3:driveOnDefaultSignalGroups(sgLane3Left)
lane4:driveOnDefaultSignalGroups(sgLane4Straight)

-- Lege die Phasen an
phase1 = crossing:newPhase("P1")
phase1:addSignalGroup(sgLane1StraightRight, sgLane4Straight, sgTramNorthSouth, sgPedEast)

phase2 = crossing:newPhase("P2")
phase2:addSignalGroup(sgLane2Right, sgLane3Left, sgLane4Straight)

phase3 = crossing:newPhase("P3")
phase3:addSignalGroup(sgEastVehicle, sgLane2Left, sgPedNorthSouth)
