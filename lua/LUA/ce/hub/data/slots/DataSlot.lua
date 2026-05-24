if CeDebugLoad then print("[#Start] Loading ce.hub.data.slots.DataSlot ...") end

---@class DataSlot
---@field id number
---@field slotType string
---@field name string|nil
---@field data string|nil
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
---@field getData fun(self: DataSlot):string|nil
---@field setData fun(self: DataSlot, data: string):boolean
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

function DataSlot.loadFromEep(id, nameResolver, storageUtility)
    local slot = DataSlot:new({ id = id, slotType = "empty" })
    local hResult, data = slot:pullData()
    if hResult then
        local name = nameResolver.getSlotName(id) or storageUtility.getName(id) or "?"
        slot:setSlotType("filled")
        slot:update({ name = name, data = data })
        return slot, true
    end
    return slot, false
end

function DataSlot:update(values)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(values) == "table", "Need 'values' as table")

    updateField(self, "name", values.name)
    updateField(self, "data", values.data)
end

function DataSlot:peekData()
    assert(type(self) == "table", "Call this method with ':'")
    return self.data
end

function DataSlot:getData()
    assert(type(self) == "table", "Call this method with ':'")
    if self.data == nil then self:pullData() end
    return self.data
end

function DataSlot:pullData()
    assert(type(self) == "table", "Call this method with ':'")
    local hResult, data = EEPLoadData(self.id)
    if hResult then
        updateField(self, "data", data)
        self:setSlotType("filled")
    end
    return hResult, data
end

function DataSlot:setData(data)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(data) == "string", "Need 'data' as string")
    if self.data == data and self.slotType == "filled" then return true end
    local hResult = EEPSaveData(self.id, data)
    if hResult then
        updateField(self, "data", data)
        self:setSlotType("filled")
    end
    return hResult
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
