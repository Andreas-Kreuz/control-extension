-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/version/VersionLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local VersionDtoFactory = {}

local CE_TYPE = HubCeTypes.EepVersion
local KEY_ID = "id"
local ENTRY_ID = "versionInfo"

function VersionDtoFactory.createVersionDto(versionInfo)
    local dto = {
        ceType = CE_TYPE,
        id = ENTRY_ID,
        name = ENTRY_ID,
        eepVersion = versionInfo.eepVersion,
        luaVersion = versionInfo.luaVersion,
        singleVersion = versionInfo.singleVersion,
        eepLanguage = versionInfo.eepLanguage,
        layoutVersion = versionInfo.layoutVersion,
        layoutLanguage = versionInfo.layoutLanguage,
        layoutName = versionInfo.layoutName,
        layoutPath = versionInfo.layoutPath
    }
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function VersionDtoFactory.createVersionDtoList(versionInfo)
    local _, _, _, dto = VersionDtoFactory.createVersionDto(versionInfo)
    return CE_TYPE, KEY_ID, { [ENTRY_ID] = dto }
end

return VersionDtoFactory
