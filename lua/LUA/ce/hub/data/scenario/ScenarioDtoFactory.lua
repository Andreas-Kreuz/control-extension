-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/scenario/ScenarioLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local ScenarioDtoFactory = {}

local CE_TYPE = HubCeTypes.Scenario
local KEY_ID = "id"
local ENTRY_ID = "scenario"

function ScenarioDtoFactory.createScenarioDto(scenario)
    local dto = {
        ceType = CE_TYPE,
        id = scenario.id or ENTRY_ID,
        name = scenario.name or ENTRY_ID,
        scenarioName = scenario.scenarioName,
        scenarioPath = scenario.scenarioPath,
        savedWithEep = scenario.savedWithEep,
        scenarioLanguage = scenario.scenarioLanguage,
        eepLanguage = scenario.eepLanguage,
        activeTrain = scenario.activeTrain,
        activeRollingStock = scenario.activeRollingStock,
        timeLapse = scenario.timeLapse
    }
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function ScenarioDtoFactory.createScenarioDtoList(scenario)
    local _, _, _, dto = ScenarioDtoFactory.createScenarioDto(scenario)
    return CE_TYPE, KEY_ID, { [ENTRY_ID] = dto }
end

return ScenarioDtoFactory
