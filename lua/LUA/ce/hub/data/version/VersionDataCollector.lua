if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionDataCollector ...") end

local Version = require("ce.hub.data.version.Version")

---@class VersionDataCollector
---@field collectVersionInfo fun():table
local VersionDataCollector = {}

function VersionDataCollector.collectVersionInfo()
    return Version.pullCurrent()
end

return VersionDataCollector
