if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioDataCollector ...") end

local ScenarioDataCollector = {}

local function callOptional(fn, ...)
    if type(fn) ~= "function" then return "-" end

    local ok, value = pcall(fn, ...)
    if not ok then return nil end

    return value
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
        timeLapse = callOptional(EEPGetTimeLapse)
    }
end

return ScenarioDataCollector
