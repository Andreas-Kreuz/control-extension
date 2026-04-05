-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/structures/StructureStaticLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureStaticDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local StructureStaticDtoFactory = {}

local CE_TYPE = HubCeTypes.StructureStatic
local KEY_ID = "id"

local function toStructureStaticDto(structure)
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
        tag = structure.tag
    }
end

function StructureStaticDtoFactory.createDto(structure)
    local dto = toStructureStaticDto(structure)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function StructureStaticDtoFactory.createDtoList(structures)
    local structureDtos = {}
    for i = 1, #structures do
        local _, _, _, dto = StructureStaticDtoFactory.createDto(structures[i])
        structureDtos[i] = dto
    end
    return CE_TYPE, KEY_ID, structureDtos
end

function StructureStaticDtoFactory.createRefDto(structureId)
    local dto = { ceType = CE_TYPE, id = structureId }
    return CE_TYPE, KEY_ID, structureId, dto
end

return StructureStaticDtoFactory
