-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/structures/StructureLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

---@class StructureDtoFactory
---@field createFullDto fun(structure: Structure, isSelected: boolean|nil):string,string,string|number,StructureDto
---@field createPatchDto fun(structure: Structure, dirtyFields: table<string,boolean>, isSelected: boolean|nil):string,
---string,string|number,StructureDto
---@field createRemovalDto fun(structureId: string):string,string,string|number,table
local StructureDtoFactory = {}

local CE_TYPE = HubCeTypes.Structure
local KEY_ID = "id"

local function getGsbname(structure)
    if structure.getGsbname then return structure:getGsbname() end
    return structure.gsbname
end

-- DtoFields: class definition in StructureDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = function (structure) return structure.name end,
        placeholder = ""
    },
    pos_x = {
        getValue = function (structure) return structure.pos_x end,
        placeholder = 0
    },
    pos_y = {
        getValue = function (structure) return structure.pos_y end,
        placeholder = 0
    },
    pos_z = {
        getValue = function (structure) return structure.pos_z end,
        placeholder = 0
    },
    rot_x = {
        getValue = function (structure) return structure.rot_x end,
        placeholder = 0
    },
    rot_y = {
        getValue = function (structure) return structure.rot_y end,
        placeholder = 0
    },
    rot_z = {
        getValue = function (structure) return structure.rot_z end,
        placeholder = 0
    },
    modelType = {
        getValue = function (structure) return structure.modelType end,
        placeholder = 0
    },
    modelTypeText = {
        getValue = function (structure) return structure.modelTypeText end,
        placeholder = ""
    },
    tag = {
        getValue = function (structure) return structure:getTag() end,
        placeholder = ""
    },
    light = {
        getValue = function (structure) return structure:getLight() end,
        placeholder = false
    },
    smoke = {
        getValue = function (structure) return structure:getSmoke() end,
        placeholder = false
    },
    fire = {
        getValue = function (structure) return structure:getFire() end,
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

return StructureDtoFactory
