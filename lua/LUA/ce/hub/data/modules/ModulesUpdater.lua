if CeDebugLoad then print("[#Start] Loading ce.hub.data.modules.ModulesUpdater ...") end

local ModulesDataCollector = require("ce.hub.data.modules.ModulesDataCollector")
local ModulesRegistry = require("ce.hub.data.modules.ModulesRegistry")

local ModulesUpdater = {}

function ModulesUpdater.runUpdate()
    ModulesRegistry.set(ModulesDataCollector.collectModules())
end

return ModulesUpdater
