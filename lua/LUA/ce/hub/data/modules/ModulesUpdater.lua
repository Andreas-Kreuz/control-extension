if CeDebugLoad then print("[#Start] Loading ce.hub.data.modules.ModulesUpdater ...") end

local ModulesRegistry = require("ce.hub.data.modules.ModulesRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local ModulesUpdater = {}

---@type table<string, CeModule>|nil
local registeredCeModules = nil

---@param modules table<string, CeModule>
function ModulesUpdater.setRegisteredCeModules(modules) registeredCeModules = modules end

function ModulesUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("modules") then return end
    assert(registeredCeModules)
    ModulesRegistry.set(registeredCeModules)
end

return ModulesUpdater