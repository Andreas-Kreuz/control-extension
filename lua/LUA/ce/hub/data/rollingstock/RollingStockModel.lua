if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockModel ...") end

-- Model metadata extraction: project-docs/ai/guides/lua-rollingstock-models.md
-- Register model names without EEP instance suffixes like ";001".
-- Wagon numbers are vehicle numbers and must not overwrite licence plates.
---@class RollingStockModel
---@field new fun(self: RollingStockModel, o?: table):RollingStockModel
---@field setLine fun(self: RollingStockModel, rollingStockName: string, line: string):nil
---@field setDestination fun(self: RollingStockModel, rollingStockName: string, destination: string):nil
---@field setOrigin fun(self: RollingStockModel, rollingStockName: string, origin: string):nil
---@field setNextStop fun(self: RollingStockModel, rollingStockName: string, nextStop: string):nil
---@field setStations fun(self: RollingStockModel, rollingStockName: string, stations: string):nil
---@field setWagonNr fun(self: RollingStockModel, rollingStockName: string, wagonNumber: string):nil
---@field openDoors fun(self: RollingStockModel, rollingStockName: string):nil
---@field closeDoors fun(self: RollingStockModel, rollingStockName: string):nil
local RollingStockModel = {}

function RollingStockModel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

function RollingStockModel:setLine(rollingStockName, line)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    assert(type(line) == "string", "Need 'line' as string")
    -- Overwrite me
end

function RollingStockModel:setDestination(rollingStockName, destination)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    assert(type(destination) == "string", "Need 'destination' as string")
    -- Overwrite me
end

function RollingStockModel:setOrigin(rollingStockName, origin)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    assert(type(origin) == "string", "Need 'origin' as string")
    -- Overwrite me
end

function RollingStockModel:setNextStop(rollingStockName, nextStop)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    assert(type(nextStop) == "string", "Need 'nextStop' as string")
    -- Overwrite me
end

function RollingStockModel:setStations(rollingStockName, stations)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    assert(type(stations) == "string", "Need 'stations' as string")
    -- Overwrite me
end

function RollingStockModel:setWagonNr(rollingStockName, wagonNumber)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    assert(type(wagonNumber) == "string", "Need 'wagonNumber' as string")
    -- Overwrite me
end

function RollingStockModel:openDoors(rollingStockName)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    -- Overwrite me
end

function RollingStockModel:closeDoors(rollingStockName)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    -- Overwrite me
end

return RollingStockModel
