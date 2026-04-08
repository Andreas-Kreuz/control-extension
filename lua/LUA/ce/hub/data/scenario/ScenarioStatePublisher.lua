if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioStatePublisher ...") end
local ScenarioPublisher = require("ce.hub.data.scenario.ScenarioPublisher")

ScenarioStatePublisher = {}
ScenarioStatePublisher.enabled = true
local initialized = false
ScenarioStatePublisher.name = "ce.hub.data.scenario.ScenarioStatePublisher"
ScenarioStatePublisher.ceTypes = require("ce.hub.data.HubCeTypes").Scenario

function ScenarioStatePublisher.initialize()
    if not ScenarioStatePublisher.enabled or initialized then return end

    initialized = true
end

function ScenarioStatePublisher.syncState()
    if not ScenarioStatePublisher.enabled then return end

    if not initialized then ScenarioStatePublisher.initialize() end
    return ScenarioPublisher.syncState()
end

return ScenarioStatePublisher
