-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/version/VersionLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local HubCeTypes = require("ce.hub.data.HubCeTypes")

---@class VersionDtoFactory
---@field createFullDto fun(versionInfo: table):string,string,string|number,VersionDto
---@field createPatchDto fun(versionInfo: table, dirtyFields: table<string, boolean>):string,string,
---string|number,VersionDto
---@field createVersionDtoList fun(versionInfo: table):string,string,table
local VersionDtoFactory = {}

local CE_TYPE = HubCeTypes.EepVersion
local KEY_ID = "id"
local ENTRY_ID = "versionInfo"

-- DtoFields: class definition in VersionDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = function () return ENTRY_ID end,
        placeholder = ENTRY_ID
    },
    eepVersion = {
        getValue = function (versionInfo) return versionInfo.eepVersion end,
        placeholder = ""
    },
    luaVersion = {
        getValue = function (versionInfo) return versionInfo.luaVersion end,
        placeholder = ""
    },
    singleVersion = {
        getValue = function (versionInfo) return versionInfo.singleVersion end,
        placeholder = ""
    },
}

local function buildVersionDto(versionInfo)
    return DtoBuilder.buildFullDto({
        ceType = CE_TYPE,
        id = ENTRY_ID
    }, versionInfo, dtoFields)
end

local function buildVersionPatchDto(versionInfo, dirtyFields)
    return DtoBuilder.buildPatchDto({
        ceType = CE_TYPE,
        id = ENTRY_ID
    }, versionInfo, dirtyFields, dtoFields)
end

function VersionDtoFactory.createFullDto(versionInfo)
    local dto = buildVersionDto(versionInfo)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function VersionDtoFactory.createPatchDto(versionInfo, dirtyFields)
    local dto = buildVersionPatchDto(versionInfo, dirtyFields)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function VersionDtoFactory.createVersionDtoList(versionInfo)
    local _, _, _, dto = VersionDtoFactory.createFullDto(versionInfo)
    return CE_TYPE, KEY_ID, { [ENTRY_ID] = dto }
end

return VersionDtoFactory
