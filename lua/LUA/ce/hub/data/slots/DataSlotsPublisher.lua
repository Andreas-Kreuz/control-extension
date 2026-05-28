if CeDebugLoad then print("[#Start] Loading ce.hub.data.slots.DataSlotsPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local DataSlotDtoFactory = require("ce.hub.data.slots.DataSlotDtoFactory")
local DataSlotsRegistry = require("ce.hub.data.slots.DataSlotsRegistry")

local DataSlotsPublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

local function publishRemovedSlots(ceType, removedIds)
    for slotId in pairs(removedIds) do
        DataChangeBus.fireDataRemoved(DataSlotDtoFactory.createRemovalDto(ceType, slotId))
    end
end

local function publishSlots(ceType, slots)
    local hasSlot = false
    local allSlotsNeedFullSend = true
    for _, slot in pairs(slots) do
        hasSlot = true
        if not slot.needsFullSend then allSlotsNeedFullSend = false end
    end

    if hasSlot and allSlotsNeedFullSend then
        if ceType == DataSlotDtoFactory.filledCeType() then
            DataChangeBus.fireListChange(DataSlotDtoFactory.createFilledDataSlotDtoList(slots))
        else
            DataChangeBus.fireListChange(DataSlotDtoFactory.createEmptyDataSlotDtoList(slots))
        end
        for _, slot in pairs(slots) do
            slot.needsFullSend = false
            slot:resetDirty()
        end
        return
    end

    for _, slot in pairs(slots) do
        if slot.needsFullSend then
            DataChangeBus.fireDataChanged(DataSlotDtoFactory.createFullDto(ceType, slot))
            slot.needsFullSend = false
            slot:resetDirty()
        elseif slot:hasDirtyFields() then
            local dtoCeType, keyId, key, dto = DataSlotDtoFactory.createPatchDto(ceType, slot, slot.dirtyFields)
            if hasPayloadFields(dto) then DataChangeBus.fireDataChanged(dtoCeType, keyId, key, dto) end
            slot:resetDirty()
        end
    end
end

function DataSlotsPublisher.syncState()
    local filledCeType = DataSlotDtoFactory.filledCeType()
    local emptyCeType = DataSlotDtoFactory.emptyCeType()

    publishRemovedSlots(filledCeType, DataSlotsRegistry.getRemovedFilledIds())
    publishRemovedSlots(emptyCeType, DataSlotsRegistry.getRemovedEmptyIds())
    DataSlotsRegistry.clearRemoved()

    publishSlots(filledCeType, DataSlotsRegistry.getFilled())
    publishSlots(emptyCeType, DataSlotsRegistry.getEmpty())
end

return DataSlotsPublisher
