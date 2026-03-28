-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/version/VersionLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local VersionDtoFactory = {}

local CE_TYPE = HubCeTypes.EepVersion
local KEY_ID = "id"
local ENTRY_ID = "versionInfo"

function VersionDtoFactory.createVersionDto(eepVersion, luaVersion, singleVersion)
    local dto = {
        ceType = CE_TYPE,
        id = ENTRY_ID,
        name = ENTRY_ID,
        eepVersion = eepVersion,
        luaVersion = luaVersion,
        singleVersion = singleVersion
    }
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function VersionDtoFactory.createVersionDtoList(eepVersion, luaVersion, singleVersion)
    local _, _, _, dto = VersionDtoFactory.createVersionDto(eepVersion, luaVersion, singleVersion)
    return CE_TYPE, KEY_ID, { [ENTRY_ID] = dto }
end

return VersionDtoFactory
