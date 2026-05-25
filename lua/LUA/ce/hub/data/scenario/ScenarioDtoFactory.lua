-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/scenario/ScenarioLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local cached = DtoFieldAccess.cached
local peek = DtoFieldAccess.peek
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

local function scenarioName(scenario)
    return cached(scenario, function (source) return source:peekName() end, "name") or ENTRY_ID
end

local function staticCameras(scenario)
    return cached(scenario, function (source) return source:peekStaticCameras() end, "staticCameras") or {}
end

local function dynamicCameras(scenario)
    return cached(scenario, function (source) return source:peekDynamicCameras() end, "dynamicCameras") or {}
end

-- DtoFields: class definition in ScenarioDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = scenarioName,
        placeholder = ENTRY_ID
    },
    scenarioName = {
        getValue = peek(function (source) return source:peekScenarioName() end, "scenarioName"),
        placeholder = ""
    },
    scenarioPath = {
        getValue = peek(function (source) return source:peekScenarioPath() end, "scenarioPath"),
        placeholder = ""
    },
    savedWithEep = {
        getValue = peek(function (source) return source:peekSavedWithEep() end, "savedWithEep"),
        placeholder = 0
    },
    scenarioLanguage = {
        getValue = peek(function (source) return source:peekScenarioLanguage() end, "scenarioLanguage"),
        placeholder = ""
    },
    eepLanguage = {
        getValue = peek(function (source) return source:peekEepLanguage() end, "eepLanguage"),
        placeholder = ""
    },
    activeTrain = {
        getValue = peek(function (source) return source:peekActiveTrain() end, "activeTrain"),
        placeholder = ""
    },
    activeRollingStock = {
        getValue = peek(function (source) return source:peekActiveRollingStock() end, "activeRollingStock"),
        placeholder = ""
    },
    timeLapse = {
        getValue = peek(function (source) return source:peekTimeLapse() end, "timeLapse"),
        placeholder = 0
    },
    staticCameras = {
        getValue = staticCameras,
        placeholder = {}
    },
    dynamicCameras = {
        getValue = dynamicCameras,
        placeholder = {}
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
