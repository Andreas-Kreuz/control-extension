clearlog()
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
local TrafficLight = require("ce.mods.road.TrafficLight")
local Lane = require("ce.mods.road.Lane")
local Intersection = require("ce.mods.road.Intersection")
-- local TrafficPhase = require("ce.mods.road.TrafficPhase")

Intersection.debug = true

------------------------------------------------
-- Damit kommt wird die Variable "Zugname" automatisch durch EEP belegt
-- http://emaps-eep.de/lua/code-schnipsel
------------------------------------------------
setmetatable(_ENV, {
    __index = function (_, k)
        local p = load(k)
        if p then
            local f = function (z)
                local s = Zugname
                Zugname = z
                p()
                Zugname = s
            end
            _ENV[k] = f
            return f
        end
        return nil
    end
})

--------------------------------------------
-- Definiere Funktionen fuer Kontaktpunkte
--------------------------------------------
function enterLane(Zugname, lane)
    assert(lane, "lane darf nicht nil sein. Richtige Lua-Funktion im Kontaktpunkt?")
    lane:vehicleEntered(Zugname)
end

function leaveLane(Zugname, lane)
    assert(lane, "lane darf nicht nil sein. Richtige Lua-Funktion im Kontaktpunkt?")
    lane:vehicleLeft(Zugname)
end

-------------------------------------------------------------------------------
-- Definiere die Fahrspuren fuer die Kreuzung
-------------------------------------------------------------------------------

--    +---------------------------- Variablenname der Ampel
--    |    +----------------------- Legt eine neue Ampel an
--    |    |                +------ Signal-ID dieser Ampel
--    |    |                |   +-- Modell dieser Ampel - weiss wo rot, gelb und gruen / Fussgaenger ist
local K1 = TrafficLight:new("K1", 07, TrafficLightModel.JS2_3er_mit_FG)
-- Ampel K1 ist gleichzeitig eine Fußgängerampel
local K2 = TrafficLight:new("K2", 08, TrafficLightModel.JS2_3er_mit_FG)
local K3 = TrafficLight:new("K3", 09, TrafficLightModel.JS2_3er_mit_FG)
local K4 = TrafficLight:new("K4", 10, TrafficLightModel.JS2_3er_mit_FG)
local K5 = TrafficLight:new("K5", 12, TrafficLightModel.JS2_3er_mit_FG)
local K6 = TrafficLight:new("K6", 13, TrafficLightModel.JS2_3er_ohne_FG) -- dies ist keine Fußgängerampel
local K7 = TrafficLight:new("K7", 11, TrafficLightModel.JS2_3er_mit_FG)

-- Ampeln für die Straßenbahn nutzen die Lichtfunktion der einzelnen Immobilien
local S1 = TrafficLight:new("S1", 14, TrafficLightModel.Unsichtbar_2er,
                            "#29_Straba Signal Halt",      -- rot
                            "#28_Straba Signal geradeaus", --  gruen
                            "#27_Straba Signal anhalten",  --   gelb
                            "#26_Straba Signal A")         --    Anforderung
local S2 = TrafficLight:new("S2", 15, TrafficLightModel.Unsichtbar_2er,
                            "#32_Straba Signal Halt",      --       rot
                            "#30_Straba Signal geradeaus", --  gruen
                            "#31_Straba Signal anhalten",  --   gelb
                            "#33_Straba Signal A")         --    Anforderung

local F1 = K1:withPedestrian("F1")
local F2 = K2:withPedestrian("F2")
local F3 = K3:withPedestrian("F3")
local F4 = K4:withPedestrian("F4")
local F5 = K5:withPedestrian("F5")
local F6 = K7:withPedestrian("F6")

--   +-----------------------------------------Neue Fahrspur
--   |        +------------------------------- Name der Fahrspur
--   |        |   +------------------------- Speicher ID - um die Anzahl der Fahrzeuge
--   |        |   |                                        und die Wartezeit zu speichern
--   |        |   |    +------------------ neue Ampel für diese Fahrspur
--   |        |   |    |           +------ Signal-ID dieser Ampel
--   |        |   |    |           |   +-- Modell kann rot, gelb, gruen und FG schalten
-- Die Fahrspur N wird durch die Fahrspur-Ampel K1 (Signal ID 07) gesteuert
-- K2 muss später gleichzeitig leuchten (Signal ID 08)
n = Lane:new("N", 100, K1)

-- Die Fahrspur O1 wird durch die Fahrspur-Ampel K2 (Signal 09) gesteuert
-- K4 muss später gleichzeitig leuchten (Signal ID 10)
o1 = Lane:new("O1", 102, K3)

-- Fahrspuren im Westen
-- Die Fahrspur W1 wird durch die Fahrspur-Ampel K5 (Signal 12) gesteuert
w1 = Lane:new("W1", 104, K5)

-- Die Fahrspur W2 wird durch die Fahrspur-Ampel K6 (Signal 13) gesteuert
-- K7 muss später gleichzeitig leuchten (Signal ID 11)
w2 = Lane:new("W2", 105, K6)

-- Fahrspuren fuer Strassenbahnen:
os = Lane:new("OS", 107, S1)
-- requests are shown after signal groups are configured
os:useSignalForQueue() -- Erfasst Anforderungen, wenn ein Fahrzeug an Signal 14 steht

ws = Lane:new("WS", 108, S2)
-- requests are shown after signal groups are configured
ws:useTrackForQueue(2) -- Erfasst Anforderungen, wenn ein Fahrzeug auf Strasse 2 steht

--------------------------------------------------------------
-- Definiere die Phasen und die Kreuzung
--------------------------------------------------------------
-- Eine Phase bestimmt, welche Fahrspuren gleichzeitig auf
-- grün geschaltet werden dürfen, alle anderen sind rot

k1 = Intersection:new("Tutorial 2")
local sgLaneNorth = k1:newSignalGroup("sgLaneNorth"):addVehicleSignals(K1, K2)
local sgLaneEast = k1:newSignalGroup("sgLaneEast"):addVehicleSignals(K3, K4)
local sgLaneWest1 = k1:newSignalGroup("sgLaneWest1"):addVehicleSignals(K5)
local sgLaneWest2 = k1:newSignalGroup("sgLaneWest2"):addVehicleSignals(K6, K7)
local sgTramEastWest = k1:newSignalGroup("sgTramEastWest"):addTramSignals(S1)
local sgTramWestEast = k1:newSignalGroup("sgTramWestEast"):addTramSignals(S2)
local sgPedNorth = k1:newSignalGroup("sgPedNorth"):addPedestrianSignals(F1, F2)
local sgPedEast = k1:newSignalGroup("sgPedEast"):addPedestrianSignals(F3, F4)
local sgPedWest = k1:newSignalGroup("sgPedWest"):addPedestrianSignals(F5, F6)
os:showRequestsOnSignalGroups(sgTramEastWest)
ws:showRequestsOnSignalGroups(sgTramWestEast)

--- Tutorial 2: Phase 1
local phase1 = k1:newPhase("P1")
phase1:addSignalGroup(sgLaneEast, sgLaneWest1, sgTramEastWest, sgTramWestEast, sgPedNorth)

--- Tutorial 2: Phase 2
local phase2 = k1:newPhase("P2")
phase2:addSignalGroup(sgLaneWest2, sgPedEast)

--- Tutorial 2: Phase 3
local phase3 = k1:newPhase("P3")
phase3:addSignalGroup(sgLaneNorth, sgPedEast, sgPedWest)

-- Die Kreuzung soll die Phasen einfach nur in Ihrer Reihenfolge schalten
k1:setSwitchInStrictOrder(true)

local ControlExtension = require("ce.ControlExtension")
ControlExtension.addModules(
    require("ce.mods.road.CeRoadModule")
)

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
