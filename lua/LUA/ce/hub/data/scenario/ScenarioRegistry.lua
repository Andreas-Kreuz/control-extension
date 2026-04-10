if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioRegistry ...") end

local ScenarioRegistry = {}

local scenario = nil

function ScenarioRegistry.set(entry)
    scenario = entry
end

function ScenarioRegistry.get()
    return scenario
end

return ScenarioRegistry
