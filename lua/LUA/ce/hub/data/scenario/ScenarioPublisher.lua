if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local ScenarioDtoFactory = require("ce.hub.data.scenario.ScenarioDtoFactory")
local ScenarioRegistry = require("ce.hub.data.scenario.ScenarioRegistry")

local ScenarioPublisher = {}

function ScenarioPublisher.syncState()
    local scenario = ScenarioRegistry.get()
    if scenario then
        DataChangeBus.fireListChange(ScenarioDtoFactory.createScenarioDtoList(scenario))
    end
    return {}
end

return ScenarioPublisher
