if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioUpdater ...") end

local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local Scenario = require("ce.hub.data.scenario.Scenario")
local ScenarioRegistry = require("ce.hub.data.scenario.ScenarioRegistry")

local ScenarioUpdater = {}

function ScenarioUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("scenario") then return end
    ScenarioRegistry.set(Scenario.pullCurrent())
end

return ScenarioUpdater
