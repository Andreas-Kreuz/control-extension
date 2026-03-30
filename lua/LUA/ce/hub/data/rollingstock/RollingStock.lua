if AkDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStock ...") end

local RollingStockModels = require("ce.hub.data.rollingstock.RollingStockModels")
local StorageUtility = require("ce.hub.util.StorageUtility")
local TableUtils = require("ce.hub.util.TableUtils")
local TagKeys = require("ce.hub.data.rollingstock.TagKeys")
-- local DataChangeBus = require("ce.hub.publish.DataChangeBus")

local EEPRollingstockModelTypeText = {
    [1] = "Tenderlok",
    [2] = "Schlepptenderlok",
    [3] = "Tender",
    [4] = "Elektrolok",
    [5] = "Diesellok",
    [6] = "Triebwagen",
    [7] = "U- oder S-Bahn",
    [8] = "Strassenbahn",
    [9] = "Gueterwaggon",
    [10] = "Personenwaggon",
    [11] = "Luftfahrzeug",
    [12] = "Maschine",
    [13] = "Wasserfahrzeug",
    [14] = "LKW",
    [15] = "PKW"
}

local function round2(value)
    return tonumber(string.format("%.2f", tonumber(value) or 0)) or 0
end

local function collectTextureTexts(rollingStockName)
    if not EEPRollingstockGetTextureText then return {} end
    local surfaceTexts = {}
    local surfaceNumber = 1
    while true do
        local ok, textureText = EEPRollingstockGetTextureText(rollingStockName, surfaceNumber)
        if not ok then break end
        surfaceTexts[tostring(surfaceNumber)] = textureText or ""
        surfaceNumber = surfaceNumber + 1
    end
    return surfaceTexts
end

local RollingStock = {}

local function markStaticUpdated(rollingStock)
    rollingStock.valuesUpdated = true
    rollingStock.staticValuesUpdated = true
end

local function markDynamicUpdated(rollingStock)
    rollingStock.dynamicValuesUpdated = true
end


---Create a new RollingStock and init it
---@param o RollingStock
---@return RollingStock
function RollingStock:new(o)
    assert(o.rollingStockName, "Provide a rollingStockName")
    assert(type(o.rollingStockName) == "string", "Need 'o.id' as string")
    o.id = o.rollingStockName

    self.__index = self
    setmetatable(o, self)

    local _, couplingFront = EEPRollingstockGetCouplingFront(o.id) -- EEP 11.0
    local _, couplingRear = EEPRollingstockGetCouplingRear(o.id)   -- EEP 11.0

    local _, length = EEPRollingstockGetLength(o.id)               -- EEP 15
    local _, propelled = EEPRollingstockGetMotor(o.id)             -- EEP 14.2
    local _, modelType = EEPRollingstockGetModelType(o.id)         -- EEP 14.2
    local _, tag = EEPRollingstockGetTagText(o.id)                 -- EEP 14.2
    local orientationOk, orientationForward = EEPRollingstockGetOrientation and EEPRollingstockGetOrientation(o.id) or
        false, nil
    local smokeOk, smoke = EEPRollingstockGetSmoke and EEPRollingstockGetSmoke(o.id) or false, nil
    local hookOk, hookStatus = EEPRollingstockGetHook and EEPRollingstockGetHook(o.id) or false, nil
    local hookGlueOk, hookGlueMode = EEPRollingstockGetHookGlue and EEPRollingstockGetHookGlue(o.id) or false,
        nil
    local activeRollingStock = EEPRollingstockGetActive and EEPRollingstockGetActive() or ""

    local _, trackId, trackDistance, trackDirection, trackSystem = EEPRollingstockGetTrack(o.id)
    -- EEP 14.2

    local hasPos, posX, posY, posZ = EEPRollingstockGetPosition(o.id) -- EEP 16.1
    local hasMileage, mileage = EEPRollingstockGetMileage(o.id)       -- EEP 16.1
    local rotationOk, rotX, rotY, rotZ = false, nil, nil, nil
    if EEPRollingstockGetRotation then
        rotationOk, rotX, rotY, rotZ = EEPRollingstockGetRotation(o.id)
    end

    o.type = "RollingStock"
    o.model = RollingStockModels.modelFor(o.id)
    o.trainName = ""
    o.positionInTrain = -1
    o.couplingFront = couplingFront or 1
    o.couplingRear = couplingRear or 1
    o.length = tonumber(string.format("%.2f", length or -1)) or -1
    o.propelled = propelled ~= false
    o.modelType = modelType or -1
    o.modelTypeText = EEPRollingstockModelTypeText[modelType] or ""
    o.tag = tag or ""
    o.values = StorageUtility.parseTableFromString(tag)
    o.orientationForward = orientationOk and orientationForward == true or false
    o.smoke = smokeOk and smoke or 0
    o.hookStatus = hookOk and hookStatus or 0
    o.hookGlueMode = hookGlueOk and hookGlueMode or 0
    o.active = activeRollingStock == o.id
    o.textureTexts = collectTextureTexts(o.id)
    o.trackId = trackId or -1
    o.trackDistance = tonumber(string.format("%.2f", trackDistance or -1)) or -1
    o.trackDirection = trackDirection or -1
    o.trackSystem = trackSystem or -1
    o.x = hasPos and tonumber(posX) or -1
    o.y = hasPos and tonumber(posY) or -1
    o.z = hasPos and tonumber(posZ) or -1
    o.mileage = hasMileage and tonumber(mileage) or -1
    o.rotX = rotationOk and round2(rotX) or 0
    o.rotY = rotationOk and round2(rotY) or 0
    o.rotZ = rotationOk and round2(rotZ) or 0
    o.valuesUpdated = true
    o.staticValuesUpdated = true
    o.dynamicValuesUpdated = true
    o.textureTextsUpdated = true
    o.rotationUpdated = true
    return o
end

---Adds or replaces a value in the rolling stock
---@param key string
---@param value string
function RollingStock:setValue(key, value)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(key) == "string", "Need 'key' as string")
    assert(type(value) == "string", "Need 'value' as string")
    self.values[key] = value
    self:save();
end

---Get the current value for key
---@param key string
---@return string value
function RollingStock:getValue(key)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(key) == "string", "Need 'key' as string")
    return self.values[key]
end

function RollingStock:save(clearCurrentInfo)
    local t = clearCurrentInfo and {} or self.values
    local oldTag = self.tag
    local newTag = StorageUtility.encodeTable(t)
    self.tag = newTag
    local hresult = EEPRollingstockSetTagText(self.rollingStockName, newTag)
    assert(hresult)
    if oldTag ~= self.tag then
        markStaticUpdated(self)
        -- DataChangeBus.fireDataChanged("rolling-stocks", "id", {id = self.id, tag = self.tag})
    end
end

function RollingStock:setLine(line)
    self:setValue(TagKeys.Train.line, line)
    self.model:setLine(self.rollingStockName, line)
    -- No event here - is used by train
end

function RollingStock:setDestination(destination)
    self:setValue(TagKeys.Train.destination, destination)
    self.model:setDestination(self.rollingStockName, destination)
    -- No event here - is used by train
end

function RollingStock:setStations(stations) self.model:setStations(self.rollingStockName, stations) end

function RollingStock:setWagonNr(nr)
    local oldNr = self:getValue(TagKeys.RollingStock.wagonNumber)
    self:setValue(TagKeys.RollingStock.wagonNumber, nr)
    self.model:setWagonNr(self.rollingStockName, nr)
    if oldNr ~= nr then
        markStaticUpdated(self)
        -- DataChangeBus.fireDataChanged("rolling-stocks", "id", {id = self.id, nr = nr})
    end
end

function RollingStock:getWagonNr() return self:getValue(TagKeys.RollingStock.wagonNumber) end

--- Updates the trains trainName
---@param trainName string train trainName
function RollingStock:setTrainName(trainName)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(trainName) == "string", "Need 'trainName' as string")
    local oldTrainName = self.trainName
    self.trainName = trainName
    if oldTrainName ~= trainName then
        markStaticUpdated(self)
        -- DataChangeBus.fireDataChanged("rolling-stocks", "id", {id = self.id, trainName = trainName})
    end
end

--- Get the trains trainName
---@return string train trainName
function RollingStock:getTrainName()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.trainName
end

--- Updates the rolling stock position in the train
---@param positionInTrain number rolling stock position in the train
function RollingStock:setPositionInTrain(positionInTrain)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(positionInTrain) == "number", "Need 'positionInTrain' as number")
    local oldPositionInTrain = self.positionInTrain
    self.positionInTrain = positionInTrain
    if oldPositionInTrain ~= positionInTrain then
        markStaticUpdated(self)
        -- DataChangeBus.fireDataChanged("rolling-stocks", "id", {id = self.id, positionInTrain = positionInTrain})
    end
end

--- Get the rolling stock position in the train
---@return number rolling stock position in the train
function RollingStock:getPositionInTrain()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.positionInTrain
end

--- Get the length of this rolling stock
---@return number length of this rolling stock
function RollingStock:getLength()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.length
end

--- Get the type of this rolling stock
---@return number type of this rolling stock
function RollingStock:getModelType()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.modelType
end

--- Get the type of this rolling stock
---@return string type of this rolling stock
function RollingStock:getModelTypeText()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.modelTypeText
end

--- Get the type of this rolling stock
---@return string type of this rolling stock
function RollingStock:getTag()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.tag
end

--- Get the propelled value of this rolling stock
---@return boolean propelled value of this rolling stock
function RollingStock:getPropelled()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.propelled
end

function RollingStock:setOrientationForward(orientationForward)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(orientationForward) == "boolean", "Need 'orientationForward' as boolean")
    local oldOrientationForward = self.orientationForward
    self.orientationForward = orientationForward
    if oldOrientationForward ~= orientationForward then markDynamicUpdated(self) end
end

function RollingStock:getOrientationForward()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.orientationForward
end

function RollingStock:setSmoke(smoke)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(smoke) == "number", "Need 'smoke' as number")
    local oldSmoke = self.smoke
    self.smoke = smoke
    if oldSmoke ~= smoke then markDynamicUpdated(self) end
end

function RollingStock:getSmoke()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.smoke
end

function RollingStock:setHookStatus(hookStatus)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(hookStatus) == "number", "Need 'hookStatus' as number")
    local oldHookStatus = self.hookStatus
    self.hookStatus = hookStatus
    if oldHookStatus ~= hookStatus then markStaticUpdated(self) end
end

function RollingStock:getHookStatus()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.hookStatus
end

function RollingStock:setHookGlueMode(hookGlueMode)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(hookGlueMode) == "number", "Need 'hookGlueMode' as number")
    local oldHookGlueMode = self.hookGlueMode
    self.hookGlueMode = hookGlueMode
    if oldHookGlueMode ~= hookGlueMode then markStaticUpdated(self) end
end

function RollingStock:getHookGlueMode()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.hookGlueMode
end

function RollingStock:setActive(active)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(active) == "boolean", "Need 'active' as boolean")
    local oldActive = self.active
    self.active = active
    if oldActive ~= active then markDynamicUpdated(self) end
end

function RollingStock:getActive()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.active
end

function RollingStock:setTextureTexts(textureTexts)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(textureTexts) == "table", "Need 'textureTexts' as table")
    local oldTextureTexts = self.textureTexts or {}
    self.textureTexts = textureTexts
    if not TableUtils.sameDictEntries(oldTextureTexts, textureTexts) then self.textureTextsUpdated = true end
end

function RollingStock:getTextureTexts()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.textureTexts or {}
end

function RollingStock:updateTextureTexts()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    self:setTextureTexts(collectTextureTexts(self.rollingStockName))
end

function RollingStock:setRotation(rotX, rotY, rotZ)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(rotX) == "number", "Need 'rotX' as number")
    assert(type(rotY) == "number", "Need 'rotY' as number")
    assert(type(rotZ) == "number", "Need 'rotZ' as number")
    rotX = round2(rotX)
    rotY = round2(rotY)
    rotZ = round2(rotZ)
    local oldRotX, oldRotY, oldRotZ = self.rotX, self.rotY, self.rotZ
    self.rotX = rotX
    self.rotY = rotY
    self.rotZ = rotZ
    if oldRotX ~= rotX or oldRotY ~= rotY or oldRotZ ~= rotZ then self.rotationUpdated = true end
end

function RollingStock:getRotX()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.rotX
end

function RollingStock:getRotY()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.rotY
end

function RollingStock:getRotZ()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.rotZ
end

--- Updates the front coupling of the rolling stock
---@param couplingFront number the front coupling of the rolling stock
function RollingStock:setCouplingFront(couplingFront)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(couplingFront) == "number", "Need 'positionInTrain' as number")
    local oldCoupling = self.couplingFront
    self.couplingFront = couplingFront
    if oldCoupling ~= couplingFront then
        markStaticUpdated(self)
        -- DataChangeBus.fireDataChanged("rolling-stocks", "id", {id = self.id, couplingFront = couplingFront})
    end
end

--- Get the front coupling of the rolling stock
---@return number the front coupling of the rolling stock
function RollingStock:getCouplingFront()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.couplingFront
end

--- Updates the rear coupling of the rolling stock
---@param couplingRear number the rear coupling of the rolling stock
function RollingStock:setCouplingRear(couplingRear)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(couplingRear) == "number", "Need 'positionInTrain' as number")
    local oldCoupling = self.couplingRear
    self.couplingRear = couplingRear
    if oldCoupling ~= couplingRear then
        markStaticUpdated(self)
        -- DataChangeBus.fireDataChanged("rolling-stocks", "id", {id = self.id, couplingRear = couplingRear})
    end
end

--- Get the rear coupling of the rolling stock
---@return number the rear coupling of the rolling stock
function RollingStock:getCouplingRear()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.couplingRear
end

--- Get the track id of the rolling stock
---@return number the track id of the rolling stock
function RollingStock:getTrackId()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.trackId
end

--- Updates the rolling stock track information
---@param trackId number track id
---@param trackDistance number track distance
---@param trackDirection number track direction
---@param trackSystem number track system
function RollingStock:setTrack(trackId, trackDistance, trackDirection, trackSystem)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(trackId) == "number", "Need 'trackId' as number")
    assert(type(trackDistance) == "number", "Need 'trackDistance' as number")
    assert(type(trackDirection) == "number", "Need 'trackDirection' as number")
    assert(type(trackSystem) == "number", "Need 'trackSystem' as number")
    local oldId, oldDist, oldDir, oldSys = self.trackId, self.trackDistance, self.trackDirection, self.trackSystem
    self.trackId = trackId
    self.trackDistance = trackDistance
    self.trackDirection = trackDirection
    self.trackSystem = trackSystem
    if oldId ~= trackId or oldDist ~= trackDistance or oldDir ~= trackDirection or oldSys ~= trackSystem then
        markDynamicUpdated(self)
        -- DataChangeBus.fireDataChanged("rollingStockInfo", "id", {
        --     id = self.id,
        --     trackId = trackId,
        --     trackDistance = trackDistance,
        --     trackDirection = trackDirection,
        --     trackSystem = trackSystem
        -- })
    end
end

--- Get the track distance of the rolling stock
---@return number the track distance of the rolling stock
function RollingStock:getTrackDistance()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.trackDistance
end

--- Get the track direction of the rolling stock
---@return number the track direction of the rolling stock
function RollingStock:getTrackDirection()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.trackDirection
end

--- Get the track system of the rolling stock
---@return number the track system of the rolling stock
function RollingStock:getTrackSystem()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.trackSystem
end

--- Updates the trains trackType
---@param trackType string train trackType
function RollingStock:setTrackType(trackType)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(trackType) == "string", "Need 'trackType' as string")
    local oldValue = self.trackType
    self.trackType = trackType
    if oldValue ~= trackType then
        markStaticUpdated(self)
        -- DataChangeBus.fireDataChanged("rolling-stocks", "id", {id = self.id, trackType = trackType})
    end
end

--- Get the trains trackType
---@return string trackType trackType
function RollingStock:getTrackType()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.trackType
end

--- Updates the rolling stock position on the map
---@param x number x coordinate
---@param y number y coordinate
---@param z number z coordinate
function RollingStock:setPosition(x, y, z)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(x) == "number", "Need 'x' as number")
    assert(type(y) == "number", "Need 'y' as number")
    assert(type(z) == "number", "Need 'z' as number")
    local oldX, oldY, oldZ = self.x, self.y, self.z
    self.x = x
    self.y = y
    self.z = z
    if oldX ~= x or oldY ~= y or oldZ ~= z then
        markDynamicUpdated(self)
        -- DataChangeBus.fireDataChanged("rollingStockInfo", "id", {id = self.id, posX = x, posY = y, posZ = z})
    end
end

--- Get the x coordinate of this rolling stock
---@return number x coordinate of this rolling stock
function RollingStock:getX()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.x
end

--- Get the y coordinate of this rolling stock
---@return number y coordinate of this rolling stock
function RollingStock:getY()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.y
end

--- Get the z coordinate of this rolling stock
---@return number z coordinate of this rolling stock
function RollingStock:getZ()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.z
end

--- Get the mileage of this rolling stock
---@param mileage number mileage of this rolling stock
function RollingStock:setMileage(mileage)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(mileage) == "number", "Need 'mileage' as number")
    local oldMileage = self.mileage
    self.mileage = mileage
    if oldMileage ~= mileage then
        markDynamicUpdated(self)
        -- DataChangeBus.fireDataChanged("rollingStockInfo", "id", {id = self.id, mileage = mileage})
    end
end

--- Get the mileage of this rolling stock
---@return number mileage of this rolling stock
function RollingStock:getMileage()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.mileage
end

function RollingStock:openDoors() self.model:openDoors(self.rollingStockName) end

function RollingStock:closeDoors() self.model:closeDoors(self.rollingStockName) end

function RollingStock:toJsonStatic()
    return {
        id = self.rollingStockName,
        name = self.rollingStockName,
        trainName = self:getTrainName(),
        positionInTrain = self:getPositionInTrain(),
        couplingFront = self:getCouplingFront(),
        couplingRear = self:getCouplingRear(),
        length = self:getLength(),
        propelled = self:getPropelled(),
        modelType = self:getModelType(),
        modelTypeText = self:getModelTypeText(),
        tag = self:getTag(),
        orientationForward = self:getOrientationForward(),
        smoke = self:getSmoke(),
        hookStatus = self:getHookStatus(),
        hookGlueMode = self:getHookGlueMode(),
        active = self:getActive(),
        nr = self:getWagonNr(),
        trackId = self:getTrackId(),
        trackDistance = self:getTrackDistance(),
        trackDirection = self:getTrackDirection(),
        trackSystem = self:getTrackSystem(),
        trackType = self:getTrackType(),
        posX = self:getX(),
        posY = self:getY(),
        posZ = self:getZ(),
        mileage = self:getMileage()
    }
end

function RollingStock:toJsonDynamic()
    return {
        id = self.id,
        name = self.rollingStockName,
        trackId = self:getTrackId(),
        trackDistance = self:getTrackDistance(),
        trackDirection = self:getTrackDirection(),
        trackSystem = self:getTrackSystem(),
        posX = self:getX(),
        posY = self:getY(),
        posZ = self:getZ(),
        mileage = self:getMileage()
    }
end

return RollingStock
