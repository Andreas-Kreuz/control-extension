if CeDebugLoad then print("[#Start] Loading ce.hub.data.modules.ModulesRegistry ...") end

local Module = require("ce.hub.data.modules.Module")

local ModulesRegistry = {}

local modules = {}
local removedIds = {}

function ModulesRegistry.set(entries)
    local currentIds = {}

    for moduleName, sourceModule in pairs(entries or {}) do
        local moduleId = sourceModule.id
        currentIds[moduleId] = true

        local values = {
            id = moduleId,
            name = moduleName,
            enabled = sourceModule.enabled
        }
        if modules[moduleId] then
            modules[moduleId]:update(values)
        else
            modules[moduleId] = Module:new(values)
        end
    end

    for moduleId in pairs(modules) do
        if not currentIds[moduleId] then
            modules[moduleId] = nil
            removedIds[moduleId] = true
        end
    end
end

function ModulesRegistry.get()
    return modules
end

function ModulesRegistry.getRemovedIds()
    local copy = {}
    for moduleId in pairs(removedIds) do copy[moduleId] = true end
    return copy
end

function ModulesRegistry.clearRemoved()
    removedIds = {}
end

return ModulesRegistry
