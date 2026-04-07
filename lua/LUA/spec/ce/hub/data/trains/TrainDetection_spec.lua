describe("TrainDiscovery", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local function resetModules()
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.data.tracks.TrackRegistry")
        clearModule("ce.hub.data.trains.TrainDiscoveryCache")
        clearModule("ce.hub.data.trains.Train")
        clearModule("ce.hub.data.trains.TrainRegistry")
        clearModule("ce.hub.data.trains.TrainDiscovery")
        clearModule("ce.hub.data.trains.TrainUpdater")
        clearModule("ce.hub.data.rollingstock.RollingStock")
        clearModule("ce.hub.data.rollingstock.RollingStockRegistry")
        clearModule("ce.hub.data.rollingstock.RollingStockUpdater")
    end

    local function runCycle(selectedTrackCeTypes)
        local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
        local TrainUpdater = require("ce.hub.data.trains.TrainUpdater")
        local RollingStockUpdater = require("ce.hub.data.rollingstock.RollingStockUpdater")

        TrainDiscovery.runDiscovery(selectedTrackCeTypes or {})
        TrainUpdater.runUpdate({})
        RollingStockUpdater.runUpdate({})
    end

    before_each(function ()
        resetModules()
    end)

    it("discovers trains on tracks and updates rolling-stock composition after splits", function ()
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

    it("keeps optional multi-return getters robust during updates", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")

        EepSimulator.simulateAddTrain("#EepTrainMultiReturn", "RollingStock 3", "RollingStock 4")
        TrainDiscovery.runInitialDiscovery()
        EepSimulator.simulatePlaceTrainOnRailTrack(2, "#EepTrainMultiReturn")
        runCycle()

        local rollingStockName = TrainRegistry.rollingStockNameInTrain("#EepTrainMultiReturn", 0)
        local originalGetTrainCouplingFront = _G.EEPGetTrainCouplingFront
        local originalGetTrainCouplingRear = _G.EEPGetTrainCouplingRear
        local originalIsTrainInTrainyard = _G.EEPIsTrainInTrainyard
        local originalGetOrientation = _G.EEPRollingstockGetOrientation
        local originalGetSmoke = _G.EEPRollingstockGetSmoke
        local originalGetHook = _G.EEPRollingstockGetHook
        local originalGetHookGlue = _G.EEPRollingstockGetHookGlue

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

        _G.EEPGetTrainCouplingFront = originalGetTrainCouplingFront
        _G.EEPGetTrainCouplingRear = originalGetTrainCouplingRear
        _G.EEPIsTrainInTrainyard = originalIsTrainInTrainyard
        _G.EEPRollingstockGetOrientation = originalGetOrientation
        _G.EEPRollingstockGetSmoke = originalGetSmoke
        _G.EEPRollingstockGetHook = originalGetHook
        _G.EEPRollingstockGetHookGlue = originalGetHookGlue
    end)
end)
