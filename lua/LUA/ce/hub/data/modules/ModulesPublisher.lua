if CeDebugLoad then print("[#Start] Loading ce.hub.data.modules.ModulesPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local ModuleDtoFactory = require("ce.hub.data.modules.ModuleDtoFactory")
local ModulesRegistry = require("ce.hub.data.modules.ModulesRegistry")

local ModulesPublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

local function publishRemovedModules()
    for moduleId in pairs(ModulesRegistry.getRemovedIds()) do
        DataChangeBus.fireDataRemoved(ModuleDtoFactory.createRemovalDto(moduleId))
    end
    ModulesRegistry.clearRemoved()
end

local function publishModule(module)
    if module.needsFullSend then
        DataChangeBus.fireDataAdded(ModuleDtoFactory.createModuleDto(module))
        module.needsFullSend = false
        module:resetDirty()
    elseif module:hasDirtyFields() then
        local ceType, keyId, key, dto = ModuleDtoFactory.createModulePatchDto(module, module.dirtyFields)
        if hasPayloadFields(dto) then DataChangeBus.fireDataChanged(ceType, keyId, key, dto) end
        module:resetDirty()
    end
end

function ModulesPublisher.syncState()
    local registeredCeModules = ModulesRegistry.get()
    publishRemovedModules()
    for _, module in pairs(registeredCeModules) do publishModule(module) end
end

return ModulesPublisher
