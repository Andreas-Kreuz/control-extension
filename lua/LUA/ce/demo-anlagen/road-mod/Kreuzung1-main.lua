clearlog()
local Lane = require("ce.mods.road.Lane")
local PedestrianCrossing = require("ce.mods.road.PedestrianCrossing")
local Intersection = require("ce.mods.road.Intersection")
local TrafficLight = require("ce.mods.road.TrafficLight")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

Intersection.debug = false

-- START Kreuzung c1 (c1)
do
    -- Kreuzung
    local c1 = Intersection:new("c1")
        :setScriptVariableName("c1")
        :setTippStructure("#60_1Spur_Fahrradständer2_AS3")
        :withStorage(2)
        :addStaticCams("Kreuzung aus Westen")

    -- Ampeln
    local c1K1 = TrafficLight:newForSignal("K1", 16, TrafficLightModel.JS2_3er_mit_FG)
    local c1K2 = TrafficLight:newForSignal("K2", 18, TrafficLightModel.JS2_3er_ohne_FG)
    local c1K3 = TrafficLight:newForSignal("K3", 11, TrafficLightModel.JS2_3er_mit_FG)
    local c1K5 = TrafficLight:newForSignal("K5", 16, TrafficLightModel.JS2_3er_mit_FG)

    -- Fussg.-Ampeln
    local c1F1 = TrafficLight:newForSignal("F1", 11, TrafficLightModel.JS2_3er_mit_FG)
    local c1K4 = TrafficLight:newForSignal("K4", 17, TrafficLightModel.JS2_3er_ohne_FG)

    -- Fahrspur-Ampeln
    local c1Lane1Signal = TrafficLight:newForSignal("lane1Sig", 12, TrafficLightModel.Unsichtbar_2er)
    local c1Lane2Signal = TrafficLight:newForSignal("lane2Sig", 13, TrafficLightModel.Unsichtbar_2er)

    -- Fahrspuren
    c1Lane1 = c1:newLane("FS1", c1Lane1Signal)
        :setScriptVariableName("c1Lane1")
    c1Lane2 = c1:newLane("FS2", c1Lane2Signal)
        :setScriptVariableName("c1Lane2")

    -- Fussgaengerfurten
    local c1PedWest = c1:newPedestrianCrossing("sgWestPed")
        :setScriptVariableName("c1PedWest")
        :setApproach(PedestrianCrossing.Approach.WEST)

    -- Ampelgruppen
    local c1SgWestCarStraight = c1
        :newSignalGroup("sgWestCarStraight")
        :setScriptVariableName("c1SgWestCarStraight")
        :setApproach(Lane.Approach.WEST)
        :setTurnDirections(Lane.Directions.STRAIGHT)
        :addVehicleSignals(c1K1, c1K2)
    local c1SgWestCarLeft = c1
        :newSignalGroup("sgWestCarLeft")
        :setScriptVariableName("c1SgWestCarLeft")
        :setApproach(Lane.Approach.WEST)
        :setTurnDirections(Lane.Directions.LEFT)
        :addVehicleSignals(c1K3)
    local c1SgWestPed = c1
        :newSignalGroup("sgWestPed")
        :setScriptVariableName("c1SgWestPed")
        :setApproach(Lane.Approach.WEST)
        :addPedestrianCrossings(c1PedWest)
        :addPedestrianSignals(c1F1)

    -- Zuordnung der Ampelgruppen zu Fahrspuren
    c1Lane1:driveOnDefaultSignalGroups(c1SgWestCarStraight)
    c1Lane2:driveOnDefaultSignalGroups(c1SgWestCarLeft)

    -- Verkehrsphasen
    c1:newPhase("P1")
        :addSignalGroups(
            c1SgWestCarLeft,
            c1SgWestCarStraight
        )
    c1:newPhase("P2")
        :addSignalGroups(c1SgWestPed)
end
-- END Kreuzung c1 (c1)

--------------------------------
-- Lade Funktionen fuer Ampeln
--------------------------------
local BetterContacts = require("ce.third-party.BetterContacts_BH2")
BetterContacts.setOptions({
    varname = "Zugname",
    varnameTrackID = "trackId"
})

--------------------------------------------
-- Definiere Funktionen fuer Kontaktpunkte
--------------------------------------------
function enterLane(Zugname, lane)
    if not lane then return end
    assert(lane, "lane darf nicht nil sein. Richtige Lua-Funktion im Kontaktpunkt?")
    lane:vehicleEntered(Zugname)
end

function leaveLane(Zugname, lane)
    if not lane then return end
    assert(lane, "lane darf nicht nil sein. Richtige Lua-Funktion im Kontaktpunkt?")
    lane:vehicleLeft(Zugname)
end

local ControlExtension = require("ce.ControlExtension")
    .setOptions({ anl3path = "Resourcen\\Anlagen\\ce\\road-mod\\Kreuzung1.anl3", })
    .addModules(require("ce.mods.road.CeRoadModule"))

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
