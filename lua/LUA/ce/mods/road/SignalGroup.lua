if CeDebugLoad then print("[#Start] Loading ce.mods.road.SignalGroup ...") end

local SignalGroup = {}
SignalGroup.Type = { BUS = "BUS", CAR = "CAR", TRAM = "TRAM", PEDESTRIAN = "PEDESTRIAN", BICYCLE = "BICYCLE" }

local function isKnownValue(values, value)
    if values[value] then return true end
    for _, knownValue in pairs(values) do
        if knownValue == value then return true end
    end
    return false
end

local function logicalUseFor(signalType)
    if signalType == SignalGroup.Type.PEDESTRIAN then return "PEDESTRIAN" end
    return "VEHICLE"
end

local function addSignalsToGroup(self, signalType, ...)
    for _, signal in ipairs({ ... }) do
        assert(signal and signal.type == "TrafficLight", "Specify TrafficLight instances")
        local logicalUse = logicalUseFor(signalType)
        signal.signalGroupsByUse = signal.signalGroupsByUse or {}
        local existing = signal.signalGroupsByUse[logicalUse]
        assert(not existing or existing == self,
               "Signal logical use already belongs to signal group: " .. signal:signalNamesText())
        signal.signalGroupsByUse[logicalUse] = self
        self.signalHeads[signal] = signalType
    end
    return self
end

local function addPedestrianCrossingsToGroup(self, ...)
    for _, crossing in ipairs({ ... }) do
        assert(crossing and crossing.getType and crossing:getType() == "PedestrianCrossing",
               "Specify PedestrianCrossing instances")
        table.insert(self.pedestrianCrossings, crossing)
    end
    return self
end

function SignalGroup.getType() return "SignalGroup" end

function SignalGroup:new(name)
    assert(type(name) == "string", "Need 'name' as string")
    local o = {
        type = "SignalGroup",
        name = name,
        _scriptVariableName = nil,
        approach = nil,
        turnDirections = {},
        pedestrianCrossings = {},
        signalHeads = {}
    }
    self.__index = self
    return setmetatable(o, self)
end

function SignalGroup:getName() return self.name end

function SignalGroup:getScriptVariableName() return self._scriptVariableName end

function SignalGroup:setScriptVariableName(scriptVariableName)
    assert(type(scriptVariableName) == "string", "Need 'scriptVariableName' as string")
    self._scriptVariableName = scriptVariableName
    return self
end

function SignalGroup:scriptVariableName(scriptVariableName) return self:setScriptVariableName(scriptVariableName) end

function SignalGroup:getApproach() return self.approach end

function SignalGroup:getTurnDirections() return self.turnDirections end

function SignalGroup:setApproach(approach)
    local Lane = require("ce.mods.road.Lane")
    if not isKnownValue(Lane.Approach, approach) then
        print(string.format("[#SignalGroup] No such approach: %s", tostring(approach)))
    else
        self.approach = approach
    end
    return self
end

function SignalGroup:setTurnDirections(...)
    local Lane = require("ce.mods.road.Lane")
    local turnDirections = { ... }
    if #turnDirections == 1 and type(turnDirections[1]) == "table" then turnDirections = turnDirections[1] end
    for _, direction in ipairs(turnDirections) do
        if not isKnownValue(Lane.Directions, direction) then
            print(string.format("[#SignalGroup] No such direction: %s", tostring(direction)))
        end
    end
    self.turnDirections = turnDirections
    return self
end

function SignalGroup:addSignals(signalType, ...)
    return addSignalsToGroup(self, signalType, ...)
end

function SignalGroup:addVehicleSignals(...) return addSignalsToGroup(self, SignalGroup.Type.CAR, ...) end

function SignalGroup:addTramSignals(...) return addSignalsToGroup(self, SignalGroup.Type.TRAM, ...) end

function SignalGroup:addPedestrianSignals(...) return addSignalsToGroup(self, SignalGroup.Type.PEDESTRIAN, ...) end

function SignalGroup:addPedestrianCrossings(...) return addPedestrianCrossingsToGroup(self, ...) end

function SignalGroup:addPedestrianCrossing(...) return self:addPedestrianCrossings(...) end

function SignalGroup:getSignalHeads() return self.signalHeads end

function SignalGroup:getPedestrianCrossings() return self.pedestrianCrossings end

function SignalGroup:containsSignalHead(signal)
    return self.signalHeads[signal] ~= nil
end

function SignalGroup.logicalUseFor(signalType) return logicalUseFor(signalType) end

return SignalGroup
