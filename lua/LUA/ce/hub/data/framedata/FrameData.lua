if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameData ...") end

---@class FrameData
---@field id string
---@field framesPerSecond number|nil
---@field currentFrame number|nil
---@field currentRenderFrame number|nil
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local FrameData = {}

local function markDirty(frameData, fieldName)
    frameData.dirtyFields[fieldName] = true
end

local function updateField(frameData, fieldName, value)
    local oldValue = frameData[fieldName]
    frameData[fieldName] = value
    if oldValue ~= value then markDirty(frameData, fieldName) end
end

function FrameData:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.id, "Provide an id")

    self.__index = self
    setmetatable(o, self)
    o.dirtyFields = {}
    o.needsFullSend = true
    return o
end

function FrameData:update(values)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(values) == "table", "Need 'values' as table")

    updateField(self, "framesPerSecond", values.framesPerSecond)
    updateField(self, "currentFrame", values.currentFrame)
    updateField(self, "currentRenderFrame", values.currentRenderFrame)
end

function FrameData:resetDirty()
    self.dirtyFields = {}
end

function FrameData:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return FrameData
