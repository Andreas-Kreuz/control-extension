if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionUpdater ...") end

local VersionDataCollector = require("ce.hub.data.version.VersionDataCollector")
local VersionRegistry = require("ce.hub.data.version.VersionRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local VersionUpdater = {}

function VersionUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("eepVersion") then return end
    VersionRegistry.set(VersionDataCollector.collectVersionInfo())
end

return VersionUpdater
