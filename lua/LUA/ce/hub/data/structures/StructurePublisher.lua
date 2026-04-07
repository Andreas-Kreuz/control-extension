if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructurePublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local StructureDtoFactory = require("ce.hub.data.structures.StructureDtoFactory")
local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
local StructurePublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

function StructurePublisher.syncState()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")
    if not HubOptionsRegistry.isPublishEnabled("structures") then
        StructureRegistry.clearPendingChanges()
        return {}
    end

    local addedIds = StructureRegistry.getAddedIds()
    local removedIds = StructureRegistry.getRemovedIds()

    for structureId in pairs(addedIds) do
        local structure = StructureRegistry.forId(structureId)
        if structure then
            local isSelected = DynamicUpdateRegistry.isSelected(HubCeTypes.Structure, tostring(structure.id))
            DataChangeBus.fireDataAdded(StructureDtoFactory.createFullDto(structure, isSelected))
            structure.needsFullSend = false
            structure:resetDirty()
        end
    end

    for structureId in pairs(removedIds) do
        DataChangeBus.fireDataRemoved(StructureDtoFactory.createRefDto(structureId))
    end

    for structureId, structure in pairs(StructureRegistry.getAll()) do
        local isSelected = DynamicUpdateRegistry.isSelected(HubCeTypes.Structure, tostring(structure.id))
        local needsInitialSend = DynamicUpdateRegistry.needsInitialSend(HubCeTypes.Structure, tostring(structure.id))
        if not addedIds[structureId]
            and (structure.needsFullSend or structure:hasDirtyFields() or needsInitialSend) then
            if structure.needsFullSend or needsInitialSend then
                DataChangeBus.fireDataChanged(StructureDtoFactory.createFullDto(structure, isSelected))
                structure.needsFullSend = false
                if isSelected then DynamicUpdateRegistry.markSent(HubCeTypes.Structure, tostring(structure.id)) end
            else
                local ceType, keyId, key, dto = StructureDtoFactory.createPatchDto(structure, structure.dirtyFields,
                                                                                   isSelected)
                if hasPayloadFields(dto) then
                    DataChangeBus.fireDataChanged(ceType, keyId, key, dto)
                end
            end
            structure:resetDirty()
        end
    end

    StructureRegistry.clearPendingChanges()
    return {}
end

return StructurePublisher
