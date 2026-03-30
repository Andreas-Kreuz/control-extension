insulate("ce.hub.data.trains.TrainRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.data.dynamic.DynamicUpdateRegistry")
        clearModule("ce.hub.data.trains.Train")
        clearModule("ce.hub.data.trains.TrainRegistry")
        clearModule("ce.hub.data.trains.TrainStaticDtoFactory")
        clearModule("ce.hub.data.trains.TrainDynamicDtoFactory")
        clearModule("ce.hub.data.rollingstock.RollingStock")
        clearModule("ce.hub.data.rollingstock.RollingStockRegistry")
        clearModule("ce.hub.publish.DataChangeBus")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")

        require("ce.hub.eep.EepSimulator")
    end)

    it("keeps all train static entries when only one train changes", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

        EepSimulator.simulateAddTrain("T1", "RS1")
        EepSimulator.simulateAddTrain("T2", "RS2")

        local train1 = TrainRegistry.forName("T1")
        TrainRegistry.forName("T2")

        TrainRegistry.fireChangeTrainEvents({ [HubCeTypes.TrainStatic] = true })

        assert.is_not_nil(InternalDataStore.get(HubCeTypes.TrainStatic, "T1"))
        assert.is_not_nil(InternalDataStore.get(HubCeTypes.TrainStatic, "T2"))

        train1:setRoute("R1")
        TrainRegistry.fireChangeTrainEvents({ [HubCeTypes.TrainStatic] = true })

        assert.same("R1", InternalDataStore.get(HubCeTypes.TrainStatic, "T1").route)
        assert.is_not_nil(InternalDataStore.get(HubCeTypes.TrainStatic, "T2"))
    end)

    it("sends train dynamic data only for selected train ids", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local DynamicUpdateRegistry = require("ce.hub.data.dynamic.DynamicUpdateRegistry")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

        EepSimulator.simulateAddTrain("T1", "RS1")
        EepSimulator.simulateAddTrain("T2", "RS2")

        local train1 = TrainRegistry.forName("T1")
        TrainRegistry.forName("T2")

        DynamicUpdateRegistry.startUpdatesFor(HubCeTypes.TrainDynamic, "T1")
        TrainRegistry.fireChangeTrainEvents({ [HubCeTypes.TrainDynamic] = true })

        assert.is_not_nil(InternalDataStore.get(HubCeTypes.TrainDynamic, "T1"))
        assert.is_nil(InternalDataStore.get(HubCeTypes.TrainDynamic, "T2"))

        train1:setSpeed(12)
        TrainRegistry.fireChangeTrainEvents({ [HubCeTypes.TrainDynamic] = true })

        assert.same(12.0, InternalDataStore.get(HubCeTypes.TrainDynamic, "T1").speed)
    end)
end)
