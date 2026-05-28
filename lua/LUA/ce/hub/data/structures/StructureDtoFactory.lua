-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/structures/StructureLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local peek = DtoFieldAccess.peek
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

---@class StructureDtoFactory
---@field createFullDto fun(structure: Structure, isSelected: boolean|nil):string,string,string|number,StructureDto
---@field createPatchDto fun(structure: Structure, dirtyFields: table<string,boolean>, isSelected: boolean|nil):string,
---string,string|number,StructureDto
---@field createRemovalDto fun(structureId: string):string,string,string|number,table
---@field createDtoList fun(structures: table<string, Structure>, isSelectedByValue: function|nil):string,string,table
local StructureDtoFactory = {}

local CE_TYPE = HubCeTypes.Structure
local KEY_ID = "id"

local function getGsbname(structure)
    if structure.peekGsbname then return structure:peekGsbname() end
    return structure.gsbname
end

-- DtoFields: class definition in StructureDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = peek(function (source) return source:peekName() end, "name"),
        placeholder = ""
    },
    pos_x = {
        getValue = peek(function (source) return source:peekPosX() end, "pos_x"),
        placeholder = 0
    },
    pos_y = {
        getValue = peek(function (source) return source:peekPosY() end, "pos_y"),
        placeholder = 0
    },
    pos_z = {
        getValue = peek(function (source) return source:peekPosZ() end, "pos_z"),
        placeholder = 0
    },
    rot_x = {
        getValue = peek(function (source) return source:peekRotX() end, "rot_x"),
        placeholder = 0
    },
    rot_y = {
        getValue = peek(function (source) return source:peekRotY() end, "rot_y"),
        placeholder = 0
    },
    rot_z = {
        getValue = peek(function (source) return source:peekRotZ() end, "rot_z"),
        placeholder = 0
    },
    modelType = {
        getValue = peek(function (source) return source:peekModelType() end, "modelType"),
        placeholder = 0
    },
    modelTypeText = {
        getValue = peek(function (source) return source:peekModelTypeText() end, "modelTypeText"),
        placeholder = ""
    },
    tag = {
        getValue = peek(function (source) return source:peekTag() end, "tag"),
        placeholder = ""
    },
    light = {
        getValue = peek(function (source) return source:peekLight() end, "light"),
        placeholder = false
    },
    smoke = {
        getValue = peek(function (source) return source:peekSmoke() end, "smoke"),
        placeholder = false
    },
    fire = {
        getValue = peek(function (source) return source:peekFire() end, "fire"),
        placeholder = false
    },
    gsbname = {
        getValue = function (structure)
            local gsbname = getGsbname(structure)
            if gsbname ~= nil and gsbname ~= "" then return gsbname end
            return nil
        end,
        placeholder = nil
    },
}

local function baseDto(structure)
    return {
        ceType = CE_TYPE,
        id = structure.id
    }
end

local function buildFullDto(structure, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("structures")
    return DtoBuilder.buildFullDto(baseDto(structure), structure, dtoFields, fieldPolicies, isSelected)
end

local function buildPatchDto(structure, dirtyFields, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("structures")
    return DtoBuilder.buildPatchDto(baseDto(structure), structure, dirtyFields, dtoFields, fieldPolicies, isSelected)
end

function StructureDtoFactory.createFullDto(structure, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = buildFullDto(structure, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function StructureDtoFactory.createPatchDto(structure, dirtyFields, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = buildPatchDto(structure, dirtyFields, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function StructureDtoFactory.createRemovalDto(structureId)
    local dto = { ceType = CE_TYPE, id = structureId }
    return CE_TYPE, KEY_ID, structureId, dto
end

function StructureDtoFactory.createDtoList(structures, isSelectedByValue)
    local dtos = {}
    for _, structure in pairs(structures or {}) do
        local _, _, _, dto = StructureDtoFactory.createFullDto(
            structure, isSelectedByValue and isSelectedByValue(structure) or false)
        dtos[#dtos + 1] = dto
    end
    return CE_TYPE, KEY_ID, dtos
end

return StructureDtoFactory
