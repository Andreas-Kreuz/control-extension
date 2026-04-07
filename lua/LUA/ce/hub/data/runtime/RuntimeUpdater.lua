if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimeUpdater ...") end

local RuntimeDataCollector = require("ce.hub.data.runtime.RuntimeDataCollector")
local RuntimeRegistry = require("ce.hub.data.runtime.RuntimeRegistry")

local RuntimeUpdater = {}

function RuntimeUpdater.runUpdate()
    RuntimeRegistry.set(RuntimeDataCollector.collectRuntimeEntries())
end

return RuntimeUpdater
