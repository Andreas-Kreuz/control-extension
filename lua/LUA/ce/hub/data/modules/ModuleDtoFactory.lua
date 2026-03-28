-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/modules/ModuleLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.modules.ModuleDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local ModuleDtoFactory = {}

local CE_TYPE = HubCeTypes.Module
local KEY_ID = "id"

local function toModuleDto(moduleName, module)
    return {
        ceType = CE_TYPE,
        id = module.id,
        name = moduleName,
        enabled = module.enabled
    }
end

function ModuleDtoFactory.createModuleDto(moduleName, module)
    local dto = toModuleDto(moduleName, module)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function ModuleDtoFactory.createModuleDtoList(modules)
    local modInfoDtos = {}
    for moduleName, module in pairs(modules) do
        local _, _, _, dto = ModuleDtoFactory.createModuleDto(moduleName, module)
        modInfoDtos[module.id] = dto
    end
    return CE_TYPE, KEY_ID, modInfoDtos
end

function ModuleDtoFactory.createModuleReferenceDto(moduleId)
    local dto = { ceType = CE_TYPE, id = moduleId }
    return CE_TYPE, KEY_ID, moduleId, dto
end

return ModuleDtoFactory
