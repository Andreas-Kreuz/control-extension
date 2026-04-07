if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.Switch ...") end

---@class Switch
---@field id number
---@field position number
---@field tag string
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local Switch = {}

local function markDirty(switch, fieldName)
    switch.dirtyFields[fieldName] = true
end

function Switch:new(id)
    local o = {
        id = id,
        position = 0,
        tag = "",
        dirtyFields = {},
        needsFullSend = true
    }
    self.__index = self
    setmetatable(o, self)
    return o
end

function Switch:getPosition() return self.position end

function Switch:getTag() return self.tag end

function Switch:setPosition(position)
    if self.position ~= position then
        self.position = position
        markDirty(self, "position")
    end
end

function Switch:setTag(tag)
    local value = tag or ""
    if self.tag ~= value then
        self.tag = value
        markDirty(self, "tag")
    end
end

function Switch:resetDirty()
    self.dirtyFields = {}
end

function Switch:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return Switch
