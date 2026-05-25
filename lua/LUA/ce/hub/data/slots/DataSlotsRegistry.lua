if CeDebugLoad then print("[#Start] Loading ce.hub.data.slots.DataSlotsRegistry ...") end

local DataSlot = require("ce.hub.data.slots.DataSlot")

local DataSlotsRegistry = {}

local filledSlots = {}
local emptySlots = {}
local removedFilledSlotIds = {}
local removedEmptySlotIds = {}

local function updateSlot(targetSlots, sourceSlot, slotType)
    local slotId = sourceSlot.id
    local existingSlot = filledSlots[slotId] or emptySlots[slotId]
    if existingSlot then
        if existingSlot.slotType ~= slotType then
            if existingSlot.slotType == "filled" then
                removedFilledSlotIds[slotId] = true
                filledSlots[slotId] = nil
            else
                removedEmptySlotIds[slotId] = true
                emptySlots[slotId] = nil
            end
            existingSlot:setSlotType(slotType)
        end
        existingSlot:update(sourceSlot)
        targetSlots[slotId] = existingSlot
    else
        sourceSlot.slotType = slotType
        targetSlots[slotId] = DataSlot:new(sourceSlot)
    end
end

local function removeMissingSlots(currentIds)
    for slotId in pairs(filledSlots) do
        if not currentIds[slotId] then
            filledSlots[slotId] = nil
            removedFilledSlotIds[slotId] = true
        end
    end

    for slotId in pairs(emptySlots) do
        if not currentIds[slotId] then
            emptySlots[slotId] = nil
            removedEmptySlotIds[slotId] = true
        end
    end
end

local function updateSlots(filled, empty, removeMissing)
    local nextFilledSlots = removeMissing and {} or filledSlots
    local nextEmptySlots = removeMissing and {} or emptySlots
    local currentIds = {}

    for _, sourceSlot in pairs(filled or {}) do
        currentIds[sourceSlot.id] = true
        updateSlot(nextFilledSlots, sourceSlot, "filled")
    end

    for _, sourceSlot in pairs(empty or {}) do
        currentIds[sourceSlot.id] = true
        updateSlot(nextEmptySlots, sourceSlot, "empty")
    end

    if removeMissing then removeMissingSlots(currentIds) end
    filledSlots = nextFilledSlots
    emptySlots = nextEmptySlots
end

function DataSlotsRegistry.set(filled, empty)
    updateSlots(filled, empty, true)
end

function DataSlotsRegistry.update(filled, empty)
    updateSlots(filled, empty, false)
end

function DataSlotsRegistry.getFilled()
    return filledSlots
end

function DataSlotsRegistry.getEmpty()
    return emptySlots
end

function DataSlotsRegistry.get(slotType, slotId)
    local slots = slotType == "filled" and filledSlots or emptySlots
    return slots[slotId]
end

function DataSlotsRegistry.getRemovedFilledIds()
    local copy = {}
    for slotId in pairs(removedFilledSlotIds) do copy[slotId] = true end
    return copy
end

function DataSlotsRegistry.getRemovedEmptyIds()
    local copy = {}
    for slotId in pairs(removedEmptySlotIds) do copy[slotId] = true end
    return copy
end

function DataSlotsRegistry.clearRemoved()
    removedFilledSlotIds = {}
    removedEmptySlotIds = {}
end

return DataSlotsRegistry
