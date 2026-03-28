insulate("ce.hub.data.trains.TrainRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.data.trains.Train")
        clearModule("ce.hub.data.trains.TrainRegistry")
        clearModule("ce.hub.data.trains.TrainDtoFactory")
        clearModule("ce.hub.data.rollingstock.RollingStock")
        clearModule("ce.hub.data.rollingstock.RollingStockRegistry")
        clearModule("ce.hub.publish.DataChangeBus")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")

        require("ce.hub.eep.EepSimulator")
    end)

    it("keeps all train entries when only one train changes", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

        EepSimulator.simulateAddTrain("T1", "RS1")
        EepSimulator.simulateAddTrain("T2", "RS2")

        local train1 = TrainRegistry.forName("T1")
        TrainRegistry.forName("T2")

        TrainRegistry.fireChangeTrainsEvent()

        assert.is_not_nil(InternalDataStore.get("ce.hub.Train", "T1"))
        assert.is_not_nil(InternalDataStore.get("ce.hub.Train", "T2"))

        train1:setSpeed(12)
        TrainRegistry.fireChangeTrainsEvent()

        assert.same(12.0, InternalDataStore.get("ce.hub.Train", "T1").speed)
        assert.is_not_nil(InternalDataStore.get("ce.hub.Train", "T2"))
    end)
end)
