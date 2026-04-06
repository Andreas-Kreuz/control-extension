describe("TrainDetection", function ()
    local debug = false

    local EepSimulator = require("ce.hub.eep.EepSimulator")
    local TrainInfoUpdater = require("ce.hub.data.trains.TrainInfoUpdater")
    local RollingStockInfoUpdater = require("ce.hub.data.rollingstock.RollingStockInfoUpdater")
    EepSimulator.debug = debug
    EepSimulator.simulateAddTrain("#EepTrain1", "RollingStock 1", "RollingStock 2")

    local function refreshDetectedEntities(TrainDetection)
        local snapshot = TrainDetection.update()
        TrainInfoUpdater.refresh(snapshot.allKnownTrains, {})
        RollingStockInfoUpdater.refresh(snapshot.allKnownTrains, {}, snapshot.selectedCeTypes)
        return snapshot
    end

    insulate("with #EepTrain1:", function ()
        local TrainDetection = require("ce.hub.data.trains.TrainDetection")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        TrainDetection.debug = debug
        TrainRegistry.debug = debug

        TrainDetection.initialize()
        refreshDetectedEntities(TrainDetection)

        local haveTrainInitially = TrainRegistry.getAllTrainNames()["#EepTrain1"]
        it("have no train first", function () assert.is_falsy(haveTrainInitially) end)

        EepSimulator.simulatePlaceTrainOnRailTrack(1, "#EepTrain1")
        refreshDetectedEntities(TrainDetection)

        local haveTrain1AfterInserting = TrainRegistry.getAllTrainNames()["#EepTrain1"]
        local haveTrain2AfterInserting = TrainRegistry.getAllTrainNames()["#EepTrain1;001"]
        local rsCount1AfterInserting = TrainRegistry.forName("#EepTrain1"):getRollingStockCount()
        it("have #EepTrain1 after inserting", function () assert.is_true(haveTrain1AfterInserting) end)
        it("no #EepTrain1;001 after inserting", function () assert.is_falsy(haveTrain2AfterInserting) end)
        it("#EepTrain1 has 2 rollingStock", function () assert.equals(2, rsCount1AfterInserting) end)
        it("train #EepTrain1 was not created", function ()
            local _, created = TrainRegistry.forName("#EepTrain1")
            assert.is_false(created)
        end)

        EepSimulator.simulateSplitTrain("#EepTrain1", 1)
        refreshDetectedEntities(TrainDetection)
        local haveTrain1AfterSplitting = TrainRegistry.getAllTrainNames()["#EepTrain1"]
        local haveTrain2AfterSplitting = TrainRegistry.getAllTrainNames()["#EepTrain1;001"]
        local rsCount1AfterSplitting = TrainRegistry.forName("#EepTrain1"):getRollingStockCount()
        local rsCount2AfterSplitting = TrainRegistry.forName("#EepTrain1;001"):getRollingStockCount()
        it("have #EepTrain1 after splitTrain", function () assert.is_true(haveTrain1AfterSplitting) end)
        it("no #EepTrain1;001 after splitTrain", function () assert.is_true(haveTrain2AfterSplitting) end)
        it("#EepTrain1 has 1 rollingStock", function () assert.equals(1, rsCount1AfterSplitting) end)
        it("#EepTrain1;001 has 1 rollingStock", function () assert.equals(1, rsCount2AfterSplitting) end)
    end)

    insulate("with multi-return getters:", function ()
        local TrainDetection = require("ce.hub.data.trains.TrainDetection")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
        TrainDetection.debug = debug
        TrainRegistry.debug = debug

        EepSimulator.simulateAddTrain("#EepTrainMultiReturn", "RollingStock 3", "RollingStock 4")
        TrainDetection.initialize()
        EepSimulator.simulatePlaceTrainOnRailTrack(2, "#EepTrainMultiReturn")
        refreshDetectedEntities(TrainDetection)

        it("uses all values from optional multi-return getters without errors", function ()
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

            assert.has_no.errors(function () refreshDetectedEntities(TrainDetection) end)

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

            assert.has_no.errors(function () refreshDetectedEntities(TrainDetection) end)
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
end)
