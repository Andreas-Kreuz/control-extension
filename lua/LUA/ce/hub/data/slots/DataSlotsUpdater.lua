if CeDebugLoad then print("[#Start] Loading ce.hub.data.slots.DataSlotsUpdater ...") end

local DataSlot = require("ce.hub.data.slots.DataSlot")
local DataSlotNameResolver = require("ce.hub.data.slots.DataSlotNameResolver")
local DataSlotsRegistry = require("ce.hub.data.slots.DataSlotsRegistry")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local StorageUtility = require("ce.hub.util.StorageUtility")

local DataSlotsUpdater = {}

local MIN_SLOT_ID = 1
local MAX_SLOT_ID = 1000
local BATCH_SIZE = 100
local nextBatchStart = MIN_SLOT_ID

local function addSelectedSlotIds(slotIds, ceType)
    for key in pairs(InterestSyncRegistry.getSelectedKeys(ceType)) do
        local slotId = tonumber(key)
        if slotId and slotId >= MIN_SLOT_ID and slotId <= MAX_SLOT_ID then
            slotIds[slotId] = true
        end
    end
end

local function collectSlotIdsForRun()
    local slotIds = {}
    local batchEnd = math.min(nextBatchStart + BATCH_SIZE - 1, MAX_SLOT_ID)

    for id = nextBatchStart, batchEnd do slotIds[id] = true end
    nextBatchStart = batchEnd + 1
    if nextBatchStart > MAX_SLOT_ID then nextBatchStart = MIN_SLOT_ID end

    addSelectedSlotIds(slotIds, HubCeTypes.SaveSlot)
    addSelectedSlotIds(slotIds, HubCeTypes.FreeSlot)

    return slotIds
end

function DataSlotsUpdater.runUpdate()
    if not HubOptionsRegistry.isAnyDiscoveryAndUpdateEnabled("saveSlots", "freeSlots") then return end

    local filledSlots = {}
    local emptySlots = {}

    DataSlotNameResolver.updateSlotNames()
    for id in pairs(collectSlotIdsForRun()) do
        local slot, filled = DataSlot.loadFromEep(id, DataSlotNameResolver, StorageUtility)
        if filled then
            filledSlots[id] = slot
        else
            emptySlots[id] = slot
        end
    end

    DataSlotsRegistry.update(filledSlots, emptySlots)
end

return DataSlotsUpdater
