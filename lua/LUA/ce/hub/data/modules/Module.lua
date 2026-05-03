if CeDebugLoad then print("[#Start] Loading ce.hub.data.modules.Module ...") end

---@class Module
---@field id string
---@field name string
---@field enabled boolean
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local Module = {}

local function markDirty(module, fieldName)
    module.dirtyFields[fieldName] = true
end

local function updateField(module, fieldName, value)
    local oldValue = module[fieldName]
    module[fieldName] = value
    if oldValue ~= value then markDirty(module, fieldName) end
end

function Module:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.id, "Provide an id")

    self.__index = self
    setmetatable(o, self)
    o.dirtyFields = {}
    o.needsFullSend = true
    return o
end

function Module:update(values)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(values) == "table", "Need 'values' as table")

    updateField(self, "name", values.name)
    updateField(self, "enabled", values.enabled)
end

function Module:resetDirty()
    self.dirtyFields = {}
end

function Module:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return Module
