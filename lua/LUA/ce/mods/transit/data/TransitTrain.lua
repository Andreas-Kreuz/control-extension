if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitTrain ...") end

local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local TagKeys = require("ce.hub.data.rollingstock.TagKeys")

local TransitTrain = {}

local function markDirty(transitTrain, fieldName)
    transitTrain.dirtyFields[fieldName] = true
end

local function normalizeNextStations(nextStations)
    local normalized = {}
    for _, entry in ipairs(nextStations or {}) do
        if #normalized >= 5 then break end
        table.insert(normalized, {
            station = entry.station,
            platform = tostring(entry.platform or "1"),
            departureInMinutes = entry.departureInMinutes
        })
    end
    return normalized
end

local function nextStationsEqual(left, right)
    if #left ~= #right then return false end
    for index, leftEntry in ipairs(left) do
        local rightEntry = right[index]
        local leftStationName = leftEntry.station and leftEntry.station.name or nil
        local rightStationName = rightEntry.station and rightEntry.station.name or nil
        if leftStationName ~= rightStationName then return false end
        if leftEntry.platform ~= rightEntry.platform then return false end
        if leftEntry.departureInMinutes ~= rightEntry.departureInMinutes then return false end
    end
    return true
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
        origin = nil,
        direction = nil,
        nextStations = {},
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

local function updateRollingStockModels(trainName, updateModel)
    local carCount = EEPGetRollingstockItemsCount(trainName)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(trainName, i)
        local model = RollingStockRegistry.forName(rollingStockName).model
        updateModel(model, rollingStockName)
    end
end

function TransitTrain:setLine(line)
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    assert("string" == type(line) or "number" == type(line), "Provide 'line' as 'string' or 'number'")
    line = tostring(line)
    local oldLine = self.line
    self.line = line
    writeValueToRollingStock(self.id, TagKeys.Train.line, line)
    updateRollingStockModels(self.id, function(model, rollingStockName)
        model:setLine(rollingStockName, line)
    end)
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
    updateRollingStockModels(self.id, function(model, rollingStockName)
        model:setDestination(rollingStockName, destination)
    end)
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

function TransitTrain:setOrigin(origin)
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    assert(type(origin) == "string", "Need 'origin' as string")
    local oldOrigin = self.origin
    self.origin = origin
    updateRollingStockModels(self.id, function(model, rollingStockName)
        model:setOrigin(rollingStockName, origin)
    end)
    if oldOrigin ~= origin then markDirty(self, "origin") end
end

function TransitTrain:getOrigin()
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    return self.origin
end

function TransitTrain:updateOrigin(origin)
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    assert(type(origin) == "nil" or type(origin) == "string", "Need 'origin' as string|nil")
    local oldOrigin = self.origin
    self.origin = origin
    if oldOrigin ~= origin then markDirty(self, "origin") end
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

function TransitTrain:setNextStations(nextStations)
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    assert(type(nextStations) == "nil" or type(nextStations) == "table", "Need 'nextStations' as table|nil")
    local normalized = normalizeNextStations(nextStations)
    for _, entry in ipairs(normalized) do
        assert(type(entry.station) == "table" and entry.station.type == "RoadStation",
               "Need 'station' as RoadStation")
        assert(type(entry.platform) == "string", "Need 'platform' as string")
        assert(type(entry.departureInMinutes) == "number", "Need 'departureInMinutes' as number")
    end

    if not nextStationsEqual(self.nextStations, normalized) then
        self.nextStations = normalized
        markDirty(self, "nextStations")
    end
    local firstNextStation = normalized[1]
    local nextStop = firstNextStation and firstNextStation.station.name or ""
    updateRollingStockModels(self.id, function(model, rollingStockName)
        model:setNextStop(rollingStockName, nextStop)
    end)
end

function TransitTrain:getNextStations()
    assert(type(self) == "table" and self.type == "TransitTrain", "Call this method with ':'")
    return normalizeNextStations(self.nextStations)
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
