---@meta

-- Field policies: all fields always

---@class ModuleDto
---@field id string      -- Policy: always
---@field name string    -- Policy: always
---@field enabled boolean -- Policy: always

---@class ModuleDtoFactory
---@field createModuleDto fun(moduleName: string, module: CeModule):string,string,string|number,ModuleDto
---@field createModuleDtoList fun(modules: table<string, CeModule>):string,string,table
---@field createModuleReferenceDto fun(moduleId: string):string,string,string|number,ModuleDto
