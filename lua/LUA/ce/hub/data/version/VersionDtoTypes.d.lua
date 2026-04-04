---@meta

-- Field policies: all fields always

---@class VersionDto
---@field id string              -- Policy: always
---@field name string            -- Policy: always
---@field eepVersion string      -- Policy: always
---@field luaVersion string      -- Policy: always
---@field singleVersion string   -- Policy: always
---@field eepLanguage string|nil     -- Policy: always
---@field layoutVersion number|nil   -- Policy: always
---@field layoutLanguage string|nil  -- Policy: always
---@field layoutName string|nil      -- Policy: always
---@field layoutPath string|nil      -- Policy: always

---@class VersionDtoFactory
---@field createVersionDto fun(versionInfo: table):string,string,string|number,VersionDto
---@field createVersionDtoList fun(versionInfo: table):string,string,table
