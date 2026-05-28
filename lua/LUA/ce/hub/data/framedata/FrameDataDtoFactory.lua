-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/framedata/FrameDataLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local peek = DtoFieldAccess.peek
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

---@class FrameDataDtoFactory
---@field createFullDto fun(entry: table, isSelected?: boolean):string,string,string|number,FrameDataDto
---@field createPatchDto fun(entry: table, dirtyFields: table<string, boolean>, isSelected?: boolean):string,string,
---    string|number,FrameDataDto
---@field createFrameDataDtoList fun(entries: table):string,string,table
local FrameDataDtoFactory = {}

local CE_TYPE = HubCeTypes.FrameData
local KEY_ID = "id"

-- DtoFields: class definition in FrameDataDtoTypes.d.lua
local dtoFields = {
    framesPerSecond = {
        getValue = peek(function (source) return source:peekFramesPerSecond() end, "framesPerSecond"),
        placeholder = 0
    },
    currentFrame = {
        getValue = peek(function (source) return source:peekCurrentFrame() end, "currentFrame"),
        placeholder = 0
    },
    currentRenderFrame = {
        getValue = peek(function (source) return source:peekCurrentRenderFrame() end, "currentRenderFrame"),
        placeholder = 0
    },
}

local function buildFrameDataDto(entry, isSelected)
    return DtoBuilder.buildFullDto({
                                       ceType = CE_TYPE,
                                       id = entry.id
                                   }, entry, dtoFields, HubOptionsRegistry.getFieldPublishPolicies("frameData"),
                                   isSelected == true)
end

local function buildFrameDataPatchDto(entry, dirtyFields, isSelected)
    return DtoBuilder.buildPatchDto({
                                        ceType = CE_TYPE,
                                        id = entry.id
                                    }, entry, dirtyFields, dtoFields,
                                    HubOptionsRegistry.getFieldPublishPolicies("frameData"), isSelected == true)
end

function FrameDataDtoFactory.createFullDto(entry, isSelected)
    local dto = buildFrameDataDto(entry, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function FrameDataDtoFactory.createPatchDto(entry, dirtyFields, isSelected)
    local dto = buildFrameDataPatchDto(entry, dirtyFields, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function FrameDataDtoFactory.createFrameDataDtoList(entries, isSelectedByValue)
    local dtos = {}
    for _, entry in pairs(entries) do
        local _, _, _, dto =
            FrameDataDtoFactory.createFullDto(entry, isSelectedByValue and isSelectedByValue(entry) or false)
        dtos[#dtos + 1] = dto
    end
    return CE_TYPE, KEY_ID, dtos
end

return FrameDataDtoFactory
