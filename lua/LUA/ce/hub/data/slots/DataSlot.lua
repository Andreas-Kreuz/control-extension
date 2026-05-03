if CeDebugLoad then print("[#Start] Loading ce.hub.data.slots.DataSlot ...") end

---@class DataSlot
---@field id number
---@field slotType string
---@field name string|nil
---@field data string|nil
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local DataSlot = {}

local function markDirty(slot, fieldName)
    slot.dirtyFields[fieldName] = true
end

local function updateField(slot, fieldName, value)
    local oldValue = slot[fieldName]
    slot[fieldName] = value
    if oldValue ~= value then markDirty(slot, fieldName) end
end

function DataSlot:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.id, "Provide an id")
    assert(o.slotType, "Provide a slotType")

    self.__index = self
    setmetatable(o, self)
    o.dirtyFields = {}
    o.needsFullSend = true
    return o
end

function DataSlot:update(values)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(values) == "table", "Need 'values' as table")

    updateField(self, "name", values.name)
    updateField(self, "data", values.data)
end

function DataSlot:setSlotType(slotType)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(slotType) == "string", "Need 'slotType' as string")

    if self.slotType ~= slotType then
        self.slotType = slotType
        self.needsFullSend = true
        markDirty(self, "name")
        markDirty(self, "data")
    end
end

function DataSlot:resetDirty()
    self.dirtyFields = {}
end

function DataSlot:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return DataSlot
