-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/time/TimeLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.time.TimeDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TimeDtoFactory = {}

local CE_TYPE = HubCeTypes.Time
local KEY_ID = "id"

local function toTimeDto(timeData)
    return {
        ceType = CE_TYPE,
        id = timeData.id,
        name = timeData.name,
        timeComplete = timeData.timeComplete,
        timeLapse = timeData.timeLapse,
        timeH = timeData.timeH,
        timeM = timeData.timeM,
        timeS = timeData.timeS
    }
end

function TimeDtoFactory.createTimeDto(timeData)
    local dto = toTimeDto(timeData)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TimeDtoFactory.createTimeDtoList(times)
    local timeDtos = {}
    for i = 1, #times do
        local _, _, _, dto = TimeDtoFactory.createTimeDto(times[i])
        timeDtos[i] = dto
    end
    return CE_TYPE, KEY_ID, timeDtos
end

return TimeDtoFactory
