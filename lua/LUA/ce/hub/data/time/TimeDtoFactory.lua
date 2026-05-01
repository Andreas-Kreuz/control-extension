-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/time/TimeLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.time.TimeDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
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
        getValue = function (timeData) return timeData.name end,
        placeholder = ""
    },
    timeComplete = {
        getValue = function (timeData) return timeData.timeComplete end,
        placeholder = 0
    },
    timeH = {
        getValue = function (timeData) return timeData.timeH end,
        placeholder = 0
    },
    timeM = {
        getValue = function (timeData) return timeData.timeM end,
        placeholder = 0
    },
    timeS = {
        getValue = function (timeData) return timeData.timeS end,
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
