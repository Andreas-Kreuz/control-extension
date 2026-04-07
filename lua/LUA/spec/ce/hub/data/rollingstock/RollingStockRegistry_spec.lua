insulate("ce.hub.data.rollingstock.RollingStockRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.data.DynamicUpdateRegistry")
        clearModule("ce.hub.data.rollingstock.RollingStock")
        clearModule("ce.hub.data.rollingstock.RollingStockPublisher")
        clearModule("ce.hub.data.rollingstock.RollingStockRegistry")
        clearModule("ce.hub.data.rollingstock.RollingStockDtoFactory")
        clearModule("ce.hub.publish.DataChangeBus")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")

        require("ce.hub.eep.EepSimulator")
    end)

    it("sends full DTOs initially and patches on changes", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local RollingStockPublisher = require("ce.hub.data.rollingstock.RollingStockPublisher")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")

        EepSimulator.simulateAddTrain("T1", "RS1", "RS2")
        local rollingStock1 = RollingStockRegistry.forName("RS1")
        RollingStockRegistry.forName("RS2")

        RollingStockPublisher.syncState({
            ceTypes = {
                rollingStock = { ceType = HubCeTypes.RollingStock, mode = "all" }
            }
        })

        assert.is_not_nil(InternalDataStore.get(HubCeTypes.RollingStock, "RS1"))
        assert.is_not_nil(InternalDataStore.get(HubCeTypes.RollingStock, "RS2"))

        rollingStock1:setTrainName("T1")
        RollingStockPublisher.syncState({
            ceTypes = {
                rollingStock = { ceType = HubCeTypes.RollingStock, mode = "all" }
            }
        })

        assert.equals("T1", InternalDataStore.get(HubCeTypes.RollingStock, "RS1").trainName)
        assert.is_not_nil(InternalDataStore.get(HubCeTypes.RollingStock, "RS2"))
    end)

    it("sends ondemand fields only for selected ids", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local RollingStockPublisher = require("ce.hub.data.rollingstock.RollingStockPublisher")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")

        EepSimulator.simulateAddTrain("T1", "RS1", "RS2")
        local rollingStock1 = RollingStockRegistry.forName("RS1")
        RollingStockRegistry.forName("RS2")

        DynamicUpdateRegistry.startUpdatesFor(HubCeTypes.RollingStock, "RS1")
        RollingStockPublisher.syncState({
            ceTypes = {
                rollingStock = { ceType = HubCeTypes.RollingStock, mode = "selected" }
            }
        })

        assert.is_not_nil(InternalDataStore.get(HubCeTypes.RollingStock, "RS1"))

        rollingStock1:setMileage(1234)
        RollingStockPublisher.syncState({
            ceTypes = {
                rollingStock = { ceType = HubCeTypes.RollingStock, mode = "selected" }
            }
        })

        assert.equals(1234, InternalDataStore.get(HubCeTypes.RollingStock, "RS1").mileage)
    end)

    it("fires single DataRemoved on disappearance", function ()
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local RollingStockPublisher = require("ce.hub.data.rollingstock.RollingStockPublisher")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")

        local removed = {}
        local originalFireDataRemoved = DataChangeBus.fireDataRemoved
        DataChangeBus.fireDataRemoved = function (ceType, keyId, key, dto)
            table.insert(removed, { ceType = ceType, keyId = keyId, key = key, dto = dto })
            return originalFireDataRemoved(ceType, keyId, key, dto)
        end

        EepSimulator.simulateAddTrain("T1", "RS1")
        RollingStockRegistry.forName("RS1")
        RollingStockPublisher.syncState({
            ceTypes = {
                rollingStock = { ceType = HubCeTypes.RollingStock, mode = "all" }
            }
        })

        RollingStockRegistry.remove("RS1")
        RollingStockPublisher.syncState({
            ceTypes = {
                rollingStock = { ceType = HubCeTypes.RollingStock, mode = "all" }
            }
        })

        assert.equals(1, #removed)
        assert.equals(HubCeTypes.RollingStock, removed[1].ceType)
        assert.equals("RS1", removed[1].key)
    end)
end)
