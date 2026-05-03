if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.ScenarioPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local ScenarioDtoFactory = require("ce.hub.data.scenario.ScenarioDtoFactory")
local ScenarioRegistry = require("ce.hub.data.scenario.ScenarioRegistry")

local ScenarioPublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

function ScenarioPublisher.syncState()
    local scenario = ScenarioRegistry.get()
    if scenario then
        if scenario.needsFullSend then
            DataChangeBus.fireDataChanged(ScenarioDtoFactory.createFullDto(scenario))
            scenario.needsFullSend = false
            scenario:resetDirty()
        elseif scenario:hasDirtyFields() then
            local ceType, keyId, key, dto = ScenarioDtoFactory.createPatchDto(scenario, scenario.dirtyFields)
            if hasPayloadFields(dto) then DataChangeBus.fireDataChanged(ceType, keyId, key, dto) end
            scenario:resetDirty()
        end
    end
end

return ScenarioPublisher
