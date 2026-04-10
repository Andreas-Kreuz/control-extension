if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioUpdater ...") end

local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local ScenarioDataCollector = require("ce.hub.data.scenario.ScenarioDataCollector")
local ScenarioRegistry = require("ce.hub.data.scenario.ScenarioRegistry")

local ScenarioUpdater = {}

function ScenarioUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("scenario") then return end
    ScenarioRegistry.set(ScenarioDataCollector.collectScenario())
end

return ScenarioUpdater
