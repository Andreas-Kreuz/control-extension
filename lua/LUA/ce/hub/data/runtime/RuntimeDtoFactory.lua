-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/runtime/RuntimeLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimeDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local peek = DtoFieldAccess.peek
local HubCeTypes = require("ce.hub.data.HubCeTypes")

---@class RuntimeDtoFactory
---@field createFullDto fun(runtimeEntry: table):string,string,string|number,RuntimeDto
---@field createPatchDto fun(runtimeEntry: table, dirtyFields: table<string, boolean>):string,string,
---string|number,RuntimeDto
---@field createRemovalDto fun(runtimeId: string):string,string,string,table
---@field createRuntimeDtoList fun(runtimeEntries: table):string,string,table
local RuntimeDtoFactory = {}

local CE_TYPE = HubCeTypes.Runtime
local KEY_ID = "id"

-- DtoFields: class definition in RuntimeDtoTypes.d.lua
local dtoFields = {
    count = {
        getValue = peek(function (source) return source:peekCount() end, "count"),
        placeholder = 0
    },
    time = {
        getValue = peek(function (source) return source:peekTime() end, "time"),
        placeholder = 0
    },
    lastTime = {
        getValue = peek(function (source) return source:peekLastTime() end, "lastTime"),
        placeholder = 0
    },
}

local function buildRuntimeDto(runtimeEntry)
    return DtoBuilder.buildFullDto({
                                       ceType = CE_TYPE,
                                       id = runtimeEntry.id
                                   }, runtimeEntry, dtoFields)
end

local function buildRuntimePatchDto(runtimeEntry, dirtyFields)
    return DtoBuilder.buildPatchDto({
                                        ceType = CE_TYPE,
                                        id = runtimeEntry.id
                                    }, runtimeEntry, dirtyFields, dtoFields)
end

function RuntimeDtoFactory.createFullDto(runtimeEntry)
    local dto = buildRuntimeDto(runtimeEntry)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RuntimeDtoFactory.createPatchDto(runtimeEntry, dirtyFields)
    local dto = buildRuntimePatchDto(runtimeEntry, dirtyFields)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RuntimeDtoFactory.createRemovalDto(runtimeId)
    return CE_TYPE, KEY_ID, runtimeId, { ceType = CE_TYPE, id = runtimeId }
end

function RuntimeDtoFactory.createRuntimeDtoList(runtimeEntries)
    local runtimeDtos = {}
    for runtimeId, runtimeEntry in pairs(runtimeEntries) do
        local _, _, _, dto = RuntimeDtoFactory.createFullDto(runtimeEntry)
        runtimeDtos[runtimeId] = dto
    end
    return CE_TYPE, KEY_ID, runtimeDtos
end

return RuntimeDtoFactory
