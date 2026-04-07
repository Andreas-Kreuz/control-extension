if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionUpdater ...") end

local VersionDataCollector = require("ce.hub.data.version.VersionDataCollector")
local VersionRegistry = require("ce.hub.data.version.VersionRegistry")

local VersionUpdater = {}

function VersionUpdater.runUpdate()
    VersionRegistry.set(VersionDataCollector.collectVersionInfo())
end

return VersionUpdater
