if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioRegistry ...") end

local Scenario = require("ce.hub.data.scenario.Scenario")

local ScenarioRegistry = {}

local scenario = nil

function ScenarioRegistry.set(entry)
    if not entry then
        scenario = nil
        return
    end

    entry.id = entry.id or "scenario"
    entry.name = entry.name or "scenario"

    if scenario then
        scenario:update(entry)
    else
        scenario = Scenario:new(entry)
    end
end

function ScenarioRegistry.get()
    return scenario
end

function ScenarioRegistry.getOrCreate()
    if not scenario then
        scenario = Scenario:new({
            id = "scenario",
            name = "scenario"
        })
    end
    return scenario
end

return ScenarioRegistry
