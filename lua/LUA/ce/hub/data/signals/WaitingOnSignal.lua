if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.WaitingOnSignal ...") end

---@class WaitingOnSignal
---@field id string
---@field signalId number|string
---@field waitingPosition number
---@field vehicleName string
---@field waitingCount number
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local WaitingOnSignal = {}

local function markDirty(waitingOnSignal, fieldName)
    waitingOnSignal.dirtyFields[fieldName] = true
end

local function updateField(waitingOnSignal, fieldName, value)
    local oldValue = waitingOnSignal[fieldName]
    waitingOnSignal[fieldName] = value
    if oldValue ~= value then markDirty(waitingOnSignal, fieldName) end
end

function WaitingOnSignal:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.id, "Provide an id")

    self.__index = self
    setmetatable(o, self)
    o.dirtyFields = {}
    o.needsFullSend = true
    return o
end

function WaitingOnSignal:update(values)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(values) == "table", "Need 'values' as table")

    updateField(self, "signalId", values.signalId)
    updateField(self, "waitingPosition", values.waitingPosition)
    updateField(self, "vehicleName", values.vehicleName)
    updateField(self, "waitingCount", values.waitingCount)
end

function WaitingOnSignal:resetDirty()
    self.dirtyFields = {}
end

function WaitingOnSignal:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return WaitingOnSignal
