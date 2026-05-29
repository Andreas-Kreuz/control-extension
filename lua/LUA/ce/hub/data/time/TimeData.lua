if CeDebugLoad then print("[#Start] Loading ce.hub.data.time.TimeData ...") end

---@class TimeData
---@field id string
---@field name string
---@field timeComplete number
---@field timeH number
---@field timeM number
---@field timeS number
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local TimeData = {}

local function markDirty(timeData, fieldName)
    timeData.dirtyFields[fieldName] = true
end

local function updateField(timeData, fieldName, value)
    local oldValue = timeData[fieldName]
    timeData[fieldName] = value
    if oldValue ~= value then markDirty(timeData, fieldName) end
end

function TimeData:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.id, "Provide an id")

    self.__index = self
    setmetatable(o, self)
    o.dirtyFields = {}
    o.needsFullSend = true
    return o
end

function TimeData.pullCurrent()
    return {
        id = "times",
        name = "times",
        timeComplete = EEPTime,
        timeH = EEPTimeH,
        timeM = EEPTimeM,
        timeS = EEPTimeS
    }
end

function TimeData:update(values, updatedFields)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(values) == "table", "Need 'values' as table")

    if not updatedFields or updatedFields.name then updateField(self, "name", values.name) end
    if not updatedFields or updatedFields.timeComplete then updateField(self, "timeComplete", values.timeComplete) end
    if not updatedFields or updatedFields.timeH then updateField(self, "timeH", values.timeH) end
    if not updatedFields or updatedFields.timeM then updateField(self, "timeM", values.timeM) end
    if not updatedFields or updatedFields.timeS then updateField(self, "timeS", values.timeS) end
end

function TimeData:resetDirty()
    self.dirtyFields = {}
end

function TimeData:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return TimeData
