if CeDebugLoad then print("[#Start] Loading ce.hub.data.modules.ModulesRegistry ...") end

local ModulesRegistry = {}

local modules = {}

function ModulesRegistry.set(entries)
    modules = entries or {}
end

function ModulesRegistry.get()
    return modules
end

return ModulesRegistry
