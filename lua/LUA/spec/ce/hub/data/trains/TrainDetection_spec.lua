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
            runCycle()

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
    end)

    insulate("keeps optional multi-return getters robust during updates", function ()
        it("handles missing optional globals without leaking them", function ()
            local EepSimulator = require("ce.hub.eep.EepSimulator")
            local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
            local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
            local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")

            EepSimulator.simulateAddTrain("#EepTrainMultiReturn", "RollingStock 3", "RollingStock 4")
            TrainDiscovery.runInitialDiscovery()
            EepSimulator.simulatePlaceTrainOnRailTrack(2, "#EepTrainMultiReturn")
            runCycle()

            local rollingStockName = TrainRegistry.rollingStockNameInTrain("#EepTrainMultiReturn", 0)

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

            _G.EEPGetTrainCouplingFront = nil
            _G.EEPGetTrainCouplingRear = nil
            _G.EEPIsTrainInTrainyard = nil
            _G.EEPRollingstockGetOrientation = nil
            _G.EEPRollingstockGetSmoke = nil
            _G.EEPRollingstockGetHook = nil
            _G.EEPRollingstockGetHookGlue = nil

            assert.has_no.errors(function () runCycle() end)
            assert.equals(1, train:getCouplingFront())
            assert.equals(2, train:getCouplingRear())
            assert.is_false(train:getInTrainyard())
            assert.is_nil(train:getTrainyardId())
            assert.is_false(rollingStock:getOrientationForward())
            assert.equals(1, rollingStock:getSmoke())
            assert.equals(1, rollingStock:getHookStatus())
            assert.equals(1, rollingStock:getHookGlueMode())
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
            local originalGetRollingstockTrack = _G.EEPRollingstockGetTrack

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

            _G.EEPRollingstockGetTrack = function (rollingStockName)
                local info = rollingStockByTrainName[rollingStockName]
                if info then
                    return true, info.trackId, 5, 1, info.systemId
                end
                return originalGetRollingstockTrack(rollingStockName)
            end

            runCycle()

            for trackType, trackId in pairs(occupiedTracksByType) do
                local trainName = "#Train-" .. trackType
                local train = TrainRegistry.getAll()[trainName]
                local track = TrackRegistry.get(trackType, trackId)

                assert.is_not_nil(train)
                assert.equals(trackType, train:getTrackType())
                assert.same({ [tostring(trackId)] = trackId }, train:getOnTrack())
                assert.is_not_nil(track)
                assert.is_true(track.reserved)
                assert.equals(trainName, track.reservedByTrainName)
            end
        end)
    end)
end)
