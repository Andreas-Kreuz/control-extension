insulate("ce.hub.data.slots.DataSlotsStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local eepLoadDataStub

    before_each(function ()
        clearModule("ce.hub.data.slots.DataSlotsStatePublisher")
        clearModule("ce.hub.data.slots.DataSlotDtoFactory")
        clearModule("ce.hub.data.slots.DataSlotNameResolver")
        clearModule("ce.hub.util.StorageUtility")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.hub.publish.DataChangeBus")
        clearModule("ce.hub.data.slots.DataSlotsRegistry")
        clearModule("ce.hub.data.slots.DataSlotsUpdater")
        clearModule("ce.hub.data.InterestSyncRegistry")

        eepLoadDataStub = stub(_G, "EEPLoadData", function (id)
            if id == 1 then return true, "payload-1" end
            return false, nil
        end)
    end)

    after_each(function ()
        eepLoadDataStub:revert()
    end)

    it("fires save-slot and free-slot ceTypes with the existing wire format", function ()
        local DataSlotsStatePublisher = require("ce.hub.data.slots.DataSlotsStatePublisher")
        local DataSlotsUpdater = require("ce.hub.data.slots.DataSlotsUpdater")
        local DataSlotNameResolver = require("ce.hub.data.slots.DataSlotNameResolver")
        local StorageUtility = require("ce.hub.util.StorageUtility")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        local updateSlotNamesStub = stub(DataSlotNameResolver, "updateSlotNames", function () end)
        local getSlotNameStub = stub(DataSlotNameResolver, "getSlotName", function (id)
            if id == 1 then return "Named Slot" end
            return nil
        end)
        local getNameStub = stub(StorageUtility, "getName", function () return nil end)
        finally(function () updateSlotNamesStub:revert() end)
        finally(function () getSlotNameStub:revert() end)
        finally(function () getNameStub:revert() end)

        DataSlotsUpdater.runUpdate()
        DataSlotsStatePublisher.syncState()

        assert.same({
                        ["1"] = {
                            ceType = "ce.hub.SaveSlot",
                            id = 1,
                            name = "Named Slot",
                            data = "payload-1"
                        }
                    }, DataStore.getCeType("ce.hub.SaveSlot"))
        assert.same({
                        ["2"] = {
                            ceType = "ce.hub.FreeSlot",
                            id = 2
                        }
                    }, { ["2"] = DataStore.get("ce.hub.FreeSlot", 2) })
    end)

    it("loads alternating batches and always includes selected slots", function ()
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
        local DataSlotsRegistry = require("ce.hub.data.slots.DataSlotsRegistry")
        local DataSlotsUpdater = require("ce.hub.data.slots.DataSlotsUpdater")

        local loadedIds = {}
        eepLoadDataStub:revert()
        eepLoadDataStub = stub(_G, "EEPLoadData", function (id)
            loadedIds[#loadedIds + 1] = id
            if id == 250 then return true, "selected-payload" end
            return false, nil
        end)
        InterestSyncRegistry.startSyncFor(HubCeTypes.SaveSlot, "250")

        DataSlotsUpdater.runUpdate()

        assert.equals(101, #loadedIds)
        assert.is_true(DataSlotsRegistry.getFilled()[250] ~= nil)
        assert.is_true(DataSlotsRegistry.getEmpty()[1] ~= nil)
        assert.is_true(DataSlotsRegistry.getEmpty()[100] ~= nil)

        loadedIds = {}
        DataSlotsUpdater.runUpdate()

        assert.equals(101, #loadedIds)
        assert.is_true(DataSlotsRegistry.getEmpty()[1] ~= nil)
        assert.is_true(DataSlotsRegistry.getEmpty()[101] ~= nil)
        assert.is_true(DataSlotsRegistry.getEmpty()[200] ~= nil)
        assert.is_true(DataSlotsRegistry.getFilled()[250] ~= nil)
    end)
end)
