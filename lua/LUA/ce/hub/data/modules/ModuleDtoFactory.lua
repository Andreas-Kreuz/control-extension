-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/modules/ModuleLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.modules.ModuleDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local peek = DtoFieldAccess.peek
local HubCeTypes = require("ce.hub.data.HubCeTypes")

---@class ModuleDtoFactory
---@field createModuleDto fun(moduleOrName: Module|string, module: CeModule|nil):string,string,string|number,ModuleDto
---@field createModulePatchDto fun(module: Module, dirtyFields: table<string, boolean>):string,string,
---string|number,ModuleDto
---@field createRemovalDto fun(moduleId: string):string,string,string,table
---@field createModuleDtoList fun(modules: table<string, Module>):string,string,table
local ModuleDtoFactory = {}

local CE_TYPE = HubCeTypes.Module
local KEY_ID = "id"

-- DtoFields: class definition in ModuleDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = peek(function (source) return source:peekName() end, "name"),
        placeholder = ""
    },
    enabled = {
        getValue = peek(function (source) return source:peekEnabled() end, "enabled"),
        placeholder = false
    },
}

local function buildModuleDto(module)
    return DtoBuilder.buildFullDto({
                                       ceType = CE_TYPE,
                                       id = module.id
                                   }, module, dtoFields)
end

local function buildModulePatchDto(module, dirtyFields)
    return DtoBuilder.buildPatchDto({
                                        ceType = CE_TYPE,
                                        id = module.id
                                    }, module, dirtyFields, dtoFields)
end

local function normalizeModule(moduleOrName, module)
    if module then
        return {
            id = module.id,
            name = moduleOrName,
            enabled = module.enabled
        }
    end
    return moduleOrName
end

function ModuleDtoFactory.createModuleDto(moduleOrName, module)
    local dto = buildModuleDto(normalizeModule(moduleOrName, module))
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function ModuleDtoFactory.createModulePatchDto(module, dirtyFields)
    local dto = buildModulePatchDto(module, dirtyFields)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function ModuleDtoFactory.createRemovalDto(moduleId)
    return CE_TYPE, KEY_ID, moduleId, { ceType = CE_TYPE, id = moduleId }
end

function ModuleDtoFactory.createModuleDtoList(modules)
    local modInfoDtos = {}
    for _, module in pairs(modules) do
        local _, _, _, dto = ModuleDtoFactory.createModuleDto(module)
        modInfoDtos[module.id] = dto
    end
    return CE_TYPE, KEY_ID, modInfoDtos
end

return ModuleDtoFactory
