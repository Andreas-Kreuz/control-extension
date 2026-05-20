insulate("Crossing", function ()
    -- This is the setup
    --                                |    N   |        |        |
    --                                | lane 1 |        |        |
    --                                |        |        |        |
    --                                |STRAIGHT|        |        |
    --                                | +RIGHT |        |        |
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
    --                    K7          |        |        |        |
    --  In lane 2 all cars         K8=|========|========|========|-K9
    --  allowed to turn               |        | LEFT   |STRAIGHT|
    --  right when lane 3             |        |        |        |
    --  is turning left               |        | lane 3 | lane 4 |
    --  (Route: "RIGHT TURN")         |        |   S    |    S   |
    --
    require("ce.hub.eep.EepSimulator")
    local Lane = require("ce.mods.road.Lane")
    local Intersection = require("ce.mods.road.Intersection")
    local TrafficPhase = require("ce.mods.road.TrafficPhase")
    -- local LaneSettings = require("ce.mods.road.LaneSettings")
    local TrafficLight = require("ce.mods.road.TrafficLight")
    local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
    require("ce.hub.util.StorageUtility")
    local L1, L2, L3, L4
    local lane1, lane2, lane3, lane4
    local K1, K2, K3, K5, K6, K7, K8, K9
    local phaseA, phaseB, phaseC
    local crossing

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

    crossing = Intersection:new("My Crossing")
    lane1 = Lane:new("Lane 1 N", L1, { Lane.Directions.STRAIGHT }, Lane.Directions.RIGHT)
    lane2 = Lane:new("Lane 2 E", L2, { Lane.Directions.LEFT }, Lane.Directions.RIGHT)
    lane3 = Lane:new("Lane 3 S", L3, { Lane.Directions.LEFT })
    lane4 = Lane:new("Lane 4 S", L4, { Lane.Directions.STRAIGHT })

    K1:applyToLane(lane1)
    K6:applyToLane(lane2)
    K7:applyToLane(lane2, "TURN RIGHT")
    K8:applyToLane(lane3)
    K9:applyToLane(lane4)

    local sgLane1StraightRight = crossing:newSignalGroup("sgLane1StraightRight"):addVehicleSignals(K1, K2)
    local sgLane2Left = crossing:newSignalGroup("sgLane2Left"):addVehicleSignals(K6)
    local sgLane2Right = crossing:newSignalGroup("sgLane2Right"):addVehicleSignals(K7)
    local sgLane3Left = crossing:newSignalGroup("sgLane3Left"):addVehicleSignals(K8)
    local sgLane4Straight = crossing:newSignalGroup("sgLane4Straight"):addVehicleSignals(K9)
    local sgEastVehicle = crossing:newSignalGroup("sgEastVehicle"):addVehicleSignals(K3, K5)
    local sgPedEast = crossing:newSignalGroup("sgPedEast"):addPedestrianSignals(K3, K6)
    local sgPedNorthSouth = crossing:newSignalGroup("sgPedNorthSouth"):addPedestrianSignals(K1, K2, K8, K9)

    ---@type TrafficPhase
    phaseA = crossing:newPhase("P1")
    phaseA:addSignalGroup(sgLane1StraightRight, sgLane4Straight, sgPedEast)

    phaseB = crossing:newPhase("P2")
    phaseB:addSignalGroup(sgLane2Right, sgLane3Left, sgLane4Straight)

    phaseC = crossing:newPhase("P3")
    phaseC:addSignalGroup(sgEastVehicle, sgLane2Left, sgPedNorthSouth)

    Intersection.initPhases()

    describe("Lane phase NONE -> A", function ()
        local r, g = phaseA:signalHeadsToTurnRedAndGreen()

        it("Red K1 ", function () assert.is_falsy(r[K1]) end)
        it("Red K2 ", function () assert.is_falsy(r[K2]) end)
        it("Red K3 ", function () assert.is_falsy(r[K3]) end)
        it("Red K5 ", function () assert.is_falsy(r[K5]) end)
        it("Red K6 ", function () assert.is_falsy(r[K6]) end)
        it("Red K7 ", function () assert.is_falsy(r[K7]) end)
        it("Red K8 ", function () assert.is_falsy(r[K8]) end)
        it("Red K9 ", function () assert.is_falsy(r[K9]) end)

        it("Green K1 ", function () assert.equals(TrafficPhase.Type.CAR, g[K1]) end)
        it("Green K2 ", function () assert.equals(TrafficPhase.Type.CAR, g[K2]) end)
        it("Green K3 ", function () assert.equals(TrafficPhase.Type.PEDESTRIAN, g[K3]) end)
        it("Green K5 ", function () assert.is_falsy(g[K5]) end)
        it("Green K6 ", function () assert.equals(TrafficPhase.Type.PEDESTRIAN, g[K6]) end)
        it("Green K7 ", function () assert.is_falsy(g[K7]) end)
        it("Green K8 ", function () assert.is_falsy(g[K8]) end)
        it("Green K9 ", function () assert.equals(TrafficPhase.Type.CAR, g[K9]) end)
    end)

    describe("Lane phase NONE -> B", function ()
        local r, g = phaseB:signalHeadsToTurnRedAndGreen()

        it("Red K1 ", function () assert.is_falsy(r[K1]) end)
        it("Red K2 ", function () assert.is_falsy(r[K2]) end)
        it("Red K3 ", function () assert.is_falsy(r[K3]) end)
        it("Red K5 ", function () assert.is_falsy(r[K5]) end)
        it("Red K6 ", function () assert.is_falsy(r[K6]) end)
        it("Red K7 ", function () assert.is_falsy(r[K7]) end)
        it("Red K8 ", function () assert.is_falsy(r[K8]) end)
        it("Red K9 ", function () assert.is_falsy(r[K9]) end)

        it("Green K1 ", function () assert.is_falsy(g[K1]) end)
        it("Green K2 ", function () assert.is_falsy(g[K2]) end)
        it("Green K3 ", function () assert.is_falsy(g[K3]) end)
        it("Green K5 ", function () assert.is_falsy(g[K5]) end)
        it("Green K6 ", function () assert.is_falsy(g[K6]) end)
        it("Green K7 ", function () assert.equals(TrafficPhase.Type.CAR, g[K7]) end)
        it("Green K8 ", function () assert.equals(TrafficPhase.Type.CAR, g[K8]) end)
        it("Green K9 ", function () assert.equals(TrafficPhase.Type.CAR, g[K9]) end)
    end)

    describe("Lane phase NONE -> C", function ()
        local r, g = phaseC:signalHeadsToTurnRedAndGreen()

        it("Red K1 ", function () assert.is_falsy(r[K1]) end)
        it("Red K2 ", function () assert.is_falsy(r[K2]) end)
        it("Red K3 ", function () assert.is_falsy(r[K3]) end)
        it("Red K5 ", function () assert.is_falsy(r[K5]) end)
        it("Red K6 ", function () assert.is_falsy(r[K6]) end)
        it("Red K7 ", function () assert.is_falsy(r[K7]) end)
        it("Red K8 ", function () assert.is_falsy(r[K8]) end)
        it("Red K9 ", function () assert.is_falsy(r[K9]) end)

        it("Green K1 ", function () assert.equals(TrafficPhase.Type.PEDESTRIAN, g[K1]) end)
        it("Green K2 ", function () assert.equals(TrafficPhase.Type.PEDESTRIAN, g[K2]) end)
        it("Green K3 ", function () assert.equals(TrafficPhase.Type.CAR, g[K3]) end)
        it("Green K5 ", function () assert.equals(TrafficPhase.Type.CAR, g[K5]) end)
        it("Green K6 ", function () assert.equals(TrafficPhase.Type.CAR, g[K6]) end)
        it("Green K7 ", function () assert.is_falsy(g[K7]) end)
        it("Green K8 ", function () assert.equals(TrafficPhase.Type.PEDESTRIAN, g[K8]) end)
        it("Green K9 ", function () assert.equals(TrafficPhase.Type.PEDESTRIAN, g[K9]) end)
    end)

    describe("Lane phase A -> B", function ()
        local r, g = phaseB:signalHeadsToTurnRedAndGreen(phaseA)

        it("Red K1 ", function () assert.equals(TrafficPhase.Type.CAR, r[K1]) end)
        it("Red K2 ", function () assert.equals(TrafficPhase.Type.CAR, r[K2]) end)
        it("Red K3 ", function () assert.equals(TrafficPhase.Type.PEDESTRIAN, r[K3]) end)
        it("Red K5 ", function () assert.is_falsy(r[K5]) end)
        it("Red K6 ", function () assert.equals(TrafficPhase.Type.PEDESTRIAN, r[K6]) end)
        it("Red K7 ", function () assert.is_falsy(r[K7]) end)
        it("Red K8 ", function () assert.is_falsy(r[K8]) end)
        it("Red K9 ", function () assert.is_falsy(r[K9]) end)

        it("Green K1 ", function () assert.is_falsy(g[K1]) end)
        it("Green K2 ", function () assert.is_falsy(g[K2]) end)
        it("Green K3 ", function () assert.is_falsy(g[K3]) end)
        it("Green K5 ", function () assert.is_falsy(g[K5]) end)
        it("Green K6 ", function () assert.is_falsy(g[K6]) end)
        it("Green K7 ", function () assert.equals(TrafficPhase.Type.CAR, g[K7]) end)
        it("Green K8 ", function () assert.equals(TrafficPhase.Type.CAR, g[K8]) end)
        it("Green K9 ", function () assert.is_falsy(g[K9]) end)
    end)

    describe("Lane phase A -> A", function ()
        local r, g = phaseA:signalHeadsToTurnRedAndGreen(phaseA)

        it("Red K1 ", function () assert.is_falsy(r[K1]) end)
        it("Red K2 ", function () assert.is_falsy(r[K2]) end)
        it("Red K3 ", function () assert.is_falsy(r[K3]) end)
        it("Red K5 ", function () assert.is_falsy(r[K5]) end)
        it("Red K6 ", function () assert.is_falsy(r[K6]) end)
        it("Red K7 ", function () assert.is_falsy(r[K7]) end)
        it("Red K8 ", function () assert.is_falsy(r[K8]) end)
        it("Red K9 ", function () assert.is_falsy(r[K9]) end)

        it("Green K1 ", function () assert.is_falsy(g[K1]) end)
        it("Green K2 ", function () assert.is_falsy(g[K2]) end)
        it("Green K3 ", function () assert.is_falsy(g[K3]) end)
        it("Green K5 ", function () assert.is_falsy(g[K5]) end)
        it("Green K6 ", function () assert.is_falsy(g[K6]) end)
        it("Green K7 ", function () assert.is_falsy(g[K7]) end)
        it("Green K8 ", function () assert.is_falsy(g[K8]) end)
        it("Green K9 ", function () assert.is_falsy(g[K9]) end)
    end)
    describe("Lane phase B -> B", function ()
        local r, g = phaseB:signalHeadsToTurnRedAndGreen(phaseB)

        it("Red K1 ", function () assert.is_falsy(r[K1]) end)
        it("Red K2 ", function () assert.is_falsy(r[K2]) end)
        it("Red K3 ", function () assert.is_falsy(r[K3]) end)
        it("Red K5 ", function () assert.is_falsy(r[K5]) end)
        it("Red K6 ", function () assert.is_falsy(r[K6]) end)
        it("Red K7 ", function () assert.is_falsy(r[K7]) end)
        it("Red K8 ", function () assert.is_falsy(r[K8]) end)
        it("Red K9 ", function () assert.is_falsy(r[K9]) end)

        it("Green K1 ", function () assert.is_falsy(g[K1]) end)
        it("Green K2 ", function () assert.is_falsy(g[K2]) end)
        it("Green K3 ", function () assert.is_falsy(g[K3]) end)
        it("Green K5 ", function () assert.is_falsy(g[K5]) end)
        it("Green K6 ", function () assert.is_falsy(g[K6]) end)
        it("Green K7 ", function () assert.is_falsy(g[K7]) end)
        it("Green K8 ", function () assert.is_falsy(g[K8]) end)
        it("Green K9 ", function () assert.is_falsy(g[K9]) end)
    end)
    describe("Lane phase C -> C", function ()
        local r, g = phaseC:signalHeadsToTurnRedAndGreen(phaseC)

        it("Red K1 ", function () assert.is_falsy(r[K1]) end)
        it("Red K2 ", function () assert.is_falsy(r[K2]) end)
        it("Red K3 ", function () assert.is_falsy(r[K3]) end)
        it("Red K5 ", function () assert.is_falsy(r[K5]) end)
        it("Red K6 ", function () assert.is_falsy(r[K6]) end)
        it("Red K7 ", function () assert.is_falsy(r[K7]) end)
        it("Red K8 ", function () assert.is_falsy(r[K8]) end)
        it("Red K9 ", function () assert.is_falsy(r[K9]) end)

        it("Green K1 ", function () assert.is_falsy(g[K1]) end)
        it("Green K2 ", function () assert.is_falsy(g[K2]) end)
        it("Green K3 ", function () assert.is_falsy(g[K3]) end)
        it("Green K5 ", function () assert.is_falsy(g[K5]) end)
        it("Green K6 ", function () assert.is_falsy(g[K6]) end)
        it("Green K7 ", function () assert.is_falsy(g[K7]) end)
        it("Green K8 ", function () assert.is_falsy(g[K8]) end)
        it("Green K9 ", function () assert.is_falsy(g[K9]) end)
    end)
end)
