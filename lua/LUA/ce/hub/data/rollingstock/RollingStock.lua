if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStock ...") end

local RollingStockModels = require("ce.hub.data.rollingstock.RollingStockModels")
local RollingStockModelInfoRegistry = require("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
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

local function copyTableWithStringKeys(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[tostring(key)] = value end
    return copy
end

local function sortedNumberKeys(values)
    local keys = {}
    for key in pairs(values or {}) do
        local numberKey = tonumber(key)
        if numberKey then keys[#keys + 1] = numberKey end
    end
    table.sort(keys)
    return keys
end

local function currentEepLanguage()
    local language = type(EEPLng) == "string" and string.upper(EEPLng) or ""
    if language == "ENG" or language == "GER" or language == "POL" or language == "FRA" then return language end
    return "GER"
end

local function axisNameForNumber(modelInfo, axisNumber)
    if not modelInfo then return nil end

    if type(modelInfo.getAxisName) == "function" then
        return modelInfo:getAxisName(axisNumber, currentEepLanguage())
    end

    local axisNames = modelInfo.axisNames or {}
    return axisNames[tonumber(axisNumber)]
end

local function sortedAxisNumbers(modelInfo)
    local numbers = {}
    local byNumber = {}

    local function addKeys(values)
        for _, numberKey in ipairs(sortedNumberKeys(values)) do
            if not byNumber[numberKey] then
                byNumber[numberKey] = true
                numbers[#numbers + 1] = numberKey
            end
        end
    end

    addKeys(modelInfo and modelInfo.axisNames or {})
    for _, languageAxisNames in pairs(modelInfo and modelInfo.axisNamesByLanguage or {}) do
        addKeys(languageAxisNames)
    end

    table.sort(numbers)
    return numbers
end

local function collectAxisValues(rollingStockName, modelInfo)
    local axisValues = {}
    local axisNumbers = sortedAxisNumbers(modelInfo)
    local hasAxisMetadata = #axisNumbers > 0
    if not hasAxisMetadata then
        for axisNumber = 1, 10 do axisNumbers[#axisNumbers + 1] = axisNumber end
    end

    for _, axisNumber in ipairs(axisNumbers) do
        local ok, axisValue = false, nil
        if hasAxisMetadata and type(EEPRollingstockGetAxis) == "function" then
            local axisName = axisNameForNumber(modelInfo, axisNumber)
            if axisName then ok, axisValue = EEPRollingstockGetAxis(rollingStockName, axisName) end
        end
        if not ok and type(EEPRollingstockGetAxisByNumber) == "function" then
            ok, axisValue = EEPRollingstockGetAxisByNumber(rollingStockName, axisNumber)
        end
        if ok then axisValues[tostring(axisNumber)] = tonumber(axisValue) or 0 end
    end

    return axisValues
end

---@class RollingStock
---@field values table<string, string>
---@field id string
---@field rollingStockName string
---@field type string
---@field trainName string
---@field positionInTrain integer
---@field couplingFront integer
---@field couplingRear integer
---@field modelType integer
---@field modelTypeText string
---@field propelled boolean
---@field length number
---@field mileage number
---@field trackId integer
---@field trackDistance number
---@field trackDirection integer
---@field trackSystem integer
---@field x number
---@field y number
---@field z number
---@field model RollingStockModel
---@field modelInfo table|nil
---@field axisValues table<string, number>
---@field tag string
---@field orientationForward boolean
---@field smoke number
---@field hookStatus number
---@field hookGlueMode number
---@field active boolean
---@field textureTexts table<string, string>
---@field rotX number
---@field rotY number
---@field rotZ number
---@field trackType string|nil
---@field xmlModel string|nil
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
---@field new fun(self: RollingStock, o: RollingStock):RollingStock
---@field setValue fun(self: RollingStock, key: string, value: string):nil
---@field getValue fun(self: RollingStock, key: string):string
---@field save fun(self: RollingStock, clearCurrentInfo?: boolean):nil
---@field setLine fun(self: RollingStock, line: string):nil
---@field setDestination fun(self: RollingStock, destination: string):nil
---@field setStations fun(self: RollingStock, stations: string):nil
---@field setWagonNr fun(self: RollingStock, nr: string):nil
---@field getWagonNr fun(self: RollingStock):string
---@field setTrainName fun(self: RollingStock, trainName: string):nil
---@field getTrainName fun(self: RollingStock):string
---@field setPositionInTrain fun(self: RollingStock, positionInTrain: number):nil
---@field getPositionInTrain fun(self: RollingStock):number
---@field getLength fun(self: RollingStock):number
---@field setLength fun(self: RollingStock, length: number):nil
---@field getModelType fun(self: RollingStock):number
---@field setModelType fun(self: RollingStock, modelType: number):nil
---@field getModelTypeText fun(self: RollingStock):string
---@field getTag fun(self: RollingStock):string
---@field setTag fun(self: RollingStock, tag: string):nil
---@field getPropelled fun(self: RollingStock):boolean
---@field setPropelled fun(self: RollingStock, propelled: boolean):nil
---@field setOrientationForward fun(self: RollingStock, orientationForward: boolean):nil
---@field getOrientationForward fun(self: RollingStock):boolean
---@field setSmoke fun(self: RollingStock, smoke: number):nil
---@field getSmoke fun(self: RollingStock):number
---@field setHookStatus fun(self: RollingStock, hookStatus: number):nil
---@field getHookStatus fun(self: RollingStock):number
---@field setHookGlueMode fun(self: RollingStock, hookGlueMode: number):nil
---@field getHookGlueMode fun(self: RollingStock):number
---@field setActive fun(self: RollingStock, active: boolean):nil
---@field getActive fun(self: RollingStock):boolean
---@field setTextureTexts fun(self: RollingStock, textureTexts: table<string, string>):nil
---@field getTextureTexts fun(self: RollingStock):table<string, string>
---@field updateTextureTexts fun(self: RollingStock):nil
---@field setAxisValues fun(self: RollingStock, axisValues: table<string, number>):nil
---@field getAxisValues fun(self: RollingStock):table<string, number>
---@field updateAxisValues fun(self: RollingStock):nil
---@field setAxisByNumber fun(self: RollingStock, axisNumber: number|string, axisValue: number|string):boolean
---@field setAxisByNameFallback fun(self: RollingStock, axisNumber: number|string, axisValue: number|string):boolean
---@field getAxisNames fun(self: RollingStock):table<string, string>
---@field getTextureNames fun(self: RollingStock):table<string, string>
---@field setRotation fun(self: RollingStock, rotX: number, rotY: number, rotZ: number):nil
---@field getRotX fun(self: RollingStock):number
---@field getRotY fun(self: RollingStock):number
---@field getRotZ fun(self: RollingStock):number
---@field setCouplingFront fun(self: RollingStock, couplingFront: number):nil
---@field getCouplingFront fun(self: RollingStock):number
---@field setCouplingRear fun(self: RollingStock, couplingRear: number):nil
---@field getCouplingRear fun(self: RollingStock):number
---@field getTrackId fun(self: RollingStock):number
---@field setTrack fun(self: RollingStock, trackId: number, trackDistance: number,
---trackDirection: number, trackSystem: number):nil
---@field getTrackDistance fun(self: RollingStock):number
---@field getTrackDirection fun(self: RollingStock):number
---@field getTrackSystem fun(self: RollingStock):number
---@field setTrackType fun(self: RollingStock, trackType: string):nil
---@field getTrackType fun(self: RollingStock):string|nil
---@field setPosition fun(self: RollingStock, x: number, y: number, z: number):nil
---@field getX fun(self: RollingStock):number
---@field getY fun(self: RollingStock):number
---@field getZ fun(self: RollingStock):number
---@field setMileage fun(self: RollingStock, mileage: number):nil
---@field getMileage fun(self: RollingStock):number
---@field getXmlModel fun(self: RollingStock):string|nil
---@field setXmlModel fun(self: RollingStock, model: string|nil):nil
---@field resetDirty fun(self: RollingStock):nil
---@field hasDirtyFields fun(self: RollingStock):boolean
---@field openDoors fun(self: RollingStock):nil
---@field closeDoors fun(self: RollingStock):nil
---@field toJsonStatic fun(self: RollingStock):table
---@field toJsonDynamic fun(self: RollingStock):table
local RollingStock = {}

-- Field update policies (see RollingStockStaticDtoTypes.d.lua / RollingStockDynamicDtoTypes.d.lua):
--   always   -> real value always included in DTO
--   ondemand -> real value only when InterestSyncRegistry.isSelected; placeholder (0/false/"") otherwise
--   never    -> always placeholder, never sent to clients

local function markDirty(rollingStock, fieldName)
    rollingStock.dirtyFields[fieldName] = true
end

---Create a new RollingStock and init it
---@param o RollingStock
---@return RollingStock
function RollingStock:new(o)
    assert(o.rollingStockName, "Provide a rollingStockName")
    assert(type(o.rollingStockName) == "string", "Need 'o.id' as string")
    o.id = o.rollingStockName
    local xmlModel = o.xmlModel

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
    o.modelInfo = RollingStockModelInfoRegistry.infoForXmlModel(xmlModel)
    o.axisValues = collectAxisValues(o.id, o.modelInfo)
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
    o.xmlModel = xmlModel
    o.model = RollingStockModels.modelFor(o.id, o.xmlModel)
    o.dirtyFields = {}
    o.needsFullSend = true
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
        markDirty(self, "tag")
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
        markDirty(self, "nr")
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
        markDirty(self, "trainName")
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
        markDirty(self, "positionInTrain")
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

function RollingStock:setLength(length)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(length) == "number", "Need 'length' as number")
    length = tonumber(string.format("%.2f", length)) or 0
    local oldLength = self.length
    self.length = length
    if oldLength ~= length then markDirty(self, "length") end
end

--- Get the type of this rolling stock
---@return number type of this rolling stock
function RollingStock:getModelType()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.modelType
end

function RollingStock:setModelType(modelType)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(modelType) == "number", "Need 'modelType' as number")
    local oldModelType = self.modelType
    local oldModelTypeText = self.modelTypeText
    self.modelType = modelType
    self.modelTypeText = EEPRollingstockModelTypeText[modelType] or ""
    if oldModelType ~= modelType then markDirty(self, "modelType") end
    if oldModelTypeText ~= self.modelTypeText then markDirty(self, "modelTypeText") end
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

function RollingStock:setTag(tag)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(tag) == "string", "Need 'tag' as string")
    local oldTag = self.tag
    local oldNr = self:getWagonNr()
    self.tag = tag
    self.values = StorageUtility.parseTableFromString(tag)
    if oldTag ~= tag then markDirty(self, "tag") end
    if oldNr ~= self:getWagonNr() then markDirty(self, "nr") end
end

--- Get the propelled value of this rolling stock
---@return boolean propelled value of this rolling stock
function RollingStock:getPropelled()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.propelled
end

function RollingStock:setPropelled(propelled)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(propelled) == "boolean", "Need 'propelled' as boolean")
    local oldPropelled = self.propelled
    self.propelled = propelled
    if oldPropelled ~= propelled then markDirty(self, "propelled") end
end

function RollingStock:setOrientationForward(orientationForward)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(orientationForward) == "boolean", "Need 'orientationForward' as boolean")
    local oldOrientationForward = self.orientationForward
    self.orientationForward = orientationForward
    if oldOrientationForward ~= orientationForward then markDirty(self, "orientationForward") end
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
    if oldSmoke ~= smoke then markDirty(self, "smoke") end
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
    if oldHookStatus ~= hookStatus then markDirty(self, "hookStatus") end
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
    if oldHookGlueMode ~= hookGlueMode then markDirty(self, "hookGlueMode") end
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
    if oldActive ~= active then markDirty(self, "active") end
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
    if not TableUtils.sameDictEntries(oldTextureTexts, textureTexts) then markDirty(self, "surfaceTexts") end
end

function RollingStock:getTextureTexts()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.textureTexts or {}
end

function RollingStock:updateTextureTexts()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    self:setTextureTexts(collectTextureTexts(self.rollingStockName))
end

function RollingStock:setAxisValues(axisValues)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(axisValues) == "table", "Need 'axisValues' as table")
    local nextAxisValues = copyTableWithStringKeys(axisValues)
    local oldAxisValues = self.axisValues or {}
    self.axisValues = nextAxisValues
    if not TableUtils.sameDictEntries(oldAxisValues, nextAxisValues) then markDirty(self, "axisValues") end
end

function RollingStock:getAxisValues()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return copyTableWithStringKeys(self.axisValues or {})
end

function RollingStock:updateAxisValues()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    self:setAxisValues(collectAxisValues(self.rollingStockName, self.modelInfo))
end

function RollingStock:setAxisByNumber(axisNumber, axisValue)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    axisNumber = tonumber(axisNumber)
    axisValue = tonumber(axisValue)
    if not axisNumber or not axisValue then return false end

    if axisNameForNumber(self.modelInfo, axisNumber)
        and self:setAxisByNameFallback(axisNumber, axisValue) then
        return true
    end

    if type(EEPRollingstockSetAxisByNumber) == "function" then
        local ok = EEPRollingstockSetAxisByNumber(self.rollingStockName, axisNumber, axisValue)
        if ok then return true end
    end

    return self:setAxisByNameFallback(axisNumber, axisValue)
end

function RollingStock:setAxisByNameFallback(axisNumber, axisValue)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    axisNumber = tonumber(axisNumber)
    axisValue = tonumber(axisValue)
    if not axisNumber or not axisValue then return false end
    if type(EEPRollingstockSetAxis) ~= "function" then return false end

    local axisName = axisNameForNumber(self.modelInfo, axisNumber)
    if not axisName then
        print(string.format("[#RollingStock] No axis name for %s axis %s", self.rollingStockName, tostring(axisNumber)))
        return false
    end

    return EEPRollingstockSetAxis(self.rollingStockName, axisName, axisValue) == true
end

function RollingStock:getAxisNames()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return copyTableWithStringKeys(self.modelInfo and self.modelInfo.axisNames or {})
end

function RollingStock:getTextureNames()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return copyTableWithStringKeys(self.modelInfo and self.modelInfo.textureNames or {})
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
    if oldRotX ~= rotX or oldRotY ~= rotY or oldRotZ ~= rotZ then
        markDirty(self, "rotX")
        markDirty(self, "rotY")
        markDirty(self, "rotZ")
    end
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
        markDirty(self, "couplingFront")
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
        markDirty(self, "couplingRear")
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
    if oldId ~= trackId then markDirty(self, "trackId") end
    if oldDist ~= trackDistance then markDirty(self, "trackDistance") end
    if oldDir ~= trackDirection then markDirty(self, "trackDirection") end
    if oldSys ~= trackSystem then markDirty(self, "trackSystem") end
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
        markDirty(self, "trackType")
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
    if oldX ~= x then markDirty(self, "posX") end
    if oldY ~= y then markDirty(self, "posY") end
    if oldZ ~= z then markDirty(self, "posZ") end
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
        markDirty(self, "mileage")
    end
end

--- Get the mileage of this rolling stock
---@return number mileage of this rolling stock
function RollingStock:getMileage()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.mileage
end

function RollingStock:getXmlModel()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.xmlModel
end

function RollingStock:setXmlModel(model)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    local oldXmlModel = self.xmlModel
    local oldAxisNames = self:getAxisNames()
    local oldTextureNames = self:getTextureNames()
    self.xmlModel = model
    self.model = RollingStockModels.modelFor(self.rollingStockName, self.xmlModel)
    self.modelInfo = RollingStockModelInfoRegistry.infoForXmlModel(self.xmlModel)
    self:setAxisValues(collectAxisValues(self.rollingStockName, self.modelInfo))
    if oldXmlModel ~= model then markDirty(self, "xmlModel") end
    if not TableUtils.sameDictEntries(oldAxisNames, self:getAxisNames()) then markDirty(self, "axisNames") end
    if not TableUtils.sameDictEntries(oldTextureNames, self:getTextureNames()) then markDirty(self, "textureNames") end
end

function RollingStock:resetDirty()
    self.dirtyFields = {}
end

function RollingStock:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
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
        axisNames = self:getAxisNames(),
        axisValues = self:getAxisValues(),
        textureNames = self:getTextureNames(),
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
