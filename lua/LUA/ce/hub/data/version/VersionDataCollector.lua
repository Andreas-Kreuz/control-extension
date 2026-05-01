if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionDataCollector ...") end

local VersionInfo = require("ce.hub.data.version.VersionInfo")

---@class VersionDataCollector
---@field collectVersionInfo fun():table
local VersionDataCollector = {}

function VersionDataCollector.collectVersionInfo()
    return {
        eepVersion = string.format("%.1f", EEPVer),
        luaVersion = _VERSION,
        singleVersion = VersionInfo.getProgramVersion()
    }
end

return VersionDataCollector
