-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/scenario/ScenarioLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local HubCeTypes = require("ce.hub.data.HubCeTypes")

---@class ScenarioDtoFactory
---@field createFullDto fun(scenario: table):string,string,string|number,ScenarioDto
---@field createPatchDto fun(scenario: table, dirtyFields: table<string, boolean>):string,string,
---string|number,ScenarioDto
---@field createScenarioDtoList fun(scenario: table):string,string,table
local ScenarioDtoFactory = {}

local CE_TYPE = HubCeTypes.Scenario
local KEY_ID = "id"
local ENTRY_ID = "scenario"

-- DtoFields: class definition in ScenarioDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = function (scenario) return scenario.name or ENTRY_ID end,
        placeholder = ENTRY_ID
    },
    scenarioName = {
        getValue = function (scenario) return scenario.scenarioName end,
        placeholder = ""
    },
    scenarioPath = {
        getValue = function (scenario) return scenario.scenarioPath end,
        placeholder = ""
    },
    savedWithEep = {
        getValue = function (scenario) return scenario.savedWithEep end,
        placeholder = 0
    },
    scenarioLanguage = {
        getValue = function (scenario) return scenario.scenarioLanguage end,
        placeholder = ""
    },
    eepLanguage = {
        getValue = function (scenario) return scenario.eepLanguage end,
        placeholder = ""
    },
    activeTrain = {
        getValue = function (scenario) return scenario.activeTrain end,
        placeholder = ""
    },
    activeRollingStock = {
        getValue = function (scenario) return scenario.activeRollingStock end,
        placeholder = ""
    },
    timeLapse = {
        getValue = function (scenario) return scenario.timeLapse end,
        placeholder = 0
    },
}

local function buildScenarioDto(scenario)
    return DtoBuilder.buildFullDto({
        ceType = CE_TYPE,
        id = scenario.id or ENTRY_ID
    }, scenario, dtoFields)
end

local function buildScenarioPatchDto(scenario, dirtyFields)
    return DtoBuilder.buildPatchDto({
        ceType = CE_TYPE,
        id = scenario.id or ENTRY_ID
    }, scenario, dirtyFields, dtoFields)
end

function ScenarioDtoFactory.createFullDto(scenario)
    local dto = buildScenarioDto(scenario)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function ScenarioDtoFactory.createPatchDto(scenario, dirtyFields)
    local dto = buildScenarioPatchDto(scenario, dirtyFields)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function ScenarioDtoFactory.createScenarioDtoList(scenario)
    local _, _, _, dto = ScenarioDtoFactory.createFullDto(scenario)
    return CE_TYPE, KEY_ID, { [ENTRY_ID] = dto }
end

return ScenarioDtoFactory
