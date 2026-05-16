-- Lua code for testing the lane's functions
describe("Lane ...", function ()
    insulate("Register signals", function ()
        require("ce.hub.eep.EepSimulator")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local SignalIndication = require("ce.mods.road.SignalIndication")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local Lane = require("ce.mods.road.Lane")
        local signalId = 55

        -- Set the route for train "#Car1"
        EEPSetTrainRoute("#Car1", "Some Route")
        -- Signal which is visible to tell the lanes traffic to drive
        local driveSignal = TrafficLight:new("driveSignal", signalId, TrafficLightModel.Unsichtbar_2er)
        -- EEP Signal, which is used to start and stop the lanes traffic (needs to be switched to green too)
        local laneSignal = TrafficLight:new("laneSignal", 11, TrafficLightModel.Unsichtbar_2er)

        local lane = Lane:new("Lane A", 34, laneSignal)
        local tlsBeforeDriveOn = lane.signalsToDriveOn
        it("Lane has signal", function () assert.is_nil(tlsBeforeDriveOn) end)

        driveSignal:applyToLane(lane)

        it("driveSignal has lane", function () assert.is_true(driveSignal.lanes[lane]) end)
        it("lane has driveSignal with route !ALL!",
           function () assert.same({}, lane.signalsToDriveOn[driveSignal]) end)

        it("Lane has signal", function () assert.is_truthy(lane.signalsToDriveOn) end)
        it("Lane has signal", function () assert.are.same({}, lane.signalsToDriveOn[driveSignal]) end)
        describe("Can drive at red", function ()
            driveSignal:switchTo(SignalIndication.RED)
            local canDriveAtRed = laneSignal.currentIndication
            it("SignalId is correct", function ()
                assert.equals(TrafficLightModel.Unsichtbar_2er.signalIndexRed,
                              EEPGetSignal(driveSignal.signalId))
            end)
            it("canDrive()", function () assert.equals(SignalIndication.RED, canDriveAtRed) end)
        end)
        describe("Can drive at green", function ()
            driveSignal:switchTo(SignalIndication.GREEN)
            local canDriveAtGreen = laneSignal.currentIndication
            it("SignalId is correct", function ()
                assert.equals(TrafficLightModel.Unsichtbar_2er.signalIndexGreen,
                              EEPGetSignal(driveSignal.signalId))
            end)
            it("SignalId is correct", function ()
                assert.equals(TrafficLightModel.Unsichtbar_2er.signalIndexGreen,
                              EEPGetSignal(laneSignal.signalId))
            end)
            it("canDrive()", function () assert.equals(SignalIndication.GREEN, canDriveAtGreen) end)
        end)
    end)
    insulate("Can drive on route", function ()
        require("ce.hub.eep.EepSimulator")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local SignalIndication = require("ce.mods.road.SignalIndication")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local Lane = require("ce.mods.road.Lane")

        -- Set the route for train "#Car1"
        EEPSetTrainRoute("#Car1", "Matching Route")
        -- Signal which is visible to tell the lanes traffic to drive
        local K1 = TrafficLight:new("K1", 55, TrafficLightModel.JS2_3er_mit_FG)
        local K2 = TrafficLight:new("K2", 56, TrafficLightModel.JS2_3er_mit_FG)
        K1:switchTo(SignalIndication.RED)
        K2:switchTo(SignalIndication.RED)
        -- EEP Signal, which is used to start and stop the lanes traffic (needs to be switched to green too)
        local laneSignal = TrafficLight:new("laneSignal", 11, TrafficLightModel.Unsichtbar_2er)

        ---@type Lane
        local lane = Lane:new("Lane A", 34, laneSignal)
        local tlsBeforeDriveOn = lane.signalsToDriveOn
        it("Lane has signal", function () assert.is_nil(tlsBeforeDriveOn) end)

        K1:applyToLane(lane)
        K2:applyToLane(lane, "Some other route", "Matching Route", "Another")

        it("Lane has signal", function () assert.is_truthy(lane.signalsToDriveOn) end)
        it("Lane has signal", function () assert.are.same({}, lane.signalsToDriveOn[K1]) end)
        it("Lane has signal", function ()
            assert.are.same({ "Some other route", "Matching Route", "Another" }, lane.signalsToDriveOn[K2])
        end)
        describe("K1 can drive at red", function ()
            K1:switchTo(SignalIndication.RED)
            local canDriveAtRed = laneSignal.currentIndication
            local signalIndexK1 = EEPGetSignal(K1.signalId)
            it("SignalId is correct",
               function () assert.equals(TrafficLightModel.JS2_3er_mit_FG.signalIndexRed, signalIndexK1) end)
            it("canDrive()", function () assert.equals(SignalIndication.RED, canDriveAtRed) end)
            K1:switchTo(SignalIndication.RED)
        end)
        describe("K1 can drive at green", function ()
            K1:switchTo(SignalIndication.GREEN)
            local canDriveAtGreen = laneSignal.currentIndication
            local signalIndexK1 = EEPGetSignal(K1.signalId)
            it("SignalId is correct",
               function () assert.equals(TrafficLightModel.JS2_3er_mit_FG.signalIndexGreen, signalIndexK1) end)
            it("canDrive()", function () assert.equals(SignalIndication.GREEN, canDriveAtGreen) end)
            K1:switchTo(SignalIndication.RED)
        end)
        describe("K2 can drive at green", function ()
            K2:switchTo(SignalIndication.RED)
            local canDriveAtRed = laneSignal.currentIndication
            local signalIndexK2 = EEPGetSignal(K2.signalId)
            it("SignalId is correct",
               function () assert.equals(TrafficLightModel.JS2_3er_mit_FG.signalIndexRed, signalIndexK2) end)
            it("canDrive()", function () assert.equals(SignalIndication.RED, canDriveAtRed) end)
            K2:switchTo(SignalIndication.RED)
        end)
        describe("K2 can drive at green", function ()
            K2:switchTo(SignalIndication.GREEN)
            local signalIndexK2 = EEPGetSignal(K2.signalId)
            it("SignalId is correct",
               function () assert.equals(TrafficLightModel.JS2_3er_mit_FG.signalIndexGreen, signalIndexK2) end)

            local canDriveNoVehicle = laneSignal.currentIndication
            it("canDrive() noVehicle", function () assert.equals(SignalIndication.RED, canDriveNoVehicle) end)

            lane:vehicleEntered("#Car1")
            local firstVehiclesRoute1 = lane.firstVehiclesRoute
            local canDriveAtGreen2 = laneSignal.currentIndication
            it("canDrive() vehicleWithRoute", function ()
                assert.equals("Matching Route", firstVehiclesRoute1)
            end)
            it("canDrive() vehicleWithRoute", function ()
                assert.equals(SignalIndication.GREEN, canDriveAtGreen2)
            end)
            lane:vehicleLeft("#Car1")

            lane:vehicleEntered("#Car2")
            local firstVehiclesRoute2 = lane.firstVehiclesRoute
            local canDriveAtGreen3 = laneSignal.currentIndication
            it("canDrive() vehicleWithRoute", function () assert.equals("Alle", firstVehiclesRoute2) end)
            it("canDrive() vehicleWithRoute", function ()
                assert.equals(SignalIndication.RED, canDriveAtGreen3)
            end)
            lane:vehicleLeft("#Car2")

            K2:switchTo(SignalIndication.RED)
        end)
    end)

    insulate("Lane based route drive signal groups", function ()
        require("ce.hub.eep.EepSimulator")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local SignalGroup = require("ce.mods.road.SignalGroup")
        local Lane = require("ce.mods.road.Lane")

        local defaultSignal = TrafficLight:new("Default", 55, TrafficLightModel.JS2_3er_mit_FG)
        local secondDefaultSignal = TrafficLight:new("Second Default", 58, TrafficLightModel.JS2_3er_mit_FG)
        local exclusiveSignal = TrafficLight:new("Exclusive", 56, TrafficLightModel.JS2_3er_mit_FG)
        local additionalSignal = TrafficLight:new("Additional", 57, TrafficLightModel.JS2_3er_mit_FG)
        local laneSignal = TrafficLight:new("laneSignal", 11, TrafficLightModel.Unsichtbar_2er)
        local lane = Lane:new("Lane A", 34, laneSignal)
        local sgDefault = SignalGroup:new("sgDefault"):addVehicleSignals(defaultSignal, secondDefaultSignal)
        local sgExclusive = SignalGroup:new("sgExclusive"):addVehicleSignals(exclusiveSignal)
        local sgAdditional = SignalGroup:new("sgAdditional"):addVehicleSignals(additionalSignal)

        lane:driveOnDefaultSignalGroups(sgDefault)
        lane:routes("Exclusive Route"):driveOnlyOnSignalGroups(sgExclusive)
        lane:routes("Additional Route"):driveAlsoOnSignalGroups(sgAdditional)

        it("registers the default signal as fallback", function ()
            assert.is_true(lane.defaultDriveSignals[defaultSignal])
            assert.is_true(lane.defaultDriveSignals[secondDefaultSignal])
            assert.are.same({}, lane.signalsToDriveOn[defaultSignal])
            assert.are.same({}, lane.signalsToDriveOn[secondDefaultSignal])
            assert.is_true(defaultSignal.lanes[lane])
            assert.is_true(secondDefaultSignal.lanes[lane])
        end)

        it("allows non-matching routes on the default signal only", function ()
            lane.firstVehiclesRoute = "Other Route"

            assert.is_true(Lane.laneCanDrive(lane, { defaultSignal }))
            assert.is_true(Lane.laneCanDrive(lane, { secondDefaultSignal }))
            assert.is_false(Lane.laneCanDrive(lane, { exclusiveSignal }))
            assert.is_false(Lane.laneCanDrive(lane, { additionalSignal }))
        end)

        it("uses exclusive route signals instead of the default signal", function ()
            lane.firstVehiclesRoute = "Exclusive Route"

            assert.is_false(Lane.laneCanDrive(lane, { defaultSignal }))
            assert.is_false(Lane.laneCanDrive(lane, { secondDefaultSignal }))
            assert.is_true(Lane.laneCanDrive(lane, { exclusiveSignal }))
            assert.is_false(Lane.laneCanDrive(lane, { additionalSignal }))
        end)

        it("allows additional route signals together with the default signal", function ()
            lane.firstVehiclesRoute = "Additional Route"

            assert.is_true(Lane.laneCanDrive(lane, { defaultSignal }))
            assert.is_true(Lane.laneCanDrive(lane, { secondDefaultSignal }))
            assert.is_true(Lane.laneCanDrive(lane, { additionalSignal }))
            assert.is_false(Lane.laneCanDrive(lane, {}))
        end)
    end)

    insulate("Multi-group route drive signals", function ()
        require("ce.hub.eep.EepSimulator")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local SignalGroup = require("ce.mods.road.SignalGroup")
        local Lane = require("ce.mods.road.Lane")

        local defaultSignal = TrafficLight:new("Default", 55, TrafficLightModel.JS2_3er_mit_FG)
        local secondDefaultSignal = TrafficLight:new("Second Default", 56, TrafficLightModel.JS2_3er_mit_FG)
        local exclusiveSignal = TrafficLight:new("Exclusive", 57, TrafficLightModel.JS2_3er_mit_FG)
        local secondExclusiveSignal = TrafficLight:new("Second Exclusive", 58, TrafficLightModel.JS2_3er_mit_FG)
        local additionalSignal = TrafficLight:new("Additional", 59, TrafficLightModel.JS2_3er_mit_FG)
        local secondAdditionalSignal = TrafficLight:new("Second Additional", 60, TrafficLightModel.JS2_3er_mit_FG)
        local laneSignal = TrafficLight:new("laneSignal", 11, TrafficLightModel.Unsichtbar_2er)
        local lane = Lane:new("Lane A", 34, laneSignal)
        local sgDefault = SignalGroup:new("sgDefault"):addVehicleSignals(defaultSignal, secondDefaultSignal)
        local sgExclusive = SignalGroup:new("sgExclusive"):addVehicleSignals(exclusiveSignal, secondExclusiveSignal)
        local sgAdditional = SignalGroup:new("sgAdditional"):addVehicleSignals(additionalSignal, secondAdditionalSignal)

        lane:driveOnDefaultSignalGroups(sgDefault)
        lane:routes("Exclusive Route"):driveOnlyOnSignalGroups(sgExclusive)
        lane:routes("Additional Route"):driveAlsoOnSignalGroups(sgAdditional)

        it("stores the lane signal", function ()
            assert.equals(laneSignal, lane.laneSignal)
            assert.equals(laneSignal, lane.laneSignal)
        end)

        it("allows route-specific additional signals from one call", function ()
            lane.firstVehiclesRoute = "Additional Route"

            assert.is_true(Lane.laneCanDrive(lane, { additionalSignal }))
            assert.is_true(Lane.laneCanDrive(lane, { secondAdditionalSignal }))
            assert.is_true(Lane.laneCanDrive(lane, { defaultSignal }))
            assert.is_false(Lane.laneCanDrive(lane, { exclusiveSignal }))
        end)

        it("uses route-specific exclusive signals from one call", function ()
            lane.firstVehiclesRoute = "Exclusive Route"

            assert.is_false(Lane.laneCanDrive(lane, { defaultSignal }))
            assert.is_true(Lane.laneCanDrive(lane, { exclusiveSignal }))
            assert.is_true(Lane.laneCanDrive(lane, { secondExclusiveSignal }))
            assert.is_false(Lane.laneCanDrive(lane, { additionalSignal }))
        end)

        it("requires at least one route for route-bound drive signal groups", function ()
            assert.has_error(function () lane:routes():driveAlsoOnSignalGroups(sgAdditional) end,
                             "Specify at least one route")
        end)
    end)
    insulate("Legacy applyToLane maps to lane based route drive signals", function ()
        require("ce.hub.eep.EepSimulator")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local Lane = require("ce.mods.road.Lane")

        local defaultSignal = TrafficLight:new("Default", 55, TrafficLightModel.JS2_3er_mit_FG)
        local routeSignal = TrafficLight:new("Route", 56, TrafficLightModel.JS2_3er_mit_FG)
        local laneSignal = TrafficLight:new("laneSignal", 11, TrafficLightModel.Unsichtbar_2er)
        local lane = Lane:new("Lane A", 34, laneSignal)

        defaultSignal:applyToLane(lane)
        routeSignal:applyToLane(lane, "Route A")

        it("maps applyToLane without routes to the default signal", function ()
            assert.is_true(lane.defaultDriveSignals[defaultSignal])
            assert.are.same({}, lane.signalsToDriveOn[defaultSignal])
        end)

        it("maps applyToLane with routes to an additional route signal", function ()
            lane.firstVehiclesRoute = "Route A"

            assert.are.same({ "Route A" }, lane.signalsToDriveOn[routeSignal])
            assert.is_true(Lane.laneCanDrive(lane, { defaultSignal }))
            assert.is_true(Lane.laneCanDrive(lane, { routeSignal }))
        end)
    end)

    insulate("Register signals", function ()
        require("ce.hub.eep.EepSimulator")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local SignalIndication = require("ce.mods.road.SignalIndication")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local Lane = require("ce.mods.road.Lane")
        local signalId = 55

        -- Set the route for train "#Car1"
        EEPSetTrainRoute("#Car1", "Some Route")
        -- Signal which is visible to tell the lanes traffic to drive
        local K1 = TrafficLight:new("K1", signalId, TrafficLightModel.JS2_3er_ohne_FG)
        -- EEP Signal, which is used to start and stop the lanes traffic (needs to be switched to green too)
        local L1 = TrafficLight:new("L1", 11, TrafficLightModel.Unsichtbar_2er)

        local lane = Lane:new("Lane A", 34, L1)
        local tlsBeforeDriveOn = lane.signalsToDriveOn
        it("Lane has signal", function () assert.is_nil(tlsBeforeDriveOn) end)

        K1:applyToLane(lane)

        it("Lane has signal", function () assert.is_truthy(lane.signalsToDriveOn) end)
        it("Lane has signal", function () assert.are.same({}, lane.signalsToDriveOn[K1]) end)
        describe("Can drive at red", function ()
            K1:switchTo(SignalIndication.RED)
            local canDriveAtRed = L1.currentIndication
            local k1SignalIndex = EEPGetSignal(K1.signalId)
            it("SignalId is correct",
               function () assert.equals(TrafficLightModel.JS2_3er_ohne_FG.signalIndexRed, k1SignalIndex) end)
            it("canDrive()", function () assert.equals(SignalIndication.RED, canDriveAtRed) end)
        end)
        describe("Can drive at green", function ()
            K1:switchTo(SignalIndication.GREEN)
            local canDriveAtGreen = L1.currentIndication
            local k1SignalIndex = EEPGetSignal(K1.signalId)
            it("SignalId is correct",
               function () assert.equals(TrafficLightModel.JS2_3er_ohne_FG.signalIndexGreen, k1SignalIndex) end)
            it("canDrive()", function () assert.equals(SignalIndication.GREEN, canDriveAtGreen) end)
        end)
    end)

    insulate("Show requests on the correct signal groups", function ()
        require("ce.hub.eep.EepSimulator")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        -- local SignalIndication = require("ce.mods.road.SignalIndication")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local SignalGroup = require("ce.mods.road.SignalGroup")
        local Lane = require("ce.mods.road.Lane")
        local signalId = 55

        -- Set the route for train "#Car1"
        EEPSetTrainRoute("#Car1", "Route A")
        EEPSetTrainRoute("#Car2", "Route B")
        EEPSetTrainRoute("#Car3", "Route C")

        EEPStructureSetLight("#11_RED", false)
        EEPStructureSetLight("#21_RED", false)
        EEPStructureSetLight("#31_RED", false)
        EEPStructureSetLight("#12_GREEN", false)
        EEPStructureSetLight("#22_GREEN", false)
        EEPStructureSetLight("#32_GREEN", false)
        EEPStructureSetLight("#13_YELLOW", false)
        EEPStructureSetLight("#23_YELLOW", false)
        EEPStructureSetLight("#33_YELLOW", false)
        EEPStructureSetLight("#14_REQUEST", false)
        EEPStructureSetLight("#24_REQUEST", false)
        EEPStructureSetLight("#34_REQUEST", false)

        -- Signal which is visible to tell the lanes traffic to drive
        local K1 = TrafficLight:new("K1", signalId, TrafficLightModel.JS2_3er_ohne_FG, "#11_RED", "#12_GREEN",
                                    "#13_YELLOW", "#14_REQUEST")
        local K2 = TrafficLight:new("K2", signalId, TrafficLightModel.JS2_3er_ohne_FG, "#21_RED", "#22_GREEN",
                                    "#23_YELLOW", "#24_REQUEST")
        local K3 = TrafficLight:new("K3", signalId, TrafficLightModel.JS2_3er_ohne_FG, "#31_RED", "#32_GREEN",
                                    "#33_YELLOW", "#34_REQUEST")
        -- EEP Signal, which is used to start and stop the lanes traffic (needs to be switched to green too)
        local L1 = TrafficLight:new("L1", 11, TrafficLightModel.Unsichtbar_2er)
        local sgK1 = SignalGroup:new("sgK1"):addVehicleSignals(K1)
        local sgK2 = SignalGroup:new("sgK2"):addVehicleSignals(K2)
        local sgK3 = SignalGroup:new("sgK3"):addVehicleSignals(K3)

        local lane = Lane:new("Lane A", 34, L1)
        lane:showRequestsOnSignalGroups(sgK1)
        lane:routes("Route A"):showRequestsOnSignalGroups(sgK2)
        lane:routes("Route B", "Route C"):showRequestsOnSignalGroups(sgK3)

        it("K1 is registered for !ALL!", function () assert.same({ K1 }, lane.requestSignals["!ALL!"]) end)
        it("K2 is registered for Route A", function () assert.same({ K2 }, lane.requestSignals["Route A"]) end)
        it("K3 is registered for Route B", function () assert.same({ K3 }, lane.requestSignals["Route B"]) end)
        it("K3 is registered for Route C", function () assert.same({ K3 }, lane.requestSignals["Route C"]) end)

        lane:vehicleLeft("#Car4")
        local _, lightOnK1NoCar = EEPStructureGetLight("#14")
        local _, lightOnK2NoCar = EEPStructureGetLight("#24")
        local _, lightOnK3NoCar = EEPStructureGetLight("#34")
        it("  Light on K1 NoCar", function () assert.is_false(lightOnK1NoCar) end)
        it("  Light on K2 NoCar", function () assert.is_false(lightOnK2NoCar) end)
        it("  Light on K3 NoCar", function () assert.is_false(lightOnK3NoCar) end)

        lane:vehicleEntered("#Car2")
        lane:vehicleEntered("#Car1")
        local _, lightOnK1Car2 = EEPStructureGetLight("#14")
        local _, lightOnK2Car2 = EEPStructureGetLight("#24")
        local _, lightOnK3Car2 = EEPStructureGetLight("#34")
        it("  Light on K1 Car2", function () assert.is_true(lightOnK1Car2) end)
        it("  Light on K2 Car2", function () assert.is_true(lightOnK2Car2) end)
        it("  Light on K3 Car2", function () assert.is_true(lightOnK3Car2) end)
        lane:vehicleLeft("#Car2")
        lane:vehicleLeft("#Car1")

        lane:vehicleEntered("#Car3")
        local _, lightOnK1Car3 = EEPStructureGetLight("#14")
        local _, lightOnK2Car3 = EEPStructureGetLight("#24")
        local _, lightOnK3Car3 = EEPStructureGetLight("#34")
        it("  Light on K1 Car3", function () assert.is_true(lightOnK1Car3) end)
        it("  Light on K2 Car3", function () assert.is_false(lightOnK2Car3) end)
        it("  Light on K3 Car3", function () assert.is_true(lightOnK3Car3) end)
        lane:vehicleLeft("#Car3")

        lane:vehicleLeft("#Car3")
        local _, lightOnK1NoCar2 = EEPStructureGetLight("#14")
        local _, lightOnK2NoCar2 = EEPStructureGetLight("#24")
        local _, lightOnK3NoCar2 = EEPStructureGetLight("#34")
        it("  Light on K1 NoCar", function () assert.is_false(lightOnK1NoCar2) end)
        it("  Light on K2 NoCar", function () assert.is_false(lightOnK2NoCar2) end)
        it("  Light on K3 NoCar", function () assert.is_false(lightOnK3NoCar2) end)
    end)

    insulate("Route builder shows exclusive route requests only on the selected signal group", function ()
        require("ce.hub.eep.EepSimulator")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local SignalGroup = require("ce.mods.road.SignalGroup")
        local Lane = require("ce.mods.road.Lane")

        EEPSetTrainRoute("#Car1", "Route A")
        EEPSetTrainRoute("#Car2", "Route B")
        EEPSetTrainRoute("#Car3", "Route C")

        EEPStructureSetLight("#11_RED", false)
        EEPStructureSetLight("#21_RED", false)
        EEPStructureSetLight("#12_GREEN", false)
        EEPStructureSetLight("#22_GREEN", false)
        EEPStructureSetLight("#13_YELLOW", false)
        EEPStructureSetLight("#23_YELLOW", false)
        EEPStructureSetLight("#14_REQUEST", false)
        EEPStructureSetLight("#24_REQUEST", false)

        local S2 = TrafficLight:new("S2", 55, TrafficLightModel.JS2_3er_ohne_FG, "#11_RED", "#12_GREEN",
                                    "#13_YELLOW", "#14_REQUEST")
        local S3 = TrafficLight:new("S3", 56, TrafficLightModel.JS2_3er_ohne_FG, "#21_RED", "#22_GREEN",
                                    "#23_YELLOW", "#24_REQUEST")
        local laneSignal = TrafficLight:new("laneSignal", 11, TrafficLightModel.Unsichtbar_2er)
        local lane = Lane:new("Lane A", 34, laneSignal)
        local sgS2 = SignalGroup:new("sgS2"):addVehicleSignals(S2)
        local sgS3 = SignalGroup:new("sgS3"):addVehicleSignals(S3)

        lane:driveOnDefaultSignalGroups(sgS2):showRequestsOnSignalGroups(sgS2)
        lane:routes("Route A", "Route B"):driveOnlyOnSignalGroups(sgS3):showRequestsOnSignalGroups(sgS3)

        it("registers selected route requests only on S3 and default requests on S2", function ()
            assert.same({ S2 }, lane.requestSignals["!ALL!"])
            assert.same({ S3 }, lane.requestSignals["Route A"])
            assert.same({ S3 }, lane.requestSignals["Route B"])
        end)

        lane:vehicleEntered("#Car1")
        local _, lightOnS2RouteA = EEPStructureGetLight("#14")
        local _, lightOnS3RouteA = EEPStructureGetLight("#24")
        it("turns on S3 request light for an exclusive route", function () assert.is_true(lightOnS3RouteA) end)
        it("does not turn on S2 request light for an exclusive route", function () assert.is_false(lightOnS2RouteA) end)
        lane:vehicleLeft("#Car1")

        lane:vehicleEntered("#Car3")
        local _, lightOnS2RouteC = EEPStructureGetLight("#14")
        local _, lightOnS3RouteC = EEPStructureGetLight("#24")
        it("turns on S2 request light for another route", function () assert.is_true(lightOnS2RouteC) end)
        it("does not turn on S3 request light for another route", function () assert.is_false(lightOnS3RouteC) end)
    end)

    describe("Legacy loading", function ()
        insulate("No saved vehicles, but a counter", function ()
            require("ce.hub.eep.EepSimulator")
            local StorageUtility = require("ce.hub.util.StorageUtility")
            local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
            local TrafficLight = require("ce.mods.road.TrafficLight")
            local Lane = require("ce.mods.road.Lane")
            local signalId = 55

            StorageUtility.saveTable(34, { f = "4" })
            local lane = Lane:new("Lane A", 34, TrafficLight:new("X", signalId, TrafficLightModel.Unsichtbar_2er))
            insulate("Vehicles have generic names", function ()
                it("Queue looks as follows", function ()
                    assert.are.same({ "train 1", "train 2", "train 3", "train 4" }, lane.queue:elements())
                end)
                it("Lane queue size is 4", function () assert.equals(4, lane.queue:size()) end)
                it("Lane vehicle count is 4", function () assert.equals(4, lane.vehicleCount) end)
            end)
            insulate("First vehicle leaving will remove one element from queue", function ()
                lane:vehicleLeft("train 1")
                it("Queue looks as follows",
                   function () assert.are.same({ "train 2", "train 3", "train 4" }, lane.queue:elements()) end)
                it("Lane queue size is decreased", function () assert.equals(3, lane.queue:size()) end)
                it("Lane vehicle count is decreased", function () assert.equals(3, lane.vehicleCount) end)
            end)
            insulate("Third vehicle leaving will remove two more elements from queue", function ()
                lane:vehicleLeft("train 3")
                it("Queue looks as follows", function ()
                    assert.are.same({ "train 4" }, lane.queue:elements())
                end)
                it("Lane queue size is decreased", function () assert.equals(1, lane.queue:size()) end)
                it("Lane vehicle count is decreased", function () assert.equals(1, lane.vehicleCount) end)
            end)
            insulate("all elements are removed from queue", function ()
                lane:vehicleLeft("train 4")
                it("Lane queue size is decreased", function () assert.equals(0, lane.queue:size()) end)
                it("Lane vehicle count is decreased", function () assert.equals(0, lane.vehicleCount) end)
            end)
            insulate("all entries until the first good entered vehicle are removed from queue", function ()
                lane:vehicleEntered("train 5")
                lane:vehicleEntered("train 6")
                lane:vehicleLeft("no matching train")
                it("Queue looks as follows",
                   function () assert.are.same({ "train 5", "train 6" }, lane.queue:elements()) end)
                it("Lane queue size is decreased", function () assert.equals(2, lane.queue:size()) end)
                it("Lane vehicle count is decreased", function () assert.equals(2, lane.vehicleCount) end)
            end)
        end)
    end)

    describe(":useSignalForQueue()", function ()
        insulate("disabled", function ()
            require("ce.hub.eep.EepSimulator")
            local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
            local TrafficLight = require("ce.mods.road.TrafficLight")
            local Lane = require("ce.mods.road.Lane")
            local signalId = 55

            -- Set the route for train "#Car1"
            EEPSetTrainRoute("#Car1", "Some Route")
            local lane =
                Lane:new("Lane A", 34, TrafficLight:new("LANE A", signalId, TrafficLightModel.Unsichtbar_2er))

            it("Traffic lights are not used", function () assert.is_false(lane.signalUsedForRequest) end)
            it("Traffic lights there is no entry in the table",
               function () for x in pairs(lane.routesToCount) do assert(false, x) end end)
            lane:checkRequests()
        end)

        insulate("without train", function ()
            require("ce.hub.eep.EepSimulator")
            local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
            local TrafficLight = require("ce.mods.road.TrafficLight")
            local Lane = require("ce.mods.road.Lane")
            local signalId = 55

            -- Set the route for train "#Car1"
            EEPSetTrainRoute("#Car1", "Some Route")
            local lane =
                Lane:new("Lane A", 34, TrafficLight:new("LANE A", signalId, TrafficLightModel.Unsichtbar_2er))

            lane:useSignalForQueue()
            lane:checkRequests()

            it("No trains waiting on signal", function ()
                assert.equals(0, EEPGetSignalTrainsCount(signalId))
            end)
            it("Traffic lights are used", function () assert.is_true(lane.signalUsedForRequest) end)
            it("There is no request", function () assert.equals(0, lane.queue:size()) end)
        end)

        insulate("with train", function ()
            local EepSimulator = require("ce.hub.eep.EepSimulator")
            local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
            local TrafficLight = require("ce.mods.road.TrafficLight")
            local Lane = require("ce.mods.road.Lane")
            local signalId = 55

            -- Set the route for train "#Car1"
            EEPSetTrainRoute("#Car1", "Some Route")
            EEPSetTrainRoute("#Car2", "Some Route")

            EepSimulator.simulateQueueTrainOnSignal(signalId, "#Car1")
            EepSimulator.simulateQueueTrainOnSignal(signalId, "#Car2")
            local lane = Lane:new("Lane A", 34, TrafficLight:new("K1", signalId, TrafficLightModel.Unsichtbar_2er))
            lane:useSignalForQueue()
            lane:checkRequests()

            it("No trains waiting on signal", function ()
                assert.equals(2, EEPGetSignalTrainsCount(signalId))
            end)
            it("No trains waiting on signal", function ()
                assert.equals("#Car1", EEPGetSignalTrainName(signalId, 1))
                assert.equals("#Car2", EEPGetSignalTrainName(signalId, 2))
            end)
            it("Traffic lights are used", function () assert.is_true(lane.signalUsedForRequest) end)
            it("There is a car on the lane signal", function () assert.equals(2, lane.queue:size()) end)
            it("There is #Car1 on the lane signal", function ()
                assert.equals("#Car1", lane.queue:firstElement())
            end)
        end)
    end)

    describe(":useTrackForQueue()", function ()
        insulate("disabled", function ()
            require("ce.hub.eep.EepSimulator")
            local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
            local TrafficLight = require("ce.mods.road.TrafficLight")
            local Lane = require("ce.mods.road.Lane")

            -- Set the route for train "#Car1"
            EEPSetTrainRoute("#Car1", "Some Route")
            local lane = Lane:new("Lane A", 34, TrafficLight:new("K1", 66, TrafficLightModel.Unsichtbar_2er))

            it("Traffic lights are not used", function () assert.is_false(lane.tracksUsedForRequest) end)
            it("Traffic lights there is no entry in the table",
               function () for x in pairs(lane.tracksForRequests) do assert(false, x) end end)
            lane:checkRequests()
        end)

        insulate("without train", function ()
            require("ce.hub.eep.EepSimulator")
            local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
            local TrafficLight = require("ce.mods.road.TrafficLight")
            local Lane = require("ce.mods.road.Lane")
            local roadId = 55

            -- Set the route for train "#Car1"
            EEPSetTrainRoute("#Car1", "Some Route")
            local lane = Lane:new("Lane A", 34, TrafficLight:new("K1", 66, TrafficLightModel.Unsichtbar_2er))

            lane:useTrackForQueue(roadId)
            lane:checkRequests()
            lane:checkRequests()
            lane:checkRequests()

            it("No trains waiting on signal", function () assert.equals(0, EEPGetSignalTrainsCount(roadId)) end)
            it("Traffic lights are used", function () assert.is_true(lane.tracksUsedForRequest) end)
            it("There is no request", function () assert.equals(0, lane.queue:size()) end)
        end)

        insulate("with train", function ()
            local EepSimulator = require("ce.hub.eep.EepSimulator")
            local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
            local TrafficLight = require("ce.mods.road.TrafficLight")
            local Lane = require("ce.mods.road.Lane")
            local roadId = 55

            -- Set the route for train "#Car1"
            EEPSetTrainRoute("#Car1", "Some Route")

            EepSimulator.simulatePlaceTrainOnRoadTrack(roadId, "#Car1")
            local lane = Lane:new("Lane A", 34, TrafficLight:new("K1", 66, TrafficLightModel.Unsichtbar_2er))
            lane:useTrackForQueue(roadId)
            lane:checkRequests()
            lane:checkRequests()
            lane:checkRequests()

            it("- #Car1 is on the road", function ()
                local trackRegistered, trackOccupied, trainName = EEPIsRoadTrackReserved(roadId, true)
                assert.equals(true, trackRegistered)
                assert.equals(true, trackOccupied)
                assert.equals("#Car1", trainName)
            end)
            it("- Road counting is used", function () assert.is_true(lane.tracksUsedForRequest) end)
            it("- There is a request on the road track", function () assert.equals(1, lane.queue:size()) end)
            it("- There is a request on the road track",
               function () assert.equals("#Car1", lane.queue:firstElement()) end)
        end)
    end)

    insulate("Loading", function ()
        require("ce.hub.eep.EepSimulator")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local SignalIndication = require("ce.mods.road.SignalIndication")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local Lane = require("ce.mods.road.Lane")

        EEPSaveData(888, "f=4,p=Rot,q=#Mittelklasse_PKW_blau_NP1|#Citaro_01c_LE-Ue_UK2_v7;001" ..
            "|#Auflieger_Mobil_HB3|#Kaessbohrer Tankauflieger BP (v8),w=6,")
        local lane = Lane:new("Lane A", 888, TrafficLight:new("K1", 66, TrafficLightModel.Unsichtbar_2er))

        it("Lane loaded", function () assert.equals(4, lane.queue:size()) end)
        it("Lane loaded", function () assert.equals(4, lane.vehicleCount) end)
        it("Lane loaded", function () assert.equals(6, lane.waitCount) end)
        it("Lane loaded", function () assert.equals(SignalIndication.RED, lane.currentIndication) end)
    end)
end)
