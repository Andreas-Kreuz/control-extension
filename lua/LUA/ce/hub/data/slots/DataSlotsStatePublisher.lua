if CeDebugLoad then print("[#Start] Loading ce.hub.data.slots.DataSlotsStatePublisher ...") end
local DataSlotsPublisher = require("ce.hub.data.slots.DataSlotsPublisher")

local DataSlotsStatePublisher = {}
DataSlotsStatePublisher.name = "ce.hub.data.slots.DataSlotsStatePublisher"
DataSlotsStatePublisher.enabled = true
local initialized = false

DataSlotsStatePublisher.options = {
    ceTypes = {
        saveSlots = { ceType = "ce.hub.SaveSlot", mode = "all" },
        freeSlots = { ceType = "ce.hub.FreeSlot", mode = "all" }
    }
}

function DataSlotsStatePublisher.initialize()
    initialized = true
end

function DataSlotsStatePublisher.syncState()
    -- nothing todo
    if not DataSlotsStatePublisher.enabled then return end
    if not initialized then DataSlotsStatePublisher.initialize() end
    return DataSlotsPublisher.syncState()
end

return DataSlotsStatePublisher
