if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioDataCollector ...") end

local ScenarioDiscovery = require("ce.hub.data.scenario.ScenarioDiscovery")

---@class ScenarioDataCollector
---@field collectScenario fun():table
local ScenarioDataCollector = {}

local function callOptional(fn, ...)
    if type(fn) ~= "function" then return "-" end

    local ok, value = pcall(fn, ...)
    if not ok then return nil end

    return value
end

local function copyList(values)
    local copy = {}
    for _, value in ipairs(values or {}) do copy[#copy + 1] = value end
    return copy
end

function ScenarioDataCollector.collectScenario()
    return {
        id = "scenario",
        name = "scenario",
        scenarioName = callOptional(EEPGetAnlName),
        scenarioPath = callOptional(EEPGetAnlPath),
        savedWithEep = callOptional(EEPGetAnlVer),
        scenarioLanguage = callOptional(EEPGetAnlLng),
        eepLanguage = EEPLng,
        activeTrain = callOptional(EEPGetTrainActive),
        activeRollingStock = callOptional(EEPRollingstockGetActive),
        timeLapse = callOptional(EEPGetTimeLapse),
        staticCameras = copyList(ScenarioDiscovery.getStaticCameras()),
        dynamicCameras = copyList(ScenarioDiscovery.getDynamicCameras())
    }
end

return ScenarioDataCollector
