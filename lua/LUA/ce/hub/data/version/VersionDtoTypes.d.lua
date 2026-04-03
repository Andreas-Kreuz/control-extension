---@meta

---@class VersionDto
---@field id string
---@field name string
---@field eepVersion string
---@field luaVersion string
---@field singleVersion string
---@field eepLanguage string|nil
---@field layoutVersion number|nil
---@field layoutLanguage string|nil
---@field layoutName string|nil
---@field layoutPath string|nil

---@class VersionDtoFactory
---@field createVersionDto fun(versionInfo: table):string,string,string|number,VersionDto
---@field createVersionDtoList fun(versionInfo: table):string,string,table
