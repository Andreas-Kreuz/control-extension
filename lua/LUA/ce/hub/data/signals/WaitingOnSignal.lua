if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.WaitingOnSignal ...") end

local DataClass = require("ce.hub.data.DataClass")

---@class WaitingOnSignal
---@field id string
---@field signalId number|string
---@field waitingPosition number
---@field vehicleName string
---@field waitingCount number
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local WaitingOnSignal = {}

local function updateField(waitingOnSignal, fieldName, value)
    DataClass.replaceField(waitingOnSignal, fieldName, value)
end

function WaitingOnSignal:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.id, "Provide an id")

    self.__index = self
    setmetatable(o, self)
    DataClass.init(o)
    return o
end

function WaitingOnSignal:peekSignalId() return self.signalId end

function WaitingOnSignal:peekWaitingPosition() return self.waitingPosition end

function WaitingOnSignal:peekVehicleName() return self.vehicleName end

function WaitingOnSignal:peekWaitingCount() return self.waitingCount end

function WaitingOnSignal:update(values)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(values) == "table", "Need 'values' as table")

    updateField(self, "signalId", values.signalId)
    updateField(self, "waitingPosition", values.waitingPosition)
    updateField(self, "vehicleName", values.vehicleName)
    updateField(self, "waitingCount", values.waitingCount)
end

function WaitingOnSignal:resetDirty()
    DataClass.resetDirty(self)
end

function WaitingOnSignal:hasDirtyFields()
    return DataClass.hasDirtyFields(self)
end

return WaitingOnSignal
