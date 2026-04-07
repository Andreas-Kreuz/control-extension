insulate("ce.hub.data.trains.TrainRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.data.DynamicUpdateRegistry")
        clearModule("ce.hub.data.trains.Train")
        clearModule("ce.hub.data.trains.TrainPublisher")
        clearModule("ce.hub.data.trains.TrainRegistry")
        clearModule("ce.hub.data.trains.TrainDtoFactory")
        clearModule("ce.hub.data.rollingstock.RollingStock")
        clearModule("ce.hub.data.rollingstock.RollingStockRegistry")
        clearModule("ce.hub.publish.DataChangeBus")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")

        require("ce.hub.eep.EepSimulator")
    end)

    it("sends full DTOs on initial send and patches on subsequent changes", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local TrainPublisher = require("ce.hub.data.trains.TrainPublisher")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

        EepSimulator.simulateAddTrain("T1", "RS1")
        EepSimulator.simulateAddTrain("T2", "RS2")

        local train1 = TrainRegistry.forName("T1")
        TrainRegistry.forName("T2")

        TrainPublisher.syncState({
            ceTypes = {
                train = { ceType = HubCeTypes.Train, mode = "all" }
            }
        })

        assert.is_not_nil(InternalDataStore.get(HubCeTypes.Train, "T1"))
        assert.is_not_nil(InternalDataStore.get(HubCeTypes.Train, "T2"))

        train1:setRoute("R1")
        TrainPublisher.syncState({
            ceTypes = {
                train = { ceType = HubCeTypes.Train, mode = "all" }
            }
        })

        assert.same("R1", InternalDataStore.get(HubCeTypes.Train, "T1").route)
        assert.is_not_nil(InternalDataStore.get(HubCeTypes.Train, "T2"))
    end)

    it("sends ondemand fields with real values only for selected trains", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local TrainPublisher = require("ce.hub.data.trains.TrainPublisher")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

        EepSimulator.simulateAddTrain("T1", "RS1")
        EepSimulator.simulateAddTrain("T2", "RS2")

        local train1 = TrainRegistry.forName("T1")
        TrainRegistry.forName("T2")

        DynamicUpdateRegistry.startUpdatesFor(HubCeTypes.Train, "T1")
        TrainPublisher.syncState({
            ceTypes = {
                train = { ceType = HubCeTypes.Train, mode = "selected" }
            }
        })

        -- T1 is selected, should have real speed value
        assert.is_not_nil(InternalDataStore.get(HubCeTypes.Train, "T1"))

        train1:setSpeed(12)
        TrainPublisher.syncState({
            ceTypes = {
                train = { ceType = HubCeTypes.Train, mode = "selected" }
            }
        })

        assert.same(12.0, InternalDataStore.get(HubCeTypes.Train, "T1").speed)
    end)

    it("sends all trains in all mode", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local TrainPublisher = require("ce.hub.data.trains.TrainPublisher")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

        EepSimulator.simulateAddTrain("T1", "RS1")
        EepSimulator.simulateAddTrain("T2", "RS2")

        TrainRegistry.forName("T1")
        TrainRegistry.forName("T2")

        TrainPublisher.syncState({
            ceTypes = {
                train = { ceType = HubCeTypes.Train, mode = "all" }
            }
        })

        assert.is_not_nil(InternalDataStore.get(HubCeTypes.Train, "T1"))
        assert.is_not_nil(InternalDataStore.get(HubCeTypes.Train, "T2"))
    end)
end)
