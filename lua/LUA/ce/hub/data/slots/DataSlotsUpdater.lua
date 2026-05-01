if CeDebugLoad then print("[#Start] Loading ce.hub.data.slots.DataSlotsUpdater ...") end

local DataSlotNameResolver = require("ce.hub.data.slots.DataSlotNameResolver")
local DataSlotsRegistry = require("ce.hub.data.slots.DataSlotsRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local StorageUtility = require("ce.hub.util.StorageUtility")

local DataSlotsUpdater = {}

function DataSlotsUpdater.runUpdate()
    if not HubOptionsRegistry.isAnyDiscoveryAndUpdateEnabled("saveSlots", "freeSlots") then return end

    local filledSlots = {}
    local emptySlots = {}

    DataSlotNameResolver.updateSlotNames()
    for id = 1, 1000 do
        local hResult, data = EEPLoadData(id)
        if hResult then
            local name = DataSlotNameResolver.getSlotName(id) or StorageUtility.getName(id) or "?"
            filledSlots[id] = { id = id, name = name, data = data }
        else
            emptySlots[id] = { id = id }
        end
    end

    DataSlotsRegistry.set(filledSlots, emptySlots)
end

return DataSlotsUpdater
