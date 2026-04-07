---@meta

-- Field policies: all fields always

---@class RuntimeDto
---@field id string      -- Policy: always
---@field count number   -- Policy: always
---@field time number    -- Policy: always
---@field lastTime number -- Policy: always

---@class RuntimeDtoFactory
---@field createRuntimeDto fun(runtimeEntry: table):string,string,string|number,RuntimeDto
---@field createRuntimeDtoList fun(runtimeEntries: table):string,string,table
