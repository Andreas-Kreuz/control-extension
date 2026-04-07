-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/switches/SwitchLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local SwitchDtoFactory = {}

local CE_TYPE = HubCeTypes.Switch
local KEY_ID = "id"

local function toSwitchDto(switch)
    return {
        ceType = CE_TYPE,
        id = switch.id,
        position = switch.position,
        tag = switch.tag
    }
end

function SwitchDtoFactory.createSwitchDto(switch)
    local dto = toSwitchDto(switch)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function SwitchDtoFactory.createSwitchDtoList(switches)
    local switchDtos = {}
    for i = 1, #switches do
        local _, _, _, dto = SwitchDtoFactory.createSwitchDto(switches[i])
        switchDtos[i] = dto
    end
    return CE_TYPE, KEY_ID, switchDtos
end

return SwitchDtoFactory
