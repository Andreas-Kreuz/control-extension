if CeDebugLoad then print("[#Start] Loading ce.hub.data.modules.ModulesUpdater ...") end

local ModulesDataCollector = require("ce.hub.data.modules.ModulesDataCollector")
local ModulesRegistry = require("ce.hub.data.modules.ModulesRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local ModulesUpdater = {}

function ModulesUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("modules") then return end
    ModulesRegistry.set(ModulesDataCollector.collectModules())
end

return ModulesUpdater
