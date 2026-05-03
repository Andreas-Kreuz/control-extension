if CeDebugLoad then print("[#Start] Loading ce.hub.data.scenario.Scenario ...") end

---@class Scenario
---@field id string
---@field name string
---@field scenarioName string|nil
---@field scenarioPath string|nil
---@field savedWithEep number|nil
---@field scenarioLanguage string|nil
---@field eepLanguage string|nil
---@field activeTrain string|nil
---@field activeRollingStock string|nil
---@field timeLapse number|nil
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local Scenario = {}

local function markDirty(scenario, fieldName)
    scenario.dirtyFields[fieldName] = true
end

local function updateField(scenario, fieldName, value)
    local oldValue = scenario[fieldName]
    scenario[fieldName] = value
    if oldValue ~= value then markDirty(scenario, fieldName) end
end

function Scenario:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.id, "Provide an id")

    self.__index = self
    setmetatable(o, self)
    o.dirtyFields = {}
    o.needsFullSend = true
    return o
end

function Scenario:update(values)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(values) == "table", "Need 'values' as table")

    updateField(self, "name", values.name)
    updateField(self, "scenarioName", values.scenarioName)
    updateField(self, "scenarioPath", values.scenarioPath)
    updateField(self, "savedWithEep", values.savedWithEep)
    updateField(self, "scenarioLanguage", values.scenarioLanguage)
    updateField(self, "eepLanguage", values.eepLanguage)
    updateField(self, "activeTrain", values.activeTrain)
    updateField(self, "activeRollingStock", values.activeRollingStock)
    updateField(self, "timeLapse", values.timeLapse)
end

function Scenario:resetDirty()
    self.dirtyFields = {}
end

function Scenario:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return Scenario
