if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimeEntry ...") end

---@class RuntimeEntry
---@field id string
---@field count number
---@field time number
---@field lastTime number
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local RuntimeEntry = {}

local function markDirty(runtimeEntry, fieldName)
    runtimeEntry.dirtyFields[fieldName] = true
end

local function updateField(runtimeEntry, fieldName, value)
    local oldValue = runtimeEntry[fieldName]
    runtimeEntry[fieldName] = value
    if oldValue ~= value then markDirty(runtimeEntry, fieldName) end
end

function RuntimeEntry:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.id, "Provide an id")

    self.__index = self
    setmetatable(o, self)
    o.dirtyFields = {}
    o.needsFullSend = true
    return o
end

function RuntimeEntry:update(values)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(values) == "table", "Need 'values' as table")

    updateField(self, "count", values.count)
    updateField(self, "time", values.time)
    updateField(self, "lastTime", values.lastTime)
end

function RuntimeEntry:resetDirty()
    self.dirtyFields = {}
end

function RuntimeEntry:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return RuntimeEntry
