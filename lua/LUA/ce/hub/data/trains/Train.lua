if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.Train ...") end
-- local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local DataClass = require("ce.hub.data.DataClass")
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
---@field axisValues table<string, number>
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
---@field setLicencePlate fun(self: Train, licencePlate: string):nil
---@field setWagonNumber fun(self: Train, wagonNumber: string):nil
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
local Train = {}
local TRAIN_LIGHT_SOURCES = { 0, 1, 2, 3 }

-- Field update policies (see TrainStaticDtoTypes.d.lua / TrainDynamicDtoTypes.d.lua):
--   always   => real value always included in DTO
--   ondemand => real value only when InterestSyncRegistry.isSelected; placeholder (0/false/"") otherwise
--   never    => always placeholder, never sent to clients

local function markDirty(train, fieldName)
    train.dirtyFields[fieldName] = true
end

local function markLoaded(train, fieldName)
    DataClass.markLoaded(train, fieldName)
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

local function snapshotNumber(snapshot, fieldName)
    if snapshot[fieldName] == nil then return nil end
    return tonumber(snapshot[fieldName])
end

local function markLoadedFromSnapshot(instance, snapshot, snapshotFieldName, fieldName)
    if snapshot[snapshotFieldName] ~= nil then DataClass.markLoaded(instance, fieldName or snapshotFieldName) end
end

---Create a new train with the given object
---@param o table must contain a string o.name
function Train:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(o, "Provide a train object")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.name, "Provide a name for the train")
    assert(type(o.name) == "string", "Need 'o.name' as string")
    return Train.fromSnapshot(o)
end

function Train.forName(trainName)
    return require("ce.hub.data.trains.TrainRegistry").getOrCreate(trainName)
end

function Train.fromSnapshot(snapshot)
    assert(type(snapshot) == "table", "Need snapshot as table")
    assert(type(snapshot.name) == "string", "Need snapshot.name as string")

    local speed = snapshotNumber(snapshot, "speed") or 0
    local o = {
        id = snapshot.name,
        name = snapshot.name,
        type = "Train",
        values = snapshot.values or {},
        route = snapshot.route or "",
        rollingStockCount = snapshotNumber(snapshot, "rollingStockCount") or 0,
        speed = speed,
        targetSpeed = snapshotNumber(snapshot, "targetSpeed") or speed,
        length = snapshotNumber(snapshot, "length") or 0,
        couplingFront = snapshotNumber(snapshot, "couplingFront") or 0,
        couplingRear = snapshotNumber(snapshot, "couplingRear") or 0,
        lights = snapshot.lights or {},
        axisValues = snapshot.axisValues or {},
        active = snapshot.active == true,
        inTrainyard = snapshot.inTrainyard == true,
        trainyardId = snapshot.trainyardId,
        movesForward = snapshot.movesForward ~= nil and snapshot.movesForward == true or speed >= 0,
        trackType = snapshot.trackType,
        onTracks = snapshot.onTracks or {},
        occupiedTracks = {},
        dirtyFields = {},
        needsFullSend = true
    }

    Train.__index = Train
    setmetatable(o, Train)
    DataClass.init(o)
    markLoadedFromSnapshot(o, snapshot, "route")
    markLoadedFromSnapshot(o, snapshot, "rollingStockCount")
    markLoadedFromSnapshot(o, snapshot, "speed")
    markLoadedFromSnapshot(o, snapshot, "targetSpeed")
    markLoadedFromSnapshot(o, snapshot, "length")
    markLoadedFromSnapshot(o, snapshot, "couplingFront")
    markLoadedFromSnapshot(o, snapshot, "couplingRear")
    markLoadedFromSnapshot(o, snapshot, "lights")
    markLoadedFromSnapshot(o, snapshot, "active")
    markLoadedFromSnapshot(o, snapshot, "inTrainyard")
    markLoadedFromSnapshot(o, snapshot, "trainyardId")
    markLoadedFromSnapshot(o, snapshot, "movesForward")
    markLoadedFromSnapshot(o, snapshot, "trackType")
    markLoadedFromSnapshot(o, snapshot, "onTracks")
    return o
end

function Train:pullInitial()
    local haveTrain = EEPGetTrainRoute and EEPGetTrainRoute(self.name)
    assert(haveTrain, self.name)

    self.values = self:load()
    self:pullRoute()
    if EEPGetRollingstockItemsCount then self:setRollingStockCount(EEPGetRollingstockItemsCount(self.name)) end
    self:pullLength()
    if EEPGetTrainSpeed then
        local _, speed = EEPGetTrainSpeed(self.name)
        self:setSpeed(speed or 0)
    end
    self:pullTargetSpeed(self.speed)
    self:pullCouplingFront()
    self:pullCouplingRear()
    self:pullLights()
    self:pullActive()
    self:pullTrainyard()
    self:resetDirty()
    return self
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
        RollingStockRegistry.getOrCreate(rollingStockName):save(clearCurrentInfo)
    end
end

--- Gets the trains name
---@return string trains name
function Train:getName()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    return self.name
end

function Train:peekName() return self.name end

--- Gets the length of the train in meters
---@return number length of the train in meters
function Train:getLength()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    if not DataClass.isLoaded(self, "length") then self:pullLength() end
    return self.length
end

function Train:peekLength() return self.length end

function Train:setLength(length)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(length) == "number", "Need 'length' as number")
    length = tonumber(string.format("%.2f", length)) or 0
    local oldLength = self.length
    self.length = length
    markLoaded(self, "length")
    if oldLength ~= length then markDirty(self, "length") end
end

function Train:pullLength()
    if not DataClass.isCallable(EEPGetTrainLength) then return nil end
    local _, length = EEPGetTrainLength(self.name)
    if length then self:setLength(length) end
    return self.length
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
        local rs = RollingStockRegistry.getOrCreate(rollingStockName)
        rs:setValue(key, value)
    end
end

---Get the current value for key
---@param key string
---@return string value
function Train:getValue(key)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(key) == "string", "Need 'key' as string")
    if self.values == nil then self.values = self:load() end
    return self.values[key]
end

--- Changes the trains route
---@param routeName string Route like set in EEP
function Train:setRoute(routeName)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(routeName) == "string", "Need 'route' as string")
    if self.route == routeName then return true end
    local ok = true
    if EEPSetTrainRoute then ok = EEPSetTrainRoute(self.name, routeName) ~= false end
    if not ok then return false end
    self:replaceRoute(routeName)
    return true
end

function Train:replaceRoute(routeName)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(routeName) == "string", "Need 'route' as string")
    local oldRoute = self.route
    self.route = routeName
    markLoaded(self, "route")
    if oldRoute ~= routeName then markDirty(self, "route") end
end

function Train:updateRoute(routeName)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(routeName) == "string", "Need 'route' as string")
    self:replaceRoute(routeName)
end

function Train:pullRoute()
    if not DataClass.isCallable(EEPGetTrainRoute) then return nil end
    local routeOk, routeName = EEPGetTrainRoute(self.name)
    if not routeOk then return nil end
    self:replaceRoute(routeName or "")
    return self.route
end

--- Gets the trains route like used in EEP
---@return string route name like in EEP
function Train:getRoute()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    if not DataClass.isLoaded(self, "route") then self:pullRoute() end
    return self.route
end

function Train:peekRoute() return self.route end

function Train:setLicencePlate(licencePlate)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(licencePlate) == "string", "Need 'licencePlate' as string")
    local carCount = EEPGetRollingstockItemsCount(self.name)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(self.name, i)
        RollingStockRegistry.getOrCreate(rollingStockName):setLicencePlate(licencePlate)
    end
end

function Train:setWagonNumber(wagonNumber)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(wagonNumber) == "string", "Need 'wagonNumber' as string")
    local carCount = EEPGetRollingstockItemsCount(self.name)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(self.name, i)
        RollingStockRegistry.getOrCreate(rollingStockName):setWagonNumber(wagonNumber)
    end
end

--- Updates the trains rolling stock count
---@param count integer number of cars
function Train:setRollingStockCount(count)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(count) == "number", "Need 'count' as number")
    local oldCount = self.rollingStockCount
    self.rollingStockCount = count
    markLoaded(self, "rollingStockCount")
    if oldCount ~= count then
        markDirty(self, "rollingStockCount")
    end
end

--- Gets the trains route like used in EEP
---@return number number of cars
function Train:getRollingStockCount()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    if not DataClass.isLoaded(self, "rollingStockCount") then self:pullRollingStockCount() end
    return self.rollingStockCount
end

function Train:peekRollingStockCount() return self.rollingStockCount end

function Train:pullRollingStockCount()
    if not DataClass.isCallable(EEPGetRollingstockItemsCount) then return nil end
    self:setRollingStockCount(EEPGetRollingstockItemsCount(self.name) or 0)
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
    markLoaded(self, "speed")
    if oldSpeed ~= speed then
        markDirty(self, "speed")
        if type(oldSpeed) == "number" and oldSpeed < 0 and speed > 0 then self:setMovesForward(true) end
        if type(oldSpeed) == "number" and oldSpeed > 0 and speed < 0 then self:setMovesForward(false) end
    end
end

function Train:pullSpeed()
    if not DataClass.isCallable(EEPGetTrainSpeed) then return nil end
    local _, speed = EEPGetTrainSpeed(self.name)
    self:setSpeed(speed or 0)
    return self.speed
end

--- Gets the trains speed in km/h
---@return number train speed in km/h
function Train:getSpeed()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    if not DataClass.isLoaded(self, "speed") then self:pullSpeed() end
    return self.speed
end

function Train:peekSpeed() return self.speed end

function Train:setTargetSpeed(targetSpeed)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(targetSpeed) == "number", "Need 'targetSpeed' as number")
    targetSpeed = tonumber(string.format("%1.1f", targetSpeed)) or 0
    local oldTargetSpeed = self.targetSpeed
    self.targetSpeed = targetSpeed
    markLoaded(self, "targetSpeed")
    if oldTargetSpeed ~= targetSpeed then markDirty(self, "targetSpeed") end
end

function Train:pullTargetSpeed(fallbackSpeed)
    if not DataClass.isCallable(EEPGetTrainSpeed) then return nil end
    local _, targetSpeed = EEPGetTrainSpeed(self.name, true)
    self:setTargetSpeed(targetSpeed or fallbackSpeed or self.speed or 0)
    return self.targetSpeed
end

function Train:getTargetSpeed()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    if not DataClass.isLoaded(self, "targetSpeed") then self:pullTargetSpeed() end
    return self.targetSpeed
end

function Train:peekTargetSpeed() return self.targetSpeed end

function Train:setCouplingFront(couplingFront)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(couplingFront) == "number", "Need 'couplingFront' as number")
    local oldCouplingFront = self.couplingFront
    self.couplingFront = couplingFront
    markLoaded(self, "couplingFront")
    if oldCouplingFront ~= couplingFront then markDirty(self, "couplingFront") end
end

function Train:pullCouplingFront()
    if not DataClass.isCallable(EEPGetTrainCouplingFront) then return nil end
    local ok, trainCouplingFront = EEPGetTrainCouplingFront(self.name)
    if ok then self:setCouplingFront(trainCouplingFront) end
    return self.couplingFront
end

function Train:getCouplingFront()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    if not DataClass.isLoaded(self, "couplingFront") then self:pullCouplingFront() end
    return self.couplingFront
end

function Train:peekCouplingFront() return self.couplingFront end

function Train:setCouplingRear(couplingRear)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(couplingRear) == "number", "Need 'couplingRear' as number")
    local oldCouplingRear = self.couplingRear
    self.couplingRear = couplingRear
    markLoaded(self, "couplingRear")
    if oldCouplingRear ~= couplingRear then markDirty(self, "couplingRear") end
end

function Train:pullCouplingRear()
    if not DataClass.isCallable(EEPGetTrainCouplingRear) then return nil end
    local ok, trainCouplingRear = EEPGetTrainCouplingRear(self.name)
    if ok then self:setCouplingRear(trainCouplingRear) end
    return self.couplingRear
end

function Train:getCouplingRear()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    if not DataClass.isLoaded(self, "couplingRear") then self:pullCouplingRear() end
    return self.couplingRear
end

function Train:peekCouplingRear() return self.couplingRear end

function Train:setLights(lights)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(lights) == "table", "Need 'lights' as table")
    local changed = false
    self.lights = self.lights or {}
    for _, source in ipairs(TRAIN_LIGHT_SOURCES) do
        local key = tostring(source)
        local value = lights[key] == true
        if self.lights[key] ~= value then
            self.lights[key] = value
            changed = true
        end
    end
    if changed then markDirty(self, "lights") end
    markLoaded(self, "lights")
end

function Train:peekLight(source)
    return self.lights and self.lights[tostring(source)] or nil
end

function Train:setLight(enabled, source)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    local lightSource = tonumber(source) or 0
    if lightSource < 0 or lightSource > 3 then return false end
    local value = enabled == true
    local key = tostring(lightSource)
    if DataClass.isLoaded(self, "lights") and self:peekLight(key) == value then return true end
    if not DataClass.isCallable(EEPSetTrainLight) then return false end

    local ok = EEPSetTrainLight(self.name, value, lightSource) ~= false
    if ok then
        self.lights = self.lights or {}
        local oldValue = self.lights[key]
        self.lights[key] = value
        markLoaded(self, "lights")
        if oldValue ~= value then markDirty(self, "lights") end
    end
    return ok
end

function Train:updateLights()
    self:setLights(getTrainLights(self.name))
end

function Train:pullLights()
    self:updateLights()
    return self.lights
end

function Train:getLights()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    if not DataClass.isLoaded(self, "lights") then self:pullLights() end
    return self.lights
end

function Train:peekLights() return self.lights end

function Train:peekAxis(axisName)
    return self.axisValues and self.axisValues[tostring(axisName)] or nil
end

function Train:setAxis(axisName, axisValue)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(axisName) == "string", "Need 'axisName' as string")
    local value = tonumber(axisValue)
    if not value then return false end
    if self:peekAxis(axisName) == value then return true end

    local ok = true
    if EEPSetTrainAxis then ok = EEPSetTrainAxis(self.name, axisName, value) ~= false end
    if ok then
        self.axisValues = self.axisValues or {}
        self.axisValues[tostring(axisName)] = value
        markLoaded(self, "axisValues")
        markDirty(self, "axisValues")
    end
    return ok
end

function Train:setActive(active)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(active) == "boolean", "Need 'active' as boolean")
    local oldActive = self.active
    self.active = active
    markLoaded(self, "active")
    if oldActive ~= active then markDirty(self, "active") end
end

function Train:pullActive()
    local activeTrain = EEPGetTrainActive and EEPGetTrainActive() or ""
    self:setActive(activeTrain == self.name)
    return self.active
end

function Train:getActive()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    if not DataClass.isLoaded(self, "active") then self:pullActive() end
    return self.active
end

function Train:peekActive() return self.active end

function Train:setTrainyard(inTrainyard, trainyardId)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(inTrainyard) == "boolean", "Need 'inTrainyard' as boolean")
    local oldInTrainyard = self.inTrainyard
    local oldTrainyardId = self.trainyardId
    self.inTrainyard = inTrainyard
    self.trainyardId = inTrainyard and trainyardId or nil
    markLoaded(self, "inTrainyard")
    markLoaded(self, "trainyardId")
    if oldInTrainyard ~= self.inTrainyard or oldTrainyardId ~= self.trainyardId then
        markDirty(self, "inTrainyard")
        markDirty(self, "trainyardId")
    end
end

function Train:pullTrainyard()
    local inTrainyard, trainyardId = false, nil
    if EEPIsTrainInTrainyard then inTrainyard, trainyardId = EEPIsTrainInTrainyard(self.name) end
    self:setTrainyard(inTrainyard == true, trainyardId)
    return self.inTrainyard, self.trainyardId
end

function Train:getTrainyardId()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    if not DataClass.isLoaded(self, "inTrainyard") then self:pullTrainyard() end
    return self.trainyardId
end

function Train:peekTrainyardId() return self.trainyardId end

function Train:getInTrainyard()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    if not DataClass.isLoaded(self, "inTrainyard") then self:pullTrainyard() end
    return self.inTrainyard
end

function Train:peekInTrainyard() return self.inTrainyard end

--- Updates the trains speed in km/h
---@param movesForward boolean indicates if the train moves forward or backward
function Train:setMovesForward(movesForward)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(movesForward) == "boolean", "Need 'movesForward' as boolean")
    local oldMovesForward = self.movesForward
    self.movesForward = movesForward
    markLoaded(self, "movesForward")
    if oldMovesForward ~= movesForward then
        markDirty(self, "movesForward")
    end
end

--- Gets the trains speed in km/h
---@return boolean train speed in km/h
function Train:getMovesForward()
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    if not DataClass.isLoaded(self, "movesForward") then
        local speed = self:getSpeed()
        if speed ~= nil then self:setMovesForward(speed >= 0) end
    end
    return self.movesForward
end

function Train:peekMovesForward() return self.movesForward end

--- Updates tracks of the current train
---@param onTracks table<string, number>
function Train:setOnTrack(onTracks)
    assert(type(self) == "table" and self.type == "Train", "Call this method with ':'")
    assert(type(onTracks) == "table", "Need 'onTracks' as table")
    local oldOnTracks = self.onTracks
    self.onTracks = onTracks
    markLoaded(self, "onTracks")
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
    markLoaded(self, "trackType")
    if oldTrackType ~= trackType then
        markDirty(self, "trackType")
    end
end

function Train:getTrackType() return self.trackType end

function Train:peekTrackType() return self.trackType end

function Train:openDoors()
    local carCount = EEPGetRollingstockItemsCount(self.name)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(self.name, i)
        RollingStockRegistry.getOrCreate(rollingStockName):openDoors()
    end
end

function Train:closeDoors()
    local carCount = EEPGetRollingstockItemsCount(self.name)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(self.name, i)
        RollingStockRegistry.getOrCreate(rollingStockName):closeDoors()
    end
end

function Train:resetDirty()
    self.dirtyFields = {}
end

function Train:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

local function trainFromRegistry(trainName)
    return require("ce.hub.data.trains.TrainRegistry").get(trainName)
end

local function printMissingTrain(trainName)
    print(string.format("[#Train] Command ignored, train is not registered: %s", tostring(trainName)))
end

function Train.setActiveByName(trainName)
    local trainToActivate = trainFromRegistry(trainName)
    if not trainToActivate then
        printMissingTrain(trainName)
        return false
    end
    if not DataClass.isCallable(EEPSetTrainActive) then return false end

    local ok = EEPSetTrainActive(trainName) ~= false
    if ok then
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local ScenarioRegistry = require("ce.hub.data.scenario.ScenarioRegistry")
        for _, train in pairs(TrainRegistry.getAll()) do train:setActive(train.name == trainName) end
        ScenarioRegistry.getOrCreate():setActiveTrain(trainName)
    end
    return ok
end

function Train.setSpeedByName(trainName, speed, useTargetSpeed)
    local train = trainFromRegistry(trainName)
    local value = tonumber(speed)
    if not train or not value then
        if not train then printMissingTrain(trainName) end
        return false
    end
    local isTargetSpeed = useTargetSpeed == true
    if isTargetSpeed
        and DataClass.isLoaded(train, "targetSpeed")
        and train:peekTargetSpeed() == value then
        return true
    end
    if not isTargetSpeed and DataClass.isLoaded(train, "speed") and train:peekSpeed() == value then return true end
    if not DataClass.isCallable(EEPSetTrainSpeed) then return false end

    local ok = EEPSetTrainSpeed(trainName, value, isTargetSpeed) ~= false
    if ok then
        if isTargetSpeed then
            train:setTargetSpeed(value)
        else
            train:setSpeed(value)
        end
    end
    return ok
end

function Train.setCouplingFrontByName(trainName, enabled)
    local train = trainFromRegistry(trainName)
    if not train then
        printMissingTrain(trainName)
        return false
    end
    local value = enabled == true
    local cachedValue = value and 1 or 0
    if DataClass.isLoaded(train, "couplingFront") and train:peekCouplingFront() == cachedValue then return true end
    if not DataClass.isCallable(EEPSetTrainCouplingFront) then return false end

    local ok = EEPSetTrainCouplingFront(trainName, value) ~= false
    if ok then train:setCouplingFront(cachedValue) end
    return ok
end

function Train.setCouplingRearByName(trainName, enabled)
    local train = trainFromRegistry(trainName)
    if not train then
        printMissingTrain(trainName)
        return false
    end
    local value = enabled == true
    local cachedValue = value and 1 or 0
    if DataClass.isLoaded(train, "couplingRear") and train:peekCouplingRear() == cachedValue then return true end
    if not DataClass.isCallable(EEPSetTrainCouplingRear) then return false end

    local ok = EEPSetTrainCouplingRear(trainName, value) ~= false
    if ok then train:setCouplingRear(cachedValue) end
    return ok
end

function Train.setLightByName(trainName, enabled, source)
    local train = trainFromRegistry(trainName)
    if not train then
        printMissingTrain(trainName)
        return false
    end
    return train:setLight(enabled, source)
end


return Train
