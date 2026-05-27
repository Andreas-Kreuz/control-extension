clearlog()
local Lane = require("ce.mods.road.Lane")
local PedestrianCrossing = require("ce.mods.road.PedestrianCrossing")
local Intersection = require("ce.mods.road.Intersection")
local TrafficLight = require("ce.mods.road.TrafficLight")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

Intersection.debug = false

-- START Kreuzung c1 (Kreuzung 1 mit JS2 Ampeln)
do
    -- Kreuzung
    local c1 = Intersection:new("Kreuzung 1 mit JS2 Ampeln")
        :setScriptVariableName("c1")
        :setTippStructure("#60_1Spur_Fahrradständer2_AS3")
        :withStorage(1)
        :addStaticCams("Kreuzung aus Westen")

    -- Ampeln
    local c1K1 = TrafficLight:newForSignal("K1", 20, TrafficLightModel.JS2_3er_mit_FG)
    local c1K2 = TrafficLight:newForSignal("K2", 8, TrafficLightModel.JS2_3er_mit_FG)
    local c1K3 = TrafficLight:newForSignal("K3", 19, TrafficLightModel.JS2_3er_mit_FG)
    local c1K4 = TrafficLight:newForSignal("K4", 10, TrafficLightModel.JS2_3er_mit_FG)
    local c1K5 = TrafficLight:newForSignal("K5", 16, TrafficLightModel.JS2_3er_mit_FG)
    local c1K6 = TrafficLight:newForSignal("K6", 18, TrafficLightModel.JS2_3er_ohne_FG)
    local c1K7 = TrafficLight:newForSignal("K7", 17, TrafficLightModel.JS2_3er_ohne_FG)
    local c1K8 = TrafficLight:newForSignal("K8", 11, TrafficLightModel.JS2_3er_mit_FG)
    local c1S1 = TrafficLight:newForLightStructure("S1",
                                                   "#32_Straba Signal Halt",
                                                   "#30_Straba Signal geradeaus",
                                                   "#31_Straba Signal anhalten",
                                                   "#33_Straba Signal A",
                                                   "#34_Straba Signal Gehäuse 4",
                                                   nil
    )
    local c1S2 = TrafficLight:newForLightStructure("S2",
                                                   "#29_Straba Signal Halt",
                                                   "#28_Straba Signal geradeaus",
                                                   "#27_Straba Signal anhalten",
                                                   "#26_Straba Signal A",
                                                   "#25_Straba Signal Gehäuse 4",
                                                   nil
    )
    local c1S3 = TrafficLight:newForLightStructure("S3",
                                                   "#58_Straba Signal Halt",
                                                   "#57_Straba Signal geradeaus",
                                                   "#56_Straba Signal anhalten",
                                                   "#59_Straba Signal A",
                                                   "#61_Straba Signal Gehäuse Mast links 4",
                                                   nil
    )

    -- Fussg.-Ampeln
    local c1F1 = c1K1:withPedestrian("F1")
    local c1F2 = c1K2:withPedestrian("F2")
    local c1F3 = c1K3:withPedestrian("F3")
    local c1F4 = c1K4:withPedestrian("F4")
    local c1F5 = c1K5:withPedestrian("F5")
    local c1F6 = c1K8:withPedestrian("F6")

    -- Fahrspur-Ampeln
    local c1Lane1Signal = TrafficLight:newForSignal("lane1Sig", 7, TrafficLightModel.Unsichtbar_2er)
    local c1Lane2Signal = TrafficLight:newForSignal("lane2Sig", 9, TrafficLightModel.Unsichtbar_2er)
    local c1Lane3Signal = TrafficLight:newForSignal("lane3Sig", 15, TrafficLightModel.Unsichtbar_2er)
    local c1Lane4Signal = TrafficLight:newForSignal("lane4Sig", 12, TrafficLightModel.Unsichtbar_2er)
    local c1Lane5Signal = TrafficLight:newForSignal("lane5Sig", 13, TrafficLightModel.Unsichtbar_2er)
    local c1Lane6Signal = TrafficLight:newForSignal("lane6Sig", 14, TrafficLightModel.Unsichtbar_2er)

    -- Fahrspuren
    c1Lane1 = c1:newLane("FS1", c1Lane1Signal)
        :setKpId("c1Lane1")
    c1Lane2 = c1:newLane("FS2", c1Lane2Signal)
        :setKpId("c1Lane2")
    c1Lane3 = c1:newLane("FS3", c1Lane3Signal)
        :setKpId("c1Lane3")
        :setTrafficType(Lane.Type.TRAM)
    c1Lane4 = c1:newLane("FS4", c1Lane4Signal)
        :setKpId("c1Lane4")
    c1Lane5 = c1:newLane("FS5", c1Lane5Signal)
        :setKpId("c1Lane5")
    c1Lane6 = c1:newLane("FS6", c1Lane6Signal)
        :setKpId("c1Lane6")
        :setTrafficType(Lane.Type.TRAM)

    -- Fussgaengerfurten
    local c1PedNorth = c1:newPedestrianCrossing("sgNorthPed")
        :setScriptVariableName("c1PedNorth")
        :setApproach(PedestrianCrossing.Approach.NORTH)
    local c1PedEast = c1:newPedestrianCrossing("sgEastPed")
        :setScriptVariableName("c1PedEast")
        :setApproach(PedestrianCrossing.Approach.EAST)
    local c1PedWest = c1:newPedestrianCrossing("sgWestPed")
        :setScriptVariableName("c1PedWest")
        :setApproach(PedestrianCrossing.Approach.WEST)

    -- Ampelgruppen
    local c1SgNorthCarLeftRight = c1
        :newSignalGroup("sgNorthCarLeftRight")
        :setScriptVariableName("c1SgNorthCarLeftRight")
        :setApproach(Lane.Approach.NORTH)
        :setTurnDirections(Lane.Directions.LEFT, Lane.Directions.RIGHT)
        :addVehicleSignals(c1K1, c1K2)
    local c1SgNorthPed = c1
        :newSignalGroup("sgNorthPed")
        :setScriptVariableName("c1SgNorthPed")
        :setApproach(Lane.Approach.NORTH)
        :addPedestrianCrossings(c1PedNorth)
        :addPedestrianSignals(c1F1, c1F2)
    local c1SgEastCarStraightRight = c1
        :newSignalGroup("sgEastCarStraightRight")
        :setScriptVariableName("c1SgEastCarStraightRight")
        :setApproach(Lane.Approach.EAST)
        :setTurnDirections(Lane.Directions.STRAIGHT, Lane.Directions.RIGHT)
        :addVehicleSignals(c1K3, c1K4)
    local c1SgEastTramStraight = c1
        :newSignalGroup("sgEastTramStraight")
        :setScriptVariableName("c1SgEastTramStraight")
        :setApproach(Lane.Approach.EAST)
        :setTurnDirections(Lane.Directions.STRAIGHT)
        :addTramSignals(c1S1)
    local c1SgEastPed = c1
        :newSignalGroup("sgEastPed")
        :setScriptVariableName("c1SgEastPed")
        :setApproach(Lane.Approach.EAST)
        :addPedestrianCrossings(c1PedEast)
        :addPedestrianSignals(c1F3, c1F4)
    local c1SgWestCarStraight = c1
        :newSignalGroup("sgWestCarStraight")
        :setScriptVariableName("c1SgWestCarStraight")
        :setApproach(Lane.Approach.WEST)
        :setTurnDirections(Lane.Directions.STRAIGHT)
        :addVehicleSignals(c1K5, c1K6)
    local c1SgWestCarLeft = c1
        :newSignalGroup("sgWestCarLeft")
        :setScriptVariableName("c1SgWestCarLeft")
        :setApproach(Lane.Approach.WEST)
        :setTurnDirections(Lane.Directions.LEFT)
        :addVehicleSignals(c1K7, c1K8)
    local c1SgWestTramStraight = c1
        :newSignalGroup("sgWestTramStraight")
        :setScriptVariableName("c1SgWestTramStraight")
        :setApproach(Lane.Approach.WEST)
        :setTurnDirections(Lane.Directions.STRAIGHT)
        :addTramSignals(c1S2, c1S3)
    local c1SgWestPed = c1
        :newSignalGroup("sgWestPed")
        :setScriptVariableName("c1SgWestPed")
        :setApproach(Lane.Approach.WEST)
        :addPedestrianCrossings(c1PedWest)
        :addPedestrianSignals(c1F5, c1F6)

    -- Zuordnung der Ampelgruppen zu Fahrspuren
    c1Lane1:driveOnDefaultSignalGroups(c1SgNorthCarLeftRight)
    c1Lane2:driveOnDefaultSignalGroups(c1SgEastCarStraightRight)
    c1Lane3:driveOnDefaultSignalGroups(c1SgEastTramStraight)
        :showRequestsOnSignalGroups(c1SgEastTramStraight)
    c1Lane4:driveOnDefaultSignalGroups(c1SgWestCarStraight)
    c1Lane5:driveOnDefaultSignalGroups(c1SgWestCarLeft)
    c1Lane6:driveOnDefaultSignalGroups(c1SgWestTramStraight)
        :showRequestsOnSignalGroups(c1SgWestTramStraight)

    -- Verkehrsphasen
    c1:newPhase("P1")
        :addSignalGroups(
            c1SgNorthCarLeftRight,
            c1SgEastPed,
            c1SgWestPed
        )
    c1:newPhase("P2")
        :addSignalGroups(
            c1SgNorthPed,
            c1SgEastCarStraightRight,
            c1SgEastTramStraight,
            c1SgWestCarStraight,
            c1SgWestTramStraight
        )
    c1:newPhase("P3")
        :addSignalGroups(
            c1SgWestCarLeft,
            c1SgWestCarStraight
        )
end
-- END Kreuzung c1 (Kreuzung 1 mit JS2 Ampeln)

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
function onLaneEntered(trainName, laneKpId)
    local lane = Lane.resolve(laneKpId)
    lane:vehicleEntered(trainName)
end

function onLaneLeft(trainName, laneKpId)
    local lane = Lane.resolve(laneKpId)
    lane:vehicleLeft(trainName)
end

local ControlExtension = require("ce.ControlExtension")
    .setOptions({ anl3path = "Resourcen\\Anlagen\\ce\\road-mod\\Kreuzung1_mit_JS2_Ampeln.anl3", })
    .addModules(require("ce.mods.road.CeRoadModule"))

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
