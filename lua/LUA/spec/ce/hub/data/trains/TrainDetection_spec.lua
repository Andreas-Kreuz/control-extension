---@diagnostic disable: redundant-parameter
describe("TrainDiscovery", function ()
    local function runCycle(selectedTrackCeTypes)
        local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
        local TrainUpdater = require("ce.hub.data.trains.TrainUpdater")
        local RollingStockUpdater = require("ce.hub.data.rollingstock.RollingStockUpdater")

        TrainDiscovery.runDiscovery(selectedTrackCeTypes or {})
        TrainUpdater.runUpdate({})
        RollingStockUpdater.runUpdate({})
    end

    insulate("discovers trains on tracks and updates rolling-stock composition after splits", function ()
        it("keeps train discovery isolated", function ()
            local EepSimulator = require("ce.hub.eep.EepSimulator")
            local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
            local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

            EepSimulator.simulateAddTrain("#EepTrain1", "RollingStock 1", "RollingStock 2")
            TrainDiscovery.runInitialDiscovery()
            runCycle()
            assert.is_falsy(TrainRegistry.getAllTrainNames()["#EepTrain1"])

            EepSimulator.simulatePlaceTrainOnRailTrack(1, "#EepTrain1")
            for _ = 1, 50 do runCycle() end

            assert.is_true(TrainRegistry.getAllTrainNames()["#EepTrain1"])
            assert.is_falsy(TrainRegistry.getAllTrainNames()["#EepTrain1;001"])
            assert.equals(2, TrainRegistry.forName("#EepTrain1"):getRollingStockCount())

            EepSimulator.simulateSplitTrain("#EepTrain1", 1)
            runCycle()

            assert.is_true(TrainRegistry.getAllTrainNames()["#EepTrain1"])
            assert.is_true(TrainRegistry.getAllTrainNames()["#EepTrain1;001"])
            assert.equals(1, TrainRegistry.forName("#EepTrain1"):getRollingStockCount())
            assert.equals(1, TrainRegistry.forName("#EepTrain1;001"):getRollingStockCount())
        end)

        it("refreshes track occupancy on the first runtime pass and then every 50 discovery calls", function ()
            local EepSimulator = require("ce.hub.eep.EepSimulator")
            local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
            local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

            EepSimulator.simulateAddTrain("#TrackRefreshTrain1", "TrackRefreshStock1")
            EepSimulator.simulateAddTrain("#TrackRefreshTrain2", "TrackRefreshStock2")
            TrainDiscovery.runInitialDiscovery()

            EepSimulator.simulatePlaceTrainOnRailTrack(1, "#TrackRefreshTrain1")
            runCycle()

            assert.is_true(TrainRegistry.getAllTrainNames()["#TrackRefreshTrain1"])
            assert.is_falsy(TrainRegistry.getAllTrainNames()["#TrackRefreshTrain2"])

            EepSimulator.simulatePlaceTrainOnRailTrack(2, "#TrackRefreshTrain2")
            for _ = 1, 49 do runCycle() end

            assert.is_falsy(TrainRegistry.getAllTrainNames()["#TrackRefreshTrain2"])

            runCycle()

            assert.is_true(TrainRegistry.getAllTrainNames()["#TrackRefreshTrain2"])
        end)
    end)

    insulate("keeps optional multi-return getters robust during updates", function ()
        it("handles missing optional globals without leaking them", function ()
            local EepSimulator = require("ce.hub.eep.EepSimulator")
            local HubCeTypes = require("ce.hub.data.HubCeTypes")
            local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
            local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
            local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
            local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")

            EepSimulator.simulateAddTrain("#EepTrainMultiReturn", "RollingStock 3", "RollingStock 4")
            TrainDiscovery.runInitialDiscovery()
            EepSimulator.simulatePlaceTrainOnRailTrack(2, "#EepTrainMultiReturn")
            runCycle()

            local rollingStockName = TrainRegistry.rollingStockNameInTrain("#EepTrainMultiReturn", 0)
            InterestSyncRegistry.startSyncFor(HubCeTypes.Train, "#EepTrainMultiReturn")
            InterestSyncRegistry.startSyncFor(HubCeTypes.RollingStock, rollingStockName)

            EEPSetTrainCouplingFront("#EepTrainMultiReturn", true)
            EEPSetTrainCouplingRear("#EepTrainMultiReturn", false)
            EepSimulator.simulateAddTrainToTrainyard(9, "#EepTrainMultiReturn", 0, 1)
            EepSimulator.simulateSetRollingStockOrientation(rollingStockName, false)
            EEPRollingstockSetSmoke(rollingStockName, true)
            EEPRollingstockSetHook(rollingStockName, true)
            EEPRollingstockSetHookGlue(rollingStockName, true)

            assert.has_no.errors(function () runCycle() end)

            local train = TrainRegistry.forName("#EepTrainMultiReturn")
            local rollingStock = RollingStockRegistry.forName(rollingStockName)

            assert.equals(1, train:getCouplingFront())
            assert.equals(2, train:getCouplingRear())
            assert.is_true(train:getInTrainyard())
            assert.equals(9, train:getTrainyardId())
            assert.is_false(rollingStock:getOrientationForward())
            assert.equals(1, rollingStock:getSmoke())
            assert.equals(1, rollingStock:getHookStatus())
            assert.equals(1, rollingStock:getHookGlueMode())

            rawset(_G, "EEPGetTrainCouplingFront", nil)
            rawset(_G, "EEPGetTrainCouplingRear", nil)
            rawset(_G, "EEPIsTrainInTrainyard", nil)
            rawset(_G, "EEPRollingstockGetOrientation", nil)
            rawset(_G, "EEPRollingstockGetSmoke", nil)
            rawset(_G, "EEPRollingstockGetHook", nil)
            rawset(_G, "EEPRollingstockGetHookGlue", nil)

            assert.has_no.errors(function () runCycle() end)
            assert.equals(1, train:getCouplingFront())
            assert.equals(2, train:getCouplingRear())
            assert.is_false(train:getInTrainyard())
            assert.is_nil(train:getTrainyardId())
            assert.is_false(rollingStock:getOrientationForward())
            assert.equals(1, rollingStock:getSmoke())
            assert.equals(1, rollingStock:getHookStatus())
            assert.equals(1, rollingStock:getHookGlueMode())

            InterestSyncRegistry.clearAll()
        end)
    end)

    insulate("updates target speed on interest", function ()
        it("does not poll target speed for unselected trains by default", function ()
            local EepSimulator = require("ce.hub.eep.EepSimulator")
            local HubCeTypes = require("ce.hub.data.HubCeTypes")
            local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
            local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
            local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
            local TrainUpdater = require("ce.hub.data.trains.TrainUpdater")

            HubOptionsRegistry.reset()
            EepSimulator.simulateAddTrain("#TargetSpeedTrain", "TargetSpeedStock")
            local train = TrainRegistry.forName("#TargetSpeedTrain")
            train:resetDirty()

            local targetSpeedCalls = 0
            local couplingFrontCalls = 0
            local couplingRearCalls = 0
            local lightCalls = 0
            local originalGetTrainSpeed = _G.EEPGetTrainSpeed
            local getTrainSpeedStub = stub(_G, "EEPGetTrainSpeed", function (trainName, readTargetSpeed)
                if readTargetSpeed then
                    targetSpeedCalls = targetSpeedCalls + 1
                    return true, 44
                end
                return originalGetTrainSpeed(trainName, readTargetSpeed)
            end)
            local couplingFrontStub = stub(_G, "EEPGetTrainCouplingFront", function ()
                couplingFrontCalls = couplingFrontCalls + 1
                return true, 1
            end)
            local couplingRearStub = stub(_G, "EEPGetTrainCouplingRear", function ()
                couplingRearCalls = couplingRearCalls + 1
                return true, 2
            end)
            local lightStub = stub(_G, "EEPGetTrainLight", function ()
                lightCalls = lightCalls + 1
                return true, true
            end)
            finally(function () getTrainSpeedStub:revert() end)
            finally(function () couplingFrontStub:revert() end)
            finally(function () couplingRearStub:revert() end)
            finally(function () lightStub:revert() end)

            TrainUpdater.runUpdate()

            assert.equals(0, targetSpeedCalls)
            assert.equals(0, couplingFrontCalls)
            assert.equals(0, couplingRearCalls)
            assert.equals(0, lightCalls)
            assert.is_nil(train.dirtyFields.targetSpeed)

            InterestSyncRegistry.startSyncFor(HubCeTypes.Train, "#TargetSpeedTrain")
            TrainUpdater.runUpdate()

            assert.equals(1, targetSpeedCalls)
            assert.equals(1, couplingFrontCalls)
            assert.equals(1, couplingRearCalls)
            assert.equals(4, lightCalls)
            assert.equals(44, train:getTargetSpeed())
            assert.is_true(train.dirtyFields.targetSpeed)

            InterestSyncRegistry.clearAll()
            HubOptionsRegistry.reset()
        end)
    end)

    insulate("updates routes throttled and on interest", function ()
        it("polls unselected routes every ten updater runs and selected routes every run", function ()
            package.loaded["ce.hub.data.trains.TrainUpdater"] = nil
            local EepSimulator = require("ce.hub.eep.EepSimulator")
            local HubCeTypes = require("ce.hub.data.HubCeTypes")
            local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
            local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
            local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
            local TrainUpdater = require("ce.hub.data.trains.TrainUpdater")

            HubOptionsRegistry.reset()
            EepSimulator.simulateAddTrain("#RouteThrottleTrain", "RouteThrottleStock")
            EEPSetTrainRoute("#RouteThrottleTrain", "Initial Route")
            local train = TrainRegistry.forName("#RouteThrottleTrain")

            local routeCalls = 0
            local routeName = "Polled Route 1"
            local getTrainRouteStub = stub(_G, "EEPGetTrainRoute", function ()
                routeCalls = routeCalls + 1
                return true, routeName
            end)
            finally(function () getTrainRouteStub:revert() end)

            TrainUpdater.runUpdate()
            assert.equals(1, routeCalls)
            assert.equals("Polled Route 1", train:getRoute())

            routeName = "Polled Route 2"
            for _ = 1, 9 do TrainUpdater.runUpdate() end
            assert.equals(1, routeCalls)
            assert.equals("Polled Route 1", train:getRoute())

            TrainUpdater.runUpdate()
            assert.equals(2, routeCalls)
            assert.equals("Polled Route 2", train:getRoute())

            InterestSyncRegistry.startSyncFor(HubCeTypes.Train, "#RouteThrottleTrain")
            routeName = "Selected Route"
            TrainUpdater.runUpdate()
            TrainUpdater.runUpdate()

            assert.equals(4, routeCalls)
            assert.equals("Selected Route", train:getRoute())

            InterestSyncRegistry.clearAll()
            HubOptionsRegistry.reset()
        end)
    end)

    insulate("discovers one single-rolling-stock train on the second track of each track type", function ()
        it("maps occupied track buckets to the expected discovered train track types", function ()
            local EepSimulator = require("ce.hub.eep.EepSimulator")
            local Store = require("ce.hub.eep.EepSimulatorStore")
            local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
            local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
            local TrackRegistry = require("ce.hub.data.tracks.TrackRegistry")

            local occupiedTracksByType = {
                auxiliary = 2,
                control = 4,
                road = 6,
                rail = 8,
                tram = 10
            }
            local systemIdByType = {
                rail = 1,
                road = 3,
                tram = 2,
                auxiliary = 4,
                control = 5
            }
            local rollingStockByTrainName = {}

            for trackType, trackId in pairs(occupiedTracksByType) do
                local trainName = "#Train-" .. trackType
                local rollingStockName = "RS-" .. trackType
                rollingStockByTrainName[rollingStockName] = {
                    trackId = trackId,
                    systemId = systemIdByType[trackType]
                }
                EepSimulator.simulateAddTrain(trainName, rollingStockName)
            end

            TrainDiscovery.runInitialDiscovery()

            for trackType, trackId in pairs(occupiedTracksByType) do
                local trainName = "#Train-" .. trackType
                Store.state.tracks[trackType][trackId] = Store.state.tracks[trackType][trackId] or {}
                Store.state.tracks[trackType][trackId].registered = true
                Store.state.tracks[trackType][trackId].occupiedTrainName = trainName
            end

            local originalGetRollingstockTrack = _G.EEPRollingstockGetTrack
            local getRollingstockTrackStub = stub(_G, "EEPRollingstockGetTrack", function (rollingStockName)
                local info = rollingStockByTrainName[rollingStockName]
                if info then
                    return true, info.trackId, 5, 1, info.systemId
                end
                return originalGetRollingstockTrack(rollingStockName)
            end)
            finally(function () getRollingstockTrackStub:revert() end)

            runCycle()

            for trackType, trackId in pairs(occupiedTracksByType) do
                local trainName = "#Train-" .. trackType
                local train = TrainRegistry.getAll()[trainName]
                local track = TrackRegistry.get(trackType, trackId)

                assert.is_not_nil(train)
                ---@cast train Train
                assert.equals(trackType, train:getTrackType())
                assert.same({ [tostring(trackId)] = trackId }, train:getOnTrack())
                assert.is_not_nil(track)
                ---@cast track Track
                assert.is_true(track.reserved)
                assert.equals(trainName, track.reservedByTrainName)
            end
        end)
    end)
end)
