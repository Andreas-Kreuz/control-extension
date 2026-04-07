if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureRegistry ...") end

local StructureRegistry = {}

---@type table<string, Structure>
local allStructures = {}
local addedStructureIds = {}
local removedStructureIds = {}

function StructureRegistry.has(structureId)
    return allStructures[structureId] ~= nil
end

function StructureRegistry.add(structure)
    assert(type(structure) == "table", "Need structure as table")
    assert(type(structure.id) == "string", "Need structure.id as string")
    allStructures[structure.id] = structure
    addedStructureIds[structure.id] = true
    removedStructureIds[structure.id] = nil
end

function StructureRegistry.remove(structureId)
    if allStructures[structureId] == nil then return end
    allStructures[structureId] = nil
    if addedStructureIds[structureId] then
        addedStructureIds[structureId] = nil
        return
    end
    removedStructureIds[structureId] = true
end

function StructureRegistry.forId(structureId)
    return allStructures[structureId]
end

function StructureRegistry.getAll()
    local copy = {}
    for structureId, structure in pairs(allStructures) do
        copy[structureId] = structure
    end
    return copy
end

function StructureRegistry.getAddedIds()
    local copy = {}
    for structureId in pairs(addedStructureIds) do
        copy[structureId] = true
    end
    return copy
end

function StructureRegistry.getRemovedIds()
    local copy = {}
    for structureId in pairs(removedStructureIds) do
        copy[structureId] = true
    end
    return copy
end

function StructureRegistry.clearPendingChanges()
    addedStructureIds = {}
    removedStructureIds = {}
end

return StructureRegistry
