---@meta

-- Field policies: all fields always

---@class ScenarioDto
---@field id string                       -- Policy: always
---@field name string                     -- Policy: always
---@field scenarioName string|nil         -- Policy: always
---@field scenarioPath string|nil         -- Policy: always
---@field savedWithEep number|nil         -- Policy: always
---@field scenarioLanguage string|nil     -- Policy: always
---@field eepLanguage string|nil          -- Policy: always
---@field activeTrain string|nil          -- Policy: always
---@field activeRollingStock string|nil   -- Policy: always
---@field timeLapse number|nil            -- Policy: always

---@class ScenarioDtoFactory
---@field createScenarioDto fun(scenario: table):string,string,string|number,ScenarioDto
---@field createScenarioDtoList fun(scenario: table):string,string,table
