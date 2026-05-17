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
-- local TrafficPhase = require("ce.mods.road.TrafficPhase")
-- local LaneSettings = require("ce.mods.road.LaneSettings")
local TrafficLight = require("ce.mods.road.TrafficLight")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

-- Ampeln für den Kraftfahrverkehr (K) und Strassenbahnen (S)
local K1, K2
-- Phasen
local phase1, phase2
-- die Kreuzung
local crossing

-- Nutze einen Speicherslot in EEP um die Einstellungen für Kreuzungen zu laden und zu speichern
crossingCeModule.loadSettingsFromSlot(10)

-- Erzeuge immer erst Deine Ampeln
K1 = TrafficLight:new("K1", 23, TrafficLightModel.JS2_3er_mit_FG) -- NORTH STRAIGHT 1 (right)
K2 = TrafficLight:new("K2", 24, TrafficLightModel.JS2_3er_mit_FG) -- NORTH STRAIGHT 2 (left)

-- Erzeuge Kreuzung und Fahrspuren
crossing = Intersection:new("Dein Kreuzungsname")
lane1 = Lane:new("Lane 1 N", K1, { Lane.Directions.STRAIGHT, Lane.Directions.RIGHT })
lane2 = Lane:new("Lane 2 S", K2, { Lane.Directions.STRAIGHT, Lane.Directions.RIGHT })

-- Lege Signalgruppen und Phasen an
local sgK1Vehicle = crossing:newSignalGroup("sgK1Vehicle"):addVehicleSignals(K1)
local sgK2Vehicle = crossing:newSignalGroup("sgK2Vehicle"):addVehicleSignals(K2)
local sgK1Pedestrian = crossing:newSignalGroup("sgK1Pedestrian"):addPedestrianSignals(K1)
local sgK2Pedestrian = crossing:newSignalGroup("sgK2Pedestrian"):addPedestrianSignals(K2)

phase1 = crossing:newPhase("P1")
phase1:addSignalGroup(sgK1Vehicle, sgK2Pedestrian)

phase2 = crossing:newPhase("P2")
phase2:addSignalGroup(sgK2Vehicle, sgK1Pedestrian)
