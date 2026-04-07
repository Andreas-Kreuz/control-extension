if CeDebugLoad then print("[#Start] Loading ce.hub.data.slots.DataSlotsRegistry ...") end

local DataSlotsRegistry = {}

local filledSlots = {}
local emptySlots = {}

function DataSlotsRegistry.set(filled, empty)
    filledSlots = filled or {}
    emptySlots = empty or {}
end

function DataSlotsRegistry.getFilled()
    return filledSlots
end

function DataSlotsRegistry.getEmpty()
    return emptySlots
end

return DataSlotsRegistry
