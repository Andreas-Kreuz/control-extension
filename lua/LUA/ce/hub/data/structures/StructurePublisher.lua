if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructurePublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local StructureDtoFactory = require("ce.hub.data.structures.StructureDtoFactory")
local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local StructurePublisher = {}

function StructurePublisher.syncState(options)
    local opts = options or {}
    local ceTypeOptions = opts.ceTypes and opts.ceTypes.structure or nil
    if not SyncPolicy.isActive(ceTypeOptions, false) then
        StructureRegistry.clearPendingChanges()
        return {}
    end

    local addedIds = StructureRegistry.getAddedIds()
    local removedIds = StructureRegistry.getRemovedIds()

    for structureId in pairs(addedIds) do
        local structure = StructureRegistry.forId(structureId)
        if structure then
            DataChangeBus.fireDataAdded(StructureDtoFactory.createFullDto(structure, true))
            structure.needsFullSend = false
            structure:resetDirty()
        end
    end

    for structureId in pairs(removedIds) do
        DataChangeBus.fireDataRemoved(StructureDtoFactory.createRefDto(structureId))
    end

    for structureId, structure in pairs(StructureRegistry.getAll()) do
        if not addedIds[structureId] and (structure.needsFullSend or structure:hasDirtyFields()) then
            if structure.needsFullSend then
                DataChangeBus.fireDataChanged(StructureDtoFactory.createFullDto(structure, true))
                structure.needsFullSend = false
            else
                DataChangeBus.fireDataChanged(
                    StructureDtoFactory.createPatchDto(structure, structure.dirtyFields, true)
                )
            end
            structure:resetDirty()
        end
    end

    StructureRegistry.clearPendingChanges()
    return {}
end

return StructurePublisher
