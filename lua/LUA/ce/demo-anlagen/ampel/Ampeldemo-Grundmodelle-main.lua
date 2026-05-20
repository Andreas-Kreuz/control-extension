--------------------------------
-- Lade Funktionen fuer Ampeln
--------------------------------
-- Planer
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
local TrafficLight = require("ce.mods.road.TrafficLight")
local Lane = require("ce.mods.road.Lane")
local Intersection = require("ce.mods.road.Intersection")
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
IntersectionSettings.loadSettingsFromSlot(100)

------------------------------------------------
-- Damit kommt wird die Variable "Zugname" automatisch durch EEP belegt
-- http://emaps-eep.de/lua/code-schnipsel
------------------------------------------------
-- require("ce.third-party.BetterContacts_BH2")
setmetatable(_ENV, {
    __index = function (_, k)
        local p = load(k);
        if p then
            local f = function (z)
                local s = Zugname
                Zugname = z;
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
    -- print("[#Anlage] " .. lane.name .. " betreten durch: " .. Zugname)
    lane:vehicleEntered(Zugname)
end

function leaveLane(Zugname, lane)
    assert(lane, "lane darf nicht nil sein. Richtige Lua-Funktion im Kontaktpunkt?")
    -- print("[#Anlage] " .. lane.name .. " verlassen von: " .. Zugname)
    lane:vehicleLeft(Zugname)
end

----------------------------------------------------------------------------------------------------------------------
-- Definiere eigene Ampel-Modelle - hier Ampel 3 aus dem Grundbestand
-- Fuer die Signalstellung siehe Auswahlbox unter "Auswahl des Signalbegriffs"
-- bei Rechtsklick auf das Signal im 2D Editor
----------------------------------------------------------------------------------------------------------------------
Grundmodell_Ampel_3 = TrafficLightModel:new("Grundmodell Ampel 3",       -- Name des Modells
                                            2,                           -- Signalstellung fuer rot   (2. Stellung)
                                            1,                           -- Signalstellung fuer gruen (1. Stellung)
                                            3)                           -- Signalstellung fuer gelb  (3. Stellung)

Grundmodell_Ampel_3_FG = TrafficLightModel:new("Grundmodell Ampel 3 FG", -- Name des Modells
                                               2,                        -- Signalstellung fuer rot   (2. Stellung)
                                               2,                        -- Signalstellung fuer rot   (2. Stellung)
                                               2,                        -- Signalstellung fuer rot   (2. Stellung)
                                               2,                        -- Signalstellung fuer rot   (2. Stellung)
                                               1)                        -- Signalstellung fuer gruen (1. Stellung)

-- Zeige die Signal-IDs aller Ampeln an
-- for i = 1, 1000 do
--    EEPShowInfoSignal(i, true)
--    EEPChangeInfoSignal(i, "Signal " .. i)
-- end

-- region K2-Fahrspuren
do
    --    +---------------------------------- Variablenname der Ampel
    --    |    +----------------------------- Legt eine neue Ampel an
    --    |    |                      +------ Signal-ID dieser Ampel
    --    |    |                      |   +-- Modell dieser Ampel - weiss wo rot, gelb und gruen ist
    local K1 = TrafficLight:new("K1", 32, Grundmodell_Ampel_3)
    local K2 = TrafficLight:new("K2", 31, Grundmodell_Ampel_3)
    local K3 = TrafficLight:new("K3", 34, Grundmodell_Ampel_3)
    local K4 = TrafficLight:new("K4", 33, Grundmodell_Ampel_3)
    local K5 = TrafficLight:new("K5", 30, Grundmodell_Ampel_3)
    -------------------------------------------------------------------------------------------------------------------
    -- Definiere alle Fahrspuren fuer Kreuzung 2
    -------------------------------------------------------------------------------------------------------------------

    --        +------------------------------------------------------ Neue Fahrspur
    --        |              +--------------------------------------- Name der Fahrspur
    --        |              |            +------------------------- Speicher ID - um die Anzahl der Fahrzeuge
    --        |              |            |                                        und die Wartezeit zu speichern
    --        |              |            |    +-------------------- Ampel (Variablenname von oben)
    c2Lane1 = Lane:new("Fahrspur 1 - K2", K1, { "RIGHT" })
    c2Lane2 = Lane:new("Fahrspur 2 - K2", K2, { "STRAIGHT" })
    c2Lane3 = Lane:new("Fahrspur 3 - K2", K3, { "STRAIGHT" })
    c2Lane4 = Lane:new("Fahrspur 4 - K2", K4, { "LEFT" })
    c2Lane5 = Lane:new("Fahrspur 5 - K2", K5, { "LEFT", "RIGHT" })

    -- region K2-Phasen
    -------------------------------------------------------------------------------------------------------------------
    -- Definiere alle Phasen fuer Kreuzung 2
    -------------------------------------------------------------------------------------------------------------------
    -- Eine Phase bestimmt, welche Fahrspuren gleichzeitig auf grün geschaltet werden dürfen, alle anderen sind rot

    c2 = Intersection:new("Kreuzung 2")
    local sgLane1Right = c2:newSignalGroup("sgLane1Right"):addVehicleSignals(K1)
    local sgLane2Straight = c2:newSignalGroup("sgLane2Straight"):addVehicleSignals(K2)
    local sgLane3Straight = c2:newSignalGroup("sgLane3Straight"):addVehicleSignals(K3)
    local sgLane4Left = c2:newSignalGroup("sgLane4Left"):addVehicleSignals(K4)
    local sgLane5LeftRight = c2:newSignalGroup("sgLane5LeftRight"):addVehicleSignals(K5)

    --- Kreuzung 2: Phase 1
    local c2Phase1 = c2:newPhase("P1")
    c2Phase1:addSignalGroup(sgLane1Right, sgLane2Straight, sgLane3Straight)

    --- Kreuzung 2: Phase 2
    local c2Phase2 = c2:newPhase("P2")
    c2Phase2:addSignalGroup(sgLane1Right, sgLane2Straight)

    --- Kreuzung 2: Phase 3
    local c2Phase3 = c2:newPhase("P3")
    c2Phase3:addSignalGroup(sgLane3Straight, sgLane4Left)

    --- Kreuzung 2: Phase 4
    local c2Phase4 = c2:newPhase("P4")
    c2Phase4:addSignalGroup(sgLane5LeftRight)
    c2:addStaticCam("Kreuzung 2")
    c2:setTippStructure("#18")
end
-- endregion

-- region K1-Fahrspuren
do
    --    +---------------------------------- Variablenname der Ampel
    --    |    +----------------------------- Legt eine neue Ampel an
    --    |    |                      +------ Signal-ID dieser Ampel
    --    |    |                      |   +-- Modell dieser Ampel - weiss wo rot, gelb und gruen ist
    local K1 = TrafficLight:new("K1", 17, Grundmodell_Ampel_3)
    local K2 = TrafficLight:new("K2", 13, Grundmodell_Ampel_3)
    local K3 = TrafficLight:new("K3", 12, Grundmodell_Ampel_3)
    local K4 = TrafficLight:new("K4", 11, Grundmodell_Ampel_3)
    local K5 = TrafficLight:new("K5", 10, Grundmodell_Ampel_3)
    local K6 = TrafficLight:new("K6", 09, Grundmodell_Ampel_3)
    local K7 = TrafficLight:new("K7", 16, Grundmodell_Ampel_3)
    local K8 = TrafficLight:new("K8", 15, Grundmodell_Ampel_3)
    -------------------------------------------------------------------------------------------------------------------
    -- Definiere alle Fahrspuren fuer Kreuzung 1
    -------------------------------------------------------------------------------------------------------------------

    --        +----------------------------------------------------- Neue Fahrspur
    --        |        +-------------------------------------------- Name der Fahrspur
    --        |        |                  +------------------------- Speicher ID - um die Anzahl der Fahrzeuge
    --        |        |                  |                                        und die Wartezeit zu speichern
    --        |        |                  |    +-------------------- Ampel (Variablenname von oben)
    c1Lane1 = Lane:new("Fahrspur 1 - K1", K1, { "STRAIGHT", "RIGHT" })
    c1Lane2 = Lane:new("Fahrspur 2 - K1", K2, { "LEFT" })
    c1Lane3 = Lane:new("Fahrspur 3 - K1", K3, { "STRAIGHT", "RIGHT" })
    c1Lane4 = Lane:new("Fahrspur 4 - K1", K4, { "LEFT" })
    c1Lane5 = Lane:new("Fahrspur 5 - K1", K5, { "STRAIGHT", "RIGHT" })
    c1Lane6 = Lane:new("Fahrspur 6 - K1", K6, { "LEFT" })
    c1Lane7 = Lane:new("Fahrspur 7 - K1", K7, { "STRAIGHT", "RIGHT" })
    c1Lane8 = Lane:new("Fahrspur 8 - K1", K8, { "LEFT" })

    local F1 = TrafficLight:newPedestrianOnly("F1", 40, Grundmodell_Ampel_3_FG)
    local F2 = TrafficLight:newPedestrianOnly("F2", 41, Grundmodell_Ampel_3_FG)
    local F3 = TrafficLight:newPedestrianOnly("F3", 36, Grundmodell_Ampel_3_FG)
    local F4 = TrafficLight:newPedestrianOnly("F4", 37, Grundmodell_Ampel_3_FG)
    local F5 = TrafficLight:newPedestrianOnly("F5", 38, Grundmodell_Ampel_3_FG)
    local F6 = TrafficLight:newPedestrianOnly("F6", 39, Grundmodell_Ampel_3_FG)
    local F7 = TrafficLight:newPedestrianOnly("F7", 42, Grundmodell_Ampel_3_FG)
    local F8 = TrafficLight:newPedestrianOnly("F8", 43, Grundmodell_Ampel_3_FG)

    -- endregion
    -- region K1-Phasen
    -------------------------------------------------------------------------------------------------------------------
    -- Definiere alle Phasen fuer Kreuzung 1
    -------------------------------------------------------------------------------------------------------------------
    -- Eine Phase bestimmt, welche Fahrspuren gleichzeitig auf grün geschaltet werden dürfen, alle anderen sind rot

    c1 = Intersection:new("Kreuzung 1")
    local sgLane1StraightRight = c1:newSignalGroup("sgLane1StraightRight"):addVehicleSignals(K1)
    local sgLane2Left = c1:newSignalGroup("sgLane2Left"):addVehicleSignals(K2)
    local sgLane3StraightRight = c1:newSignalGroup("sgLane3StraightRight"):addVehicleSignals(K3)
    local sgLane4Left = c1:newSignalGroup("sgLane4Left"):addVehicleSignals(K4)
    local sgLane5StraightRight = c1:newSignalGroup("sgLane5StraightRight"):addVehicleSignals(K5)
    local sgLane6Left = c1:newSignalGroup("sgLane6Left"):addVehicleSignals(K6)
    local sgLane7StraightRight = c1:newSignalGroup("sgLane7StraightRight"):addVehicleSignals(K7)
    local sgLane8Left = c1:newSignalGroup("sgLane8Left"):addVehicleSignals(K8)
    local sgPedPhase1 = c1:newSignalGroup("sgPedPhase1"):addPedestrianSignals(F1, F2, F3, F4, F5, F6, F7, F8)

    --- Kreuzung 1: Phase 1
    local c1Phase1 = c1:newPhase("P1")
    c1Phase1:addSignalGroup(sgLane1StraightRight, sgLane5StraightRight, sgPedPhase1)

    --- Kreuzung 1: Phase 2
    local c1Phase2 = c1:newPhase("P2")
    c1Phase2:addSignalGroup(sgLane2Left, sgLane6Left)

    --- Kreuzung 1: Phase 3
    local c1Phase3 = c1:newPhase("P3")
    c1Phase3:addSignalGroup(sgLane3StraightRight, sgLane7StraightRight)

    --- Kreuzung 1: Phase 4
    local c1Phase4 = c1:newPhase("P4")
    c1Phase4:addSignalGroup(sgLane4Left, sgLane8Left)
    c1:addStaticCam("Kreuzung 1")
    c1:setTippStructure("#17")
end
-- endregion

local ControlExtension = require("ce.ControlExtension")
local crossingCeModule = require("ce.mods.road.CeRoadModule")
ControlExtension.addModules(crossingCeModule).setOptions({
    anl3path = "Resourcen/Anlagen/ce/Control_Extension-Demo-Ampel/Control_Extension-Demoanlage-Ampel-Grundmodelle.anl3",
})

function EEPMain()
    -- print("[#Anlage] Speicher: " .. collectgarbage("count"))
    ControlExtension.runTasks(1)
    return 1
end
