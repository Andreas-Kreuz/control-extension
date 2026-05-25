-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/time/TimeLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.time.TimeDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local peek = DtoFieldAccess.peek
local HubCeTypes = require("ce.hub.data.HubCeTypes")

---@class TimeDtoFactory
---@field createFullDto fun(timeData: table):string,string,string|number,TimeDto
---@field createPatchDto fun(timeData: table, dirtyFields: table<string, boolean>):string,string,string|number,TimeDto
---@field createTimeDtoList fun(times: table):string,string,table
local TimeDtoFactory = {}

local CE_TYPE = HubCeTypes.Time
local KEY_ID = "id"

-- DtoFields: class definition in TimeDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = peek(function (source) return source:peekName() end, "name"),
        placeholder = ""
    },
    timeComplete = {
        getValue = peek(function (source) return source:peekTimeComplete() end, "timeComplete"),
        placeholder = 0
    },
    timeH = {
        getValue = peek(function (source) return source:peekTimeH() end, "timeH"),
        placeholder = 0
    },
    timeM = {
        getValue = peek(function (source) return source:peekTimeM() end, "timeM"),
        placeholder = 0
    },
    timeS = {
        getValue = peek(function (source) return source:peekTimeS() end, "timeS"),
        placeholder = 0
    },
}

local function buildTimeDto(timeData)
    return DtoBuilder.buildFullDto({
                                       ceType = CE_TYPE,
                                       id = timeData.id
                                   }, timeData, dtoFields)
end

local function buildTimePatchDto(timeData, dirtyFields)
    return DtoBuilder.buildPatchDto({
                                        ceType = CE_TYPE,
                                        id = timeData.id
                                    }, timeData, dirtyFields, dtoFields)
end

function TimeDtoFactory.createFullDto(timeData)
    local dto = buildTimeDto(timeData)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TimeDtoFactory.createPatchDto(timeData, dirtyFields)
    local dto = buildTimePatchDto(timeData, dirtyFields)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TimeDtoFactory.createTimeDtoList(times)
    local timeDtos = {}
    for _, timeData in pairs(times) do
        local _, _, _, dto = TimeDtoFactory.createFullDto(timeData)
        timeDtos[#timeDtos + 1] = dto
    end
    return CE_TYPE, KEY_ID, timeDtos
end

return TimeDtoFactory
