-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/framedata/FrameDataLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local FrameDataDtoFactory = {}

local CE_TYPE = HubCeTypes.FrameData
local KEY_ID = "id"

local function toFrameDataDto(entry)
    return {
        ceType = CE_TYPE,
        id = entry.id,
        framesPerSecond = entry.framesPerSecond,
        currentFrame = entry.currentFrame,
        currentRenderFrame = entry.currentRenderFrame
    }
end

function FrameDataDtoFactory.createFrameDataDtoList(entries)
    local dtos = {}
    for i = 1, #entries do
        local dto = toFrameDataDto(entries[i])
        dtos[i] = dto
    end
    return CE_TYPE, KEY_ID, dtos
end

return FrameDataDtoFactory
