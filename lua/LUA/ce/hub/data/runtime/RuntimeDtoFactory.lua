-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/runtime/RuntimeLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimeDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RuntimeDtoFactory = {}

local CE_TYPE = HubCeTypes.Runtime
local KEY_ID = "id"

local function toRuntimeDto(runtimeEntry)
    return {
        ceType = CE_TYPE,
        id = runtimeEntry.id,
        count = runtimeEntry.count,
        time = runtimeEntry.time,
        lastTime = runtimeEntry.lastTime
    }
end

function RuntimeDtoFactory.createRuntimeDto(runtimeEntry)
    local dto = toRuntimeDto(runtimeEntry)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RuntimeDtoFactory.createRuntimeDtoList(runtimeEntries)
    local runtimeDtos = {}
    for runtimeId, runtimeEntry in pairs(runtimeEntries) do
        local _, _, _, dto = RuntimeDtoFactory.createRuntimeDto(runtimeEntry)
        runtimeDtos[runtimeId] = dto
    end
    return CE_TYPE, KEY_ID, runtimeDtos
end

return RuntimeDtoFactory
