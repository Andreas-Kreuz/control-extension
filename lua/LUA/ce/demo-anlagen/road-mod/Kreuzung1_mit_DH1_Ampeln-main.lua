clearlog()
local Lane = require("ce.mods.road.Lane")
local PedestrianCrossing = require("ce.mods.road.PedestrianCrossing")
local Intersection = require("ce.mods.road.Intersection")
local TrafficLight = require("ce.mods.road.TrafficLight")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

Intersection.debug = false

-- START Kreuzung c1 (Kreuzung mit DH1-Signalen ohne FG)
do
    -- Kreuzung
    local c1 = Intersection:new("Kreuzung mit DH1-Signalen ohne FG", 15)
        :setScriptVariableName("c1")
        :setTippStructure("#60_1Spur_Fahrradständer2_AS3")
        :withStorage(2)
        :addStaticCams("Kreuzung aus Westen")

    -- Ampeln
    local c1K1 = TrafficLight:newForSignal("K1", 16, TrafficLightModel.DH1_3er)
    local c1K2 = TrafficLight:newForSignal("K2", 18, TrafficLightModel.DH1_3er)
    local c1K3 = TrafficLight:newForSignal("K3", 11, TrafficLightModel.DH1_3er)
    local c1K4 = TrafficLight:newForSignal("K4", 17, TrafficLightModel.DH1_3er)
    local c1K5 = TrafficLight:newForSignal("K5", 22, TrafficLightModel.DH1_3er)
    local c1K6 = TrafficLight:newForSignal("K6", 20, TrafficLightModel.DH1_3er)
    local c1K7 = TrafficLight:newForSignal("K7", 8, TrafficLightModel.DH1_3er)
    local c1K8 = TrafficLight:newForSignal("K8", 19, TrafficLightModel.DH1_3er)
    local c1K9 = TrafficLight:newForSignal("K9", 10, TrafficLightModel.DH1_3er)
    local c1S1 = TrafficLight:newForLightStructure("S1",
                                                   "#29_Straba Signal Halt",
                                                   "#28_Straba Signal geradeaus",
                                                   "#27_Straba Signal anhalten",
                                                   "#26_Straba Signal A",
                                                   "#25_Straba Signal Gehäuse 4",
                                                   nil
    )
    local c1S2 = TrafficLight:newForLightStructure("S2",
                                                   "#58_Straba Signal Halt",
                                                   "#57_Straba Signal geradeaus",
                                                   "#56_Straba Signal anhalten",
                                                   "#59_Straba Signal A",
                                                   "#61_Straba Signal Gehäuse Mast links 4",
                                                   nil
    )
    local c1S3 = TrafficLight:newForSignal("S3", 21, TrafficLightModel.MA1_STRAB_3er_2_gruen)
    local c1S4 = TrafficLight:newForLightStructure("S4",
                                                   "#32_Straba Signal Halt",
                                                   "#30_Straba Signal geradeaus",
                                                   "#31_Straba Signal anhalten",
                                                   "#33_Straba Signal A",
                                                   "#34_Straba Signal Gehäuse 4",
                                                   nil
    )

    -- Fahrspur-Ampeln
    local c1Lane1Signal = TrafficLight:newForSignal("FS1Signal", 12, TrafficLightModel.Unsichtbar_2er)
    local c1Lane2Signal = TrafficLight:newForSignal("FS2Signal", 13, TrafficLightModel.Unsichtbar_2er)
    local c1Lane3Signal = TrafficLight:newForSignal("FS3Signal", 14, TrafficLightModel.Unsichtbar_2er)
    local c1Lane4Signal = TrafficLight:newForSignal("FS4Signal", 7, TrafficLightModel.Unsichtbar_2er)
    local c1Lane5Signal = TrafficLight:newForSignal("FS5Signal", 9, TrafficLightModel.Unsichtbar_2er)
    local c1Lane6Signal = TrafficLight:newForSignal("FS6Signal", 15, TrafficLightModel.Unsichtbar_2er)

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
        :addVehicleSignals(c1K3, c1K4)
    local c1SgNorthCarLeftRight = c1
        :newSignalGroup("sgNorthCarLeftRight")
        :setScriptVariableName("c1SgNorthCarLeftRight")
        :setApproach(Lane.Approach.NORTH)
        :setTurnDirections(Lane.Directions.LEFT, Lane.Directions.RIGHT)
        :addVehicleSignals(c1K7, c1K6)
    local c1SgWestTramStraight = c1
        :newSignalGroup("sgWestTramStraight")
        :setScriptVariableName("c1SgWestTramStraight")
        :setApproach(Lane.Approach.WEST)
        :setTurnDirections(Lane.Directions.STRAIGHT)
        :addTramSignals(c1S2, c1S1)
    local c1SgEastCarStraightRight = c1
        :newSignalGroup("sgEastCarStraightRight")
        :setScriptVariableName("c1SgEastCarStraightRight")
        :setApproach(Lane.Approach.EAST)
        :setTurnDirections(Lane.Directions.STRAIGHT, Lane.Directions.RIGHT)
        :addVehicleSignals(c1K8, c1K5, c1K9)
    local c1SgEastTramStraight = c1
        :newSignalGroup("sgEastTramStraight")
        :setScriptVariableName("c1SgEastTramStraight")
        :setApproach(Lane.Approach.EAST)
        :setTurnDirections(Lane.Directions.STRAIGHT)
        :addTramSignals(c1S4, c1S3)

    -- Zuordnung der Ampelgruppen zu Fahrspuren
    c1Lane1:driveOnDefaultSignalGroups(c1SgWestCarStraight)
    c1Lane2:driveOnDefaultSignalGroups(c1SgWestCarLeft)
    c1Lane3:driveOnDefaultSignalGroups(c1SgWestTramStraight)
        :showRequestsOnSignalGroups(c1SgWestTramStraight)
    c1Lane4:driveOnDefaultSignalGroups(c1SgNorthCarLeftRight)
    c1Lane5:driveOnDefaultSignalGroups(c1SgEastCarStraightRight)
    c1Lane6:driveOnDefaultSignalGroups(c1SgEastTramStraight)
        :showRequestsOnSignalGroups(c1SgEastTramStraight)

    -- Verkehrsphasen
    c1:newPhase("P1", 15)
        :addSignalGroups(
            c1SgWestCarLeft,
            c1SgWestCarStraight
        )
    c1:newPhase("P2", 15)
        :addSignalGroups(c1SgNorthCarLeftRight)
    c1:newPhase("P3", 15)
        :addSignalGroups(
            c1SgWestTramStraight,
            c1SgWestCarStraight,
            c1SgEastCarStraightRight,
            c1SgEastTramStraight
        )
end
-- END Kreuzung c1 (Kreuzung mit DH1-Signalen ohne FG)

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
    .setOptions({ anl3path = "Resourcen\\Anlagen\\ce\\road-mod\\Kreuzung1_mit_DH1_Ampeln.anl3", })
    .addModules(require("ce.mods.road.CeRoadModule"))

function EEPMain()
    ControlExtension.runTasks(1)
    return 1
end
