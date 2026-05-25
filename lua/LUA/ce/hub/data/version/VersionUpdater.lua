if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionUpdater ...") end

local Version = require("ce.hub.data.version.Version")
local VersionRegistry = require("ce.hub.data.version.VersionRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local VersionUpdater = {}

function VersionUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("eepVersion") then return end
    VersionRegistry.set(Version.pullCurrent())
end

return VersionUpdater
