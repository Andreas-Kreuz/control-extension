-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/framedata/FrameDataLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local HubCeTypes = require("ce.hub.data.HubCeTypes")

---@class FrameDataDtoFactory
---@field createFullDto fun(entry: table):string,string,string|number,FrameDataDto
---@field createPatchDto fun(entry: table, dirtyFields: table<string, boolean>):string,string,string|number,FrameDataDto
---@field createFrameDataDtoList fun(entries: table):string,string,table
local FrameDataDtoFactory = {}

local CE_TYPE = HubCeTypes.FrameData
local KEY_ID = "id"

-- DtoFields: class definition in FrameDataDtoTypes.d.lua
local dtoFields = {
    framesPerSecond = {
        getValue = function (entry) return entry.framesPerSecond end,
        placeholder = 0
    },
    currentFrame = {
        getValue = function (entry) return entry.currentFrame end,
        placeholder = 0
    },
    currentRenderFrame = {
        getValue = function (entry) return entry.currentRenderFrame end,
        placeholder = 0
    },
}

local function buildFrameDataDto(entry)
    return DtoBuilder.buildFullDto({
        ceType = CE_TYPE,
        id = entry.id
    }, entry, dtoFields)
end

local function buildFrameDataPatchDto(entry, dirtyFields)
    return DtoBuilder.buildPatchDto({
        ceType = CE_TYPE,
        id = entry.id
    }, entry, dirtyFields, dtoFields)
end

function FrameDataDtoFactory.createFullDto(entry)
    local dto = buildFrameDataDto(entry)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function FrameDataDtoFactory.createPatchDto(entry, dirtyFields)
    local dto = buildFrameDataPatchDto(entry, dirtyFields)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function FrameDataDtoFactory.createFrameDataDtoList(entries)
    local dtos = {}
    for _, entry in pairs(entries) do
        local _, _, _, dto = FrameDataDtoFactory.createFullDto(entry)
        dtos[#dtos + 1] = dto
    end
    return CE_TYPE, KEY_ID, dtos
end

return FrameDataDtoFactory
