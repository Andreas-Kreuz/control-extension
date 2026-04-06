-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/structures/StructureLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local StructureDtoFactory = {}

local CE_TYPE = HubCeTypes.Structure
local KEY_ID = "id"

local function toFullDto(structure)
    return {
        ceType = CE_TYPE,
        id = structure.id,
        name = structure.name,
        pos_x = structure.pos_x,
        pos_y = structure.pos_y,
        pos_z = structure.pos_z,
        rot_x = structure.rot_x,
        rot_y = structure.rot_y,
        rot_z = structure.rot_z,
        modelType = structure.modelType,
        modelTypeText = structure.modelTypeText,
        tag = structure:getTag(),
        light = structure:getLight(),
        smoke = structure:getSmoke(),
        fire = structure:getFire()
    }
end

local fieldGetters = {
    tag = function(s) return s:getTag() end,
    light = function(s) return s:getLight() end,
    smoke = function(s) return s:getSmoke() end,
    fire = function(s) return s:getFire() end,
}

local function toPatchDto(structure, dirtyFields)
    local dto = {
        ceType = CE_TYPE,
        id = structure.id,
    }
    for field in pairs(dirtyFields) do
        local getter = fieldGetters[field]
        if getter then
            dto[field] = getter(structure)
        end
    end
    return dto
end

function StructureDtoFactory.createFullDto(structure)
    local dto = toFullDto(structure)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function StructureDtoFactory.createPatchDto(structure, dirtyFields)
    local dto = toPatchDto(structure, dirtyFields)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function StructureDtoFactory.createRefDto(structureId)
    local dto = { ceType = CE_TYPE, id = structureId }
    return CE_TYPE, KEY_ID, structureId, dto
end

return StructureDtoFactory
