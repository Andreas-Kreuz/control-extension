-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/switches/SwitchLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local peek = DtoFieldAccess.peek
local HubCeTypes = require("ce.hub.data.HubCeTypes")

---@class SwitchDtoFactory
---@field createSwitchDto fun(switch: table):string,string,string|number,SwitchDto
local SwitchDtoFactory = {}

local CE_TYPE = HubCeTypes.Switch
local KEY_ID = "id"

-- DtoFields: class definition in SwitchDtoTypes.d.lua
local dtoFields = {
    position = {
        getValue = peek(function (source) return source:peekPosition() end, "position"),
        placeholder = 0
    },
    tag = {
        getValue = peek(function (source) return source:peekTag() end, "tag"),
        placeholder = ""
    },
}

local function buildSwitchDto(switch)
    return DtoBuilder.buildFullDto({
                                       ceType = CE_TYPE,
                                       id = switch.id
                                   }, switch, dtoFields)
end

function SwitchDtoFactory.createSwitchDto(switch)
    local dto = buildSwitchDto(switch)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

return SwitchDtoFactory
