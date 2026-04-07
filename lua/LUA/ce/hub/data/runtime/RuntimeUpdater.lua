if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimeUpdater ...") end

local RuntimeDataCollector = require("ce.hub.data.runtime.RuntimeDataCollector")
local RuntimeRegistry = require("ce.hub.data.runtime.RuntimeRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local RuntimeUpdater = {}

function RuntimeUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("runtimes") then return end
    RuntimeRegistry.set(RuntimeDataCollector.collectRuntimeEntries())
end

return RuntimeUpdater
