if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitTrain ...") end

local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local TagKeys = require("ce.hub.data.rollingstock.TagKeys")

local TransitTrain = {}

local function markDirty(transitTrain, fieldName)
    transitTrain.dirtyFields[fieldName] = true
end

---@param hubTrain Train
function TransitTrain:new(hubTrain)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(hubTrain) == "table" and hubTrain.type == "Train", "Need 'hubTrain' as Train")
    local o = {
        id = hubTrain.id,
        type = "TransitTrain",
        hubTrain = hubTrain,
        line = nil,
        destination = nil,
        direction = nil,
        dirtyFields = {},
        needsFullSend = true
    }
    self.__index = self
    setmetatable(o, self)
    return o
end

function TransitTrain:setHubTrain(hubTrain)
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    assert(type(hubTrain) == "table" and hubTrain.type == "Train", "Need 'hubTrain' as Train")
    self.hubTrain = hubTrain
end

local function writeValueToRollingStock(trainName, key, value)
    local carCount = EEPGetRollingstockItemsCount(trainName)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(trainName, i)
        local rs = RollingStockRegistry.forName(rollingStockName)
        rs:setValue(key, value)
    end
end

function TransitTrain:setLine(line)
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    assert("string" == type(line) or "number" == type(line), "Provide 'line' as 'string' or 'number'")
    line = tostring(line)
    local oldLine = self.line
    self.line = line
    writeValueToRollingStock(self.id, TagKeys.Train.line, line)
    local carCount = EEPGetRollingstockItemsCount(self.id)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(self.id, i)
        RollingStockRegistry.forName(rollingStockName).model:setLine(rollingStockName, line)
    end
    if oldLine ~= line then markDirty(self, "line") end
end

function TransitTrain:getLine()
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    return self.line
end

function TransitTrain:updateLine(line)
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    assert(type(line) == "nil" or type(line) == "string" or type(line) == "number", "Need 'line' as string|number|nil")
    if line ~= nil then line = tostring(line) end
    local oldLine = self.line
    self.line = line
    if oldLine ~= line then markDirty(self, "line") end
end

function TransitTrain:setDestination(destination)
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    assert(type(destination) == "string", "Need 'destination' as string")
    local oldDestination = self.destination
    self.destination = destination
    writeValueToRollingStock(self.id, TagKeys.Train.destination, destination)
    local carCount = EEPGetRollingstockItemsCount(self.id)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(self.id, i)
        RollingStockRegistry.forName(rollingStockName).model:setDestination(rollingStockName, destination)
    end
    if oldDestination ~= destination then markDirty(self, "destination") end
end

function TransitTrain:getDestination()
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    return self.destination
end

function TransitTrain:updateDestination(destination)
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    assert(type(destination) == "nil" or type(destination) == "string", "Need 'destination' as string|nil")
    local oldDestination = self.destination
    self.destination = destination
    if oldDestination ~= destination then markDirty(self, "destination") end
end

function TransitTrain:setDirection(direction)
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    assert(type(direction) == "string", "Need 'direction' as string")
    local oldDirection = self.direction
    self.direction = direction
    writeValueToRollingStock(self.id, TagKeys.Train.direction, direction)
    if oldDirection ~= direction then markDirty(self, "direction") end
end

function TransitTrain:getDirection()
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    return self.direction
end

function TransitTrain:updateDirection(direction)
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    assert(type(direction) == "nil" or type(direction) == "string", "Need 'direction' as string|nil")
    local oldDirection = self.direction
    self.direction = direction
    if oldDirection ~= direction then markDirty(self, "direction") end
end

function TransitTrain:changeDestination(destination, line)
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    self:setLine(line)
    self:setDestination(destination)
end

function TransitTrain:resetDirty()
    self.dirtyFields = {}
end

function TransitTrain:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return TransitTrain
