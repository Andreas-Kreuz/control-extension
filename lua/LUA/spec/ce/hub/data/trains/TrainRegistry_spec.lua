---@diagnostic disable: redundant-parameter
insulate("ce.hub.data.trains.TrainRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.data.InterestSyncRegistry")
        clearModule("ce.hub.data.trains.Train")
        clearModule("ce.hub.data.trains.TrainPublisher")
        clearModule("ce.hub.data.trains.TrainRegistry")
        clearModule("ce.hub.data.trains.TrainDtoFactory")
        clearModule("ce.hub.FullSyncMarker")
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

        local train1 = TrainRegistry.getOrCreate("T1")
        TrainRegistry.getOrCreate("T2")

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

    it("publishes train baseline as a list and later sends changed fields only", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local TrainPublisher = require("ce.hub.data.trains.TrainPublisher")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local listChanges = {}
        local dataAdded = {}
        local dataChanges = {}

        local fireListChangeStub = stub(DataChangeBus, "fireListChange", function (ceType, keyId, list)
            table.insert(listChanges, { ceType = ceType, keyId = keyId, list = list })
        end)
        local fireDataAddedStub = stub(DataChangeBus, "fireDataAdded", function (ceType, keyId, key, dto)
            table.insert(dataAdded, { ceType = ceType, keyId = keyId, key = key, dto = dto })
        end)
        local fireDataChangedStub = stub(DataChangeBus, "fireDataChanged", function (ceType, keyId, key, dto)
            table.insert(dataChanges, { ceType = ceType, keyId = keyId, key = key, dto = dto })
        end)
        finally(function () fireListChangeStub:revert() end)
        finally(function () fireDataAddedStub:revert() end)
        finally(function () fireDataChangedStub:revert() end)

        EepSimulator.simulateAddTrain("T1", "RS1")
        EepSimulator.simulateAddTrain("T2", "RS2")

        local train1 = TrainRegistry.getOrCreate("T1")
        TrainRegistry.getOrCreate("T2")

        TrainPublisher.syncState()

        assert.equals(1, #listChanges)
        assert.equals(2, #listChanges[1].list)
        assert.equals(0, #dataAdded)
        assert.equals(0, #dataChanges)

        train1:updateRoute("Changed Route")
        TrainPublisher.syncState()

        assert.equals(1, #dataChanges)
        assert.same({
                        ceType = "ce.hub.Train",
                        id = "T1",
                        route = "Changed Route"
                    }, dataChanges[1].dto)
    end)

    it("publishes train full-sync requests as a single list baseline", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local FullSyncMarker = require("ce.hub.FullSyncMarker")
        local TrainPublisher = require("ce.hub.data.trains.TrainPublisher")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local listChanges = {}
        local dataChanges = {}

        local fireListChangeStub = stub(DataChangeBus, "fireListChange", function (ceType, keyId, list)
            table.insert(listChanges, { ceType = ceType, keyId = keyId, list = list })
        end)
        local fireDataChangedStub = stub(DataChangeBus, "fireDataChanged", function (ceType, keyId, key, dto)
            table.insert(dataChanges, { ceType = ceType, keyId = keyId, key = key, dto = dto })
        end)
        finally(function () fireListChangeStub:revert() end)
        finally(function () fireDataChangedStub:revert() end)

        EepSimulator.simulateAddTrain("T1", "RS1")
        TrainRegistry.getOrCreate("T1")

        TrainPublisher.syncState()
        FullSyncMarker.requestFullSync()
        TrainPublisher.syncState()

        assert.equals(2, #listChanges)
        assert.equals(0, #dataChanges)
    end)

    it("sends ondemand fields with real values only for selected trains", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local TrainPublisher = require("ce.hub.data.trains.TrainPublisher")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

        EepSimulator.simulateAddTrain("T1", "RS1")
        EepSimulator.simulateAddTrain("T2", "RS2")

        local train1 = TrainRegistry.getOrCreate("T1")
        TrainRegistry.getOrCreate("T2")

        InterestSyncRegistry.startSyncFor(HubCeTypes.Train, "T1")
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

        TrainRegistry.getOrCreate("T1")
        TrainRegistry.getOrCreate("T2")

        TrainPublisher.syncState({
            ceTypes = {
                train = { ceType = HubCeTypes.Train, mode = "all" }
            }
        })

        assert.is_not_nil(InternalDataStore.get(HubCeTypes.Train, "T1"))
        assert.is_not_nil(InternalDataStore.get(HubCeTypes.Train, "T2"))
    end)
end)
