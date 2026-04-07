if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.Signal ...") end

---@class Signal
---@field id number
---@field position number
---@field tag string
---@field waitingVehiclesCount number
---@field stopDistance number|nil
---@field itemName string|nil
---@field itemNameWithModelPath string|nil
---@field signalFunctions string[]|nil
---@field activeFunction string|nil
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local Signal = {}

local function markDirty(signal, fieldName)
    signal.dirtyFields[fieldName] = true
end

function Signal:new(id)
    local o = {
        id = id,
        position = 0,
        tag = "",
        waitingVehiclesCount = 0,
        stopDistance = nil,
        itemName = nil,
        itemNameWithModelPath = nil,
        signalFunctions = nil,
        activeFunction = nil,
        dirtyFields = {},
        needsFullSend = true
    }
    self.__index = self
    setmetatable(o, self)
    return o
end

function Signal:getPosition() return self.position end

function Signal:getTag() return self.tag end

function Signal:getWaitingVehiclesCount() return self.waitingVehiclesCount end

function Signal:getStopDistance() return self.stopDistance end

function Signal:getItemName() return self.itemName end

function Signal:getItemNameWithModelPath() return self.itemNameWithModelPath end

function Signal:getSignalFunctions() return self.signalFunctions end

function Signal:getActiveFunction() return self.activeFunction end

function Signal:setPosition(position)
    if self.position ~= position then
        self.position = position
        markDirty(self, "position")
    end
end

function Signal:setTag(tag)
    local value = tag or ""
    if self.tag ~= value then
        self.tag = value
        markDirty(self, "tag")
    end
end

function Signal:setWaitingVehiclesCount(waitingVehiclesCount)
    local value = waitingVehiclesCount or 0
    if self.waitingVehiclesCount ~= value then
        self.waitingVehiclesCount = value
        markDirty(self, "waitingVehiclesCount")
    end
end

function Signal:setStopDistance(stopDistance)
    if self.stopDistance ~= stopDistance then
        self.stopDistance = stopDistance
        markDirty(self, "stopDistance")
    end
end

function Signal:setItemName(itemName, itemNameWithModelPath)
    if self.itemName ~= itemName then
        self.itemName = itemName
        markDirty(self, "itemName")
    end
    if self.itemNameWithModelPath ~= itemNameWithModelPath then
        self.itemNameWithModelPath = itemNameWithModelPath
        markDirty(self, "itemNameWithModelPath")
    end
end

function Signal:setFunctions(signalFunctions, activeFunction)
    local currentFunctions = self.signalFunctions or {}
    local changed = #currentFunctions ~= #(signalFunctions or {})
    if not changed then
        for i = 1, #currentFunctions do
            if currentFunctions[i] ~= signalFunctions[i] then
                changed = true
                break
            end
        end
    end
    if changed then
        self.signalFunctions = signalFunctions
        markDirty(self, "signalFunctions")
    end
    if self.activeFunction ~= activeFunction then
        self.activeFunction = activeFunction
        markDirty(self, "activeFunction")
    end
end

function Signal:resetDirty()
    self.dirtyFields = {}
end

function Signal:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return Signal
