if CeDebugLoad then print("[#Start] Loading ce.mods.road.SignalGroup ...") end

local SignalGroup = {}
SignalGroup.Type = { BUS = "BUS", CAR = "CAR", TRAM = "TRAM", PEDESTRIAN = "PEDESTRIAN", BICYCLE = "BICYCLE" }

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

function SignalGroup.getType() return "SignalGroup" end

function SignalGroup:new(name)
    assert(type(name) == "string", "Need 'name' as string")
    local o = {
        type = "SignalGroup",
        name = name,
        signalHeads = {}
    }
    self.__index = self
    return setmetatable(o, self)
end

function SignalGroup:getName() return self.name end

function SignalGroup:addSignals(signalType, ...)
    return addSignalsToGroup(self, signalType, ...)
end

function SignalGroup:addVehicleSignals(...) return addSignalsToGroup(self, SignalGroup.Type.CAR, ...) end

function SignalGroup:addTramSignals(...) return addSignalsToGroup(self, SignalGroup.Type.TRAM, ...) end

function SignalGroup:addPedestrianSignals(...) return addSignalsToGroup(self, SignalGroup.Type.PEDESTRIAN, ...) end

function SignalGroup:getSignalHeads() return self.signalHeads end

function SignalGroup:containsSignalHead(signal)
    return self.signalHeads[signal] ~= nil
end

function SignalGroup.logicalUseFor(signalType) return logicalUseFor(signalType) end

return SignalGroup
