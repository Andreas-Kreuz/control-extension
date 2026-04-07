insulate("ce.hub.data.slots.DataSlotsStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local originalLoadData = _G.EEPLoadData

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

        rawset(_G, "EEPLoadData", function (id)
            if id == 1 then return true, "payload-1" end
            return false, nil
        end)
    end)

    after_each(function ()
        rawset(_G, "EEPLoadData", originalLoadData)
    end)

    it("fires save-slot and free-slot ceTypes with the existing wire format", function ()
        local DataSlotsStatePublisher = require("ce.hub.data.slots.DataSlotsStatePublisher")
        local DataSlotsUpdater = require("ce.hub.data.slots.DataSlotsUpdater")
        local DataSlotNameResolver = require("ce.hub.data.slots.DataSlotNameResolver")
        local StorageUtility = require("ce.hub.util.StorageUtility")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        DataSlotNameResolver.updateSlotNames = function () end
        DataSlotNameResolver.getSlotName = function (id)
            if id == 1 then return "Named Slot" end
            return nil
        end
        StorageUtility.getName = function () return nil end

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
end)
