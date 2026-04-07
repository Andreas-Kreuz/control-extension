if CeDebugLoad then print("[#Start] Loading ce.hub.data.slots.DataSlotsUpdater ...") end

local DataSlotNameResolver = require("ce.hub.data.slots.DataSlotNameResolver")
local DataSlotsRegistry = require("ce.hub.data.slots.DataSlotsRegistry")
local StorageUtility = require("ce.hub.util.StorageUtility")

local DataSlotsUpdater = {}

local lastSlots = {}

local function updateSlot(id, name, data)
    local oldSlot = lastSlots[id]
    local newSlot = { id = id, name = name, data = data }
    if not oldSlot or oldSlot.id ~= id or oldSlot.name ~= name or oldSlot.data ~= data then lastSlots[id] = newSlot end
    return newSlot
end

function DataSlotsUpdater.runUpdate()
    local filledSlots = {}
    local emptySlots = {}

    DataSlotNameResolver.updateSlotNames()
    for id = 1, 1000 do
        local hResult, data = EEPLoadData(id)
        if hResult then
            local name = DataSlotNameResolver.getSlotName(id) or StorageUtility.getName(id) or "?"
            filledSlots[id] = updateSlot(id, name, data)
        else
            emptySlots[id] = updateSlot(id)
        end
    end

    DataSlotsRegistry.set(filledSlots, emptySlots)
end

return DataSlotsUpdater
