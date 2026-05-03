if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.Version ...") end

---@class Version
---@field id string
---@field name string
---@field eepVersion string|nil
---@field luaVersion string|nil
---@field singleVersion string|nil
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local Version = {}

local function markDirty(version, fieldName)
    version.dirtyFields[fieldName] = true
end

local function updateField(version, fieldName, value)
    local oldValue = version[fieldName]
    version[fieldName] = value
    if oldValue ~= value then markDirty(version, fieldName) end
end

function Version:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.id, "Provide an id")

    self.__index = self
    setmetatable(o, self)
    o.dirtyFields = {}
    o.needsFullSend = true
    return o
end

function Version:update(values)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(values) == "table", "Need 'values' as table")

    updateField(self, "name", values.name)
    updateField(self, "eepVersion", values.eepVersion)
    updateField(self, "luaVersion", values.luaVersion)
    updateField(self, "singleVersion", values.singleVersion)
end

function Version:resetDirty()
    self.dirtyFields = {}
end

function Version:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return Version
