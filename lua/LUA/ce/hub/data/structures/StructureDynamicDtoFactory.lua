-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/structures/StructureDynamicLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureDynamicDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local StructureDynamicDtoFactory = {}

local CE_TYPE = HubCeTypes.StructureDynamic
local KEY_ID = "id"

local function toStructureDynamicDto(structure)
    return {
        ceType = CE_TYPE,
        id = structure.id,
        light = structure:getLight(),
        smoke = structure:getSmoke(),
        fire = structure:getFire()
    }
end

function StructureDynamicDtoFactory.createDto(structure)
    local dto = toStructureDynamicDto(structure)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function StructureDynamicDtoFactory.createDtoList(structures)
    local structureDtos = {}
    for i = 1, #structures do
        local _, _, _, dto = StructureDynamicDtoFactory.createDto(structures[i])
        structureDtos[i] = dto
    end
    return CE_TYPE, KEY_ID, structureDtos
end

function StructureDynamicDtoFactory.createRefDto(structureId)
    local dto = { ceType = CE_TYPE, id = structureId }
    return CE_TYPE, KEY_ID, structureId, dto
end

return StructureDynamicDtoFactory
