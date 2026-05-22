if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureRegistry ...") end

---@class StructureRegistry
---@field has fun(structureId: string):boolean
---@field add fun(structure: Structure):nil
---@field replaceAll fun(structures: Structure[]):nil
---@field remove fun(structureId: string):nil
---@field forId fun(structureId: string):Structure|nil
---@field forName fun(structureName: string):Structure|nil
---@field getAll fun():table<string, Structure>
---@field getAddedIds fun():table<string, boolean>
---@field getRemovedIds fun():table<string, boolean>
---@field clearPendingChanges fun():nil
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

function StructureRegistry.replaceAll(structures)
    local nextStructures = {}
    local nextIds = {}

    for _, structure in ipairs(structures or {}) do
        nextStructures[structure.id] = structure
        nextIds[structure.id] = true
        if allStructures[structure.id] == nil then
            addedStructureIds[structure.id] = true
        end
        removedStructureIds[structure.id] = nil
    end

    for structureId in pairs(allStructures) do
        if not nextIds[structureId] then
            if addedStructureIds[structureId] then
                addedStructureIds[structureId] = nil
            else
                removedStructureIds[structureId] = true
            end
        end
    end

    allStructures = nextStructures
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

function StructureRegistry.forName(structureName)
    for _, structure in pairs(allStructures) do
        if structure.name == structureName then return structure end
    end
    return nil
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
