if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.Train ...") end
-- local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local TableUtils = require("ce.hub.util.TableUtils")

local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local StorageUtility = require("ce.hub.util.StorageUtility")
local EepCompatibilityApi = require("ce.hub.eep.EepCompatibilityApi")
local EEPGetTrainLength = EepCompatibilityApi.EEPGetTrainLength

---@class Train
---@field id string
---@field name string
---@field type string
---@field values table<string, string>
---@field route string
---@field rollingStockCount number
---@field speed number
---@field targetSpeed number
---@field length number
---@field couplingFront number
---@field couplingRear number
---@field lights table<string, boolean>
---@field active boolean
---@field trainyardId number|nil
---@field inTrainyard boolean
---@field movesForward boolean
---@field trackType string|nil
---@field onTracks table<string, number>
---@field occupiedTracks table<string, number>
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
---@field new fun(self: Train, o: table):Train
---@field load fun(self: Train):table<string, string>
---@field save fun(self: Train, clearCurrentInfo?: boolean):nil
---@field getName fun(self: Train):string
---@field getLength fun(self: Train):number
---@field setLength fun(self: Train, length: number):nil
---@field setValue fun(self: Train, key: string, value: string):nil
---@field getValue fun(self: Train, key: string):string
---@field setRoute fun(self: Train, routeName: string):nil
---@field updateRoute fun(self: Train, routeName: string):nil
---@field getRoute fun(self: Train):string
---@field setRollingStockCount fun(self: Train, count: integer):nil
---@field getRollingStockCount fun(self: Train):number
---@field setSpeed fun(self: Train, speed: number):nil
---@field getSpeed fun(self: Train):number
---@field setTargetSpeed fun(self: Train, targetSpeed: number):nil
---@field getTargetSpeed fun(self: Train):number
---@field setCouplingFront fun(self: Train, couplingFront: number):nil
---@field getCouplingFront fun(self: Train):number
---@field setCouplingRear fun(self: Train, couplingRear: number):nil
---@field getCouplingRear fun(self: Train):number
---@field setLights fun(self: Train, lights: table<string, boolean>):nil
---@field updateLights fun(self: Train):nil
---@field getLights fun(self: Train):table<string, boolean>
---@field setActive fun(self: Train, active: boolean):nil
---@field getActive fun(self: Train):boolean
---@field setTrainyard fun(self: Train, inTrainyard: boolean, trainyardId: number|nil):nil
---@field getTrainyardId fun(self: Train):number|nil
---@field getInTrainyard fun(self: Train):boolean
---@field setMovesForward fun(self: Train, movesForward: boolean):nil
---@field getMovesForward fun(self: Train):boolean
---@field setOnTrack fun(self: Train, onTracks: table<string, number>):nil
---@field getOnTrack fun(self: Train):table<string, number>
---@field setTrackType fun(self: Train, trackType: string):nil
---@field getTrackType fun(self: Train):string|nil
---@field openDoors fun(self: Train):nil
---@field closeDoors fun(self: Train):nil
---@field resetDirty fun(self: Train):nil
---@field hasDirtyFields fun(self: Train):boolean
---@field toJsonStatic fun(self: Train):table
---@field toJsonDynamic fun(self: Train):table
local Train = {}
local TRAIN_LIGHT_SOURCES = { 0, 1, 2, 3 }

-- Field update policies (see TrainStaticDtoTypes.d.lua / TrainDynamicDtoTypes.d.lua):
--   always   => real value always included in DTO
--   ondemand => real value only when InterestSyncRegistry.isSelected; placeholder (0/false/"") otherwise
--   never    => always placeholder, never sent to clients

local function markDirty(train, fieldName)
    train.dirtyFields[fieldName] = true
end

local function getTrainLights(trainName)
    local lights = {}
    for _, source in ipairs(TRAIN_LIGHT_SOURCES) do
        local ok, enabled = false, false
        if EEPGetTrainLight then ok, enabled = EEPGetTrainLight(trainName, source) end
        lights[tostring(source)] = ok and enabled == true or false
    end
    return lights
end


---Create a new train with the given object
---@param o table must contain a string o.name
function Train:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(o, "Provide a train object")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.name, "Provide a name for the train")
    assert(type(o.name) == "string", "Need 'o.name' as string")
    local haveTrain, trainRoute = EEPGetTrainRoute(o.name)
    local rollingStockCount = EEPGetRollingstockItemsCount(o.name)
    local _, length = EEPGetTrainLength(o.name)
    local _, speed = EEPGetTrainSpeed(o.name)
    local _, targetSpeed = EEPGetTrainSpeed(o.name, true)
    local _, couplingFront = false, nil
    if EEPGetTrainCouplingFront then _, couplingFront = EEPGetTrainCouplingFront(o.name) end
    local _, couplingRear = false, nil
    if EEPGetTrainCouplingRear then _, couplingRear = EEPGetTrainCouplingRear(o.name) end
    local activeTrain = EEPGetTrainActive and EEPGetTrainActive() or ""
    local lights = getTrainLights(o.name)
    local inTrainyard, trainyardId = false, nil
    if EEPIsTrainInTrainyard then inTrainyard, trainyardId = EEPIsTrainInTrainyard(o.name) end
    assert(haveTrain, o.name)
    self.__index = self
    setmetatable(o, self)
    o.id = o.name
    o.type = "Train"
    o.values = o:load()
    o.route = trainRoute
    o.rollingStockCount = rollingStockCount
    o.length = tonumber(string.format("%.2f", length or 0)) or 0
    o.speed = speed
    o.targetSpeed = targetSpeed or speed
    o.couplingFront = couplingFront or 0
    o.couplingRear = couplingRear or 0
    o.lights = lights
    o.active = activeTrain == o.name
    o.inTrainyard = inTrainyard == true
    o.trainyardId = inTrainyard and trainyardId or nil
    o.movesForward = speed >= 0
    o.trackType = nil
    o.onTracks = {}
    o.occupiedTracks = {}
    o.dirtyFields = {}
    o.needsFullSend = true
    return o
end

---Loads a table with values from the first rollingstock of the train
function Train:load()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    local rollingStockName = EEPGetRollingstockItemName(self.name, 0)
    return StorageUtility.loadTableRollingStock(rollingStockName)
end

---Adds or replaces all table values to ALL rolling stock of the train
function Train:save(clearCurrentInfo)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    local carCount = EEPGetRollingstockItemsCount(self.name)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(self.name, i)
        RollingStockRegistry.forName(rollingStockName):save(clearCurrentInfo)
    end
end

--- Gets the trains name
---@return string trains name
function Train:getName()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.name
end

--- Gets the length of the train in meters
---@return number length of the train in meters
function Train:getLength()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.length
end

function Train:setLength(length)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(length) == "number", "Need 'length' as number")
    length = tonumber(string.format("%.2f", length)) or 0
    local oldLength = self.length
    self.length = length
    if oldLength ~= length then markDirty(self, "length") end
end

---Adds or replaces a value to ALL rolling stock of the train
---@param key string
---@param value string
function Train:setValue(key, value)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(key) == "string", "Need 'key' as string")
    assert(type(value) == "string", "Need 'value' as string")
    self.values[key] = value
    local carCount = EEPGetRollingstockItemsCount(self.name)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(self.name, i)
        local rs = RollingStockRegistry.forName(rollingStockName)
        rs:setValue(key, value)
    end
end

---Get the current value for key
---@param key string
---@return string value
function Train:getValue(key)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(key) == "string", "Need 'key' as string")
    return self.values[key]
end

--- Changes the trains route
---@param routeName string Route like set in EEP
function Train:setRoute(routeName)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(routeName) == "string", "Need 'route' as string")
    local oldRoute = self.route
    self.route = routeName
    EEPSetTrainRoute(self.name, self.route)
    if oldRoute ~= routeName then
        markDirty(self, "route")
    end
end

function Train:updateRoute(routeName)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(routeName) == "string", "Need 'route' as string")
    local oldRoute = self.route
    self.route = routeName
    if oldRoute ~= routeName then markDirty(self, "route") end
end

--- Gets the trains route like used in EEP
---@return string route name like in EEP
function Train:getRoute()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.route
end

--- Updates the trains rolling stock count
---@param count integer number of cars
function Train:setRollingStockCount(count)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(count) == "number", "Need 'count' as number")
    local oldCount = self.rollingStockCount
    self.rollingStockCount = count
    if oldCount ~= count then
        markDirty(self, "rollingStockCount")
    end
end

--- Gets the trains route like used in EEP
---@return number number of cars
function Train:getRollingStockCount()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.rollingStockCount
end

--- Updates the trains speed in km/h
---@param speed number train speed in km/h
function Train:setSpeed(speed)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(speed) == "number", "Need 'speed' as number")
    speed = tonumber(string.format("%1.1f", speed)) or 0
    local oldSpeed = self.speed
    self.speed = speed
    if oldSpeed ~= speed then
        markDirty(self, "speed")
        if (oldSpeed < 0 and speed > 0) then self:setMovesForward(true) end
        if (oldSpeed > 0 and speed < 0) then self:setMovesForward(false) end
    end
end

--- Gets the trains speed in km/h
---@return number train speed in km/h
function Train:getSpeed()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.speed
end

function Train:setTargetSpeed(targetSpeed)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(targetSpeed) == "number", "Need 'targetSpeed' as number")
    targetSpeed = tonumber(string.format("%1.1f", targetSpeed)) or 0
    local oldTargetSpeed = self.targetSpeed
    self.targetSpeed = targetSpeed
    if oldTargetSpeed ~= targetSpeed then markDirty(self, "targetSpeed") end
end

function Train:getTargetSpeed()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.targetSpeed
end

function Train:setCouplingFront(couplingFront)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(couplingFront) == "number", "Need 'couplingFront' as number")
    local oldCouplingFront = self.couplingFront
    self.couplingFront = couplingFront
    if oldCouplingFront ~= couplingFront then markDirty(self, "couplingFront") end
end

function Train:getCouplingFront()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.couplingFront
end

function Train:setCouplingRear(couplingRear)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(couplingRear) == "number", "Need 'couplingRear' as number")
    local oldCouplingRear = self.couplingRear
    self.couplingRear = couplingRear
    if oldCouplingRear ~= couplingRear then markDirty(self, "couplingRear") end
end

function Train:getCouplingRear()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.couplingRear
end

function Train:setLights(lights)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(lights) == "table", "Need 'lights' as table")
    local changed = false
    for _, source in ipairs(TRAIN_LIGHT_SOURCES) do
        local key = tostring(source)
        local value = lights[key] == true
        if self.lights[key] ~= value then
            self.lights[key] = value
            changed = true
        end
    end
    if changed then markDirty(self, "lights") end
end

function Train:updateLights()
    self:setLights(getTrainLights(self.name))
end

function Train:getLights()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.lights
end

function Train:setActive(active)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(active) == "boolean", "Need 'active' as boolean")
    local oldActive = self.active
    self.active = active
    if oldActive ~= active then markDirty(self, "active") end
end

function Train:getActive()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.active
end

function Train:setTrainyard(inTrainyard, trainyardId)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(inTrainyard) == "boolean", "Need 'inTrainyard' as boolean")
    local oldInTrainyard = self.inTrainyard
    local oldTrainyardId = self.trainyardId
    self.inTrainyard = inTrainyard
    self.trainyardId = inTrainyard and trainyardId or nil
    if oldInTrainyard ~= self.inTrainyard or oldTrainyardId ~= self.trainyardId then
        markDirty(self, "inTrainyard")
        markDirty(self, "trainyardId")
    end
end

function Train:getTrainyardId()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.trainyardId
end

function Train:getInTrainyard()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.inTrainyard
end

--- Updates the trains speed in km/h
---@param movesForward boolean indicates if the train moves forward or backward
function Train:setMovesForward(movesForward)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(movesForward) == "boolean", "Need 'movesForward' as boolean")
    local oldMovesForward = self.movesForward
    self.movesForward = movesForward
    if oldMovesForward ~= movesForward then
        markDirty(self, "movesForward")
    end
end

--- Gets the trains speed in km/h
---@return boolean train speed in km/h
function Train:getMovesForward()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.movesForward
end

--- Updates tracks of the current train
---@param onTracks table<string, number>
function Train:setOnTrack(onTracks)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(onTracks) == "table", "Need 'onTracks' as table")
    local oldOnTracks = self.onTracks
    self.onTracks = onTracks
    if not TableUtils.sameDictEntries(oldOnTracks, onTracks) then
        markDirty(self, "onTracks")
    end
end

--- Gets the tracks of the current train
---@return table<string, number>
function Train:getOnTrack()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.onTracks
end

function Train:setTrackType(trackType)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(trackType) == "string", "Need 'trackType' as string")
    local oldTrackType = self.trackType
    self.trackType = trackType
    if oldTrackType ~= trackType then
        markDirty(self, "trackType")
    end
end

function Train:getTrackType() return self.trackType end

function Train:openDoors()
    local carCount = EEPGetRollingstockItemsCount(self.name)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(self.name, i)
        RollingStockRegistry.forName(rollingStockName):openDoors()
    end
end

function Train:closeDoors()
    local carCount = EEPGetRollingstockItemsCount(self.name)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(self.name, i)
        RollingStockRegistry.forName(rollingStockName):closeDoors()
    end
end

function Train:resetDirty()
    self.dirtyFields = {}
end

function Train:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

function Train:toJsonStatic()
    return {
        id = self:getName(),
        route = self:getRoute(),
        rollingStockCount = self:getRollingStockCount(),
        length = self:getLength(),
        trackType = self:getTrackType(),
        movesForward = self:getMovesForward(),
        speed = self:getSpeed(),
        targetSpeed = self:getTargetSpeed(),
        couplingFront = self:getCouplingFront(),
        couplingRear = self:getCouplingRear(),
        lights = self:getLights(),
        active = self:getActive(),
        inTrainyard = self:getInTrainyard(),
        trainyardId = self:getTrainyardId(),
        occupiedTacks = self:getOnTrack()
    }
end

function Train:toJsonDynamic()
    return {
        id = self:getName(),
        trackType = self:getTrackType(),
        speed = self:getSpeed(),
        occupiedTacks = self:getOnTrack()
    }
end

return Train
