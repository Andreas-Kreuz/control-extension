if CeDebugLoad then print("[#Start] Loading ce.hub.data.modules.ModulesPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local ModuleDtoFactory = require("ce.hub.data.modules.ModuleDtoFactory")
local ModulesRegistry = require("ce.hub.data.modules.ModulesRegistry")
local TableUtils = require("ce.hub.util.TableUtils")

local ModulesPublisher = {}

local knownModInfos = {}

local function checkModule(moduleName, module)
    local _, _, _, newModInfo = ModuleDtoFactory.createModuleDto(moduleName, module)
    local oldModInfo = knownModInfos[moduleName]
    if not oldModInfo then
        DataChangeBus.fireDataAdded(ModuleDtoFactory.createModuleDto(moduleName, module))
    elseif not TableUtils.sameDictEntries(oldModInfo, newModInfo) then
        DataChangeBus.fireDataChanged(ModuleDtoFactory.createModuleDto(moduleName, module))
    end
    knownModInfos[moduleName] = newModInfo
end

function ModulesPublisher.syncState()
    local registeredCeModules = ModulesRegistry.get()
    for moduleName, module in pairs(registeredCeModules) do checkModule(moduleName, module) end

    local modInfos = { modules = {} }
    local _, _, modInfosById = ModuleDtoFactory.createModuleDtoList(registeredCeModules)
    for key, value in pairs(modInfosById) do modInfos[key] = value end
    return modInfos
end

return ModulesPublisher
