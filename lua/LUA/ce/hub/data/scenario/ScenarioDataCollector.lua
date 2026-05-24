if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioDataCollector ...") end

local Scenario = require("ce.hub.data.scenario.Scenario")

---@class ScenarioDataCollector
---@field collectScenario fun():table
local ScenarioDataCollector = {}

function ScenarioDataCollector.collectScenario()
    return Scenario.pullCurrent()
end

return ScenarioDataCollector
