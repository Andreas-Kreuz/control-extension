if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStock ...") end

local RollingStockModels = require("ce.hub.data.rollingstock.RollingStockModels")
local RollingStockModelInfoRegistry = require("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
local DataClass = require("ce.hub.data.DataClass")
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
    if value == nil then return nil end
    return tonumber(string.format("%.2f", tonumber(value) or 0)) or 0
end

local function snapshotNumber(snapshot, fieldName)
    if snapshot[fieldName] == nil then return nil end
    return tonumber(snapshot[fieldName])
end

local function markLoadedFromSnapshot(instance, snapshot, snapshotFieldName, fieldName)
    if snapshot[snapshotFieldName] ~= nil then DataClass.markLoaded(instance, fieldName or snapshotFieldName) end
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

local function collectTextureTexts(rollingStockName, surfaceNumbers, existingTextureTexts)
    local surfaceTexts = copyTableWithStringKeys(existingTextureTexts or {})
    if not EEPRollingstockGetTextureText then return surfaceTexts end

    if #surfaceNumbers > 0 then
        for _, surfaceNumber in ipairs(surfaceNumbers) do
            local ok, textureText = EEPRollingstockGetTextureText(rollingStockName, surfaceNumber)
            if ok then surfaceTexts[tostring(surfaceNumber)] = textureText or "" end
        end
        return surfaceTexts
    end

    local surfaceNumber = 1
    while true do
        local ok, textureText = EEPRollingstockGetTextureText(rollingStockName, surfaceNumber)
        if not ok then break end
        surfaceTexts[tostring(surfaceNumber)] = textureText or ""
        surfaceNumber = surfaceNumber + 1
    end
    return surfaceTexts
end

local function textureSurfaceNumbersForPull(rollingStock)
    local surfaceNumbers = {}
    for _, surfaceNumber in ipairs(sortedNumberKeys(rollingStock.textureTexts or {})) do
        surfaceNumbers[#surfaceNumbers + 1] = surfaceNumber
    end
    local modelInfo = RollingStockModelInfoRegistry.get(rollingStock.xmlModel)
    local modelTextureNames = modelInfo and modelInfo.textureNames or {}
    for _, surfaceNumber in ipairs(sortedNumberKeys(modelTextureNames)) do
        if rollingStock.textureTexts == nil or rollingStock.textureTexts[tostring(surfaceNumber)] == nil then
            surfaceNumbers[#surfaceNumbers + 1] = surfaceNumber
        end
    end
    table.sort(surfaceNumbers)
    return surfaceNumbers
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

local function axisNamesKnownForModelInfo(modelInfo)
    if not modelInfo then return false end
    if type(modelInfo.getAxisNamesKnown) == "function" then return modelInfo:getAxisNamesKnown() end
    return modelInfo.axisNamesKnown == true
end

local function modelInfoForXmlModel(xmlModel, deferModelInfo)
    if deferModelInfo then
        return RollingStockModelInfoRegistry.peek(xmlModel)
    end
    return RollingStockModelInfoRegistry.get(xmlModel)
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
    if not hasAxisMetadata and axisNamesKnownForModelInfo(modelInfo) then return axisValues end
    if not hasAxisMetadata then
        for axisNumber = 1, 10 do axisNumbers[#axisNumbers + 1] = axisNumber end
    end

    for _, axisNumber in ipairs(axisNumbers) do
        local ok, axisValue = false, nil
        if hasAxisMetadata and DataClass.isCallable(EEPRollingstockGetAxis) then
            local axisName = axisNameForNumber(modelInfo, axisNumber)
            if axisName then ok, axisValue = EEPRollingstockGetAxis(rollingStockName, axisName) end
        end
        if not ok and DataClass.isCallable(EEPRollingstockGetAxisByNumber) then
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
---@field axisValues table<string, number>
---@field tag string
---@field orientationForward boolean
---@field smoke number|boolean
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
---@field new fun(self: RollingStock, o: table):RollingStock
---@field setValue fun(self: RollingStock, key: string, value: string):nil
---@field getValue fun(self: RollingStock, key: string):string
---@field save fun(self: RollingStock, clearCurrentInfo?: boolean):nil
---@field setLine fun(self: RollingStock, line: string):nil
---@field setDestination fun(self: RollingStock, destination: string):nil
---@field setStations fun(self: RollingStock, stations: string):nil
---@field setLicencePlate fun(self: RollingStock, licencePlate: string):nil
---@field getLicencePlate fun(self: RollingStock):string
---@field setWagonNumber fun(self: RollingStock, wagonNumber: string):nil
---@field getWagonNumber fun(self: RollingStock):string
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
---@field setSmoke fun(self: RollingStock, smoke: number|boolean):nil
---@field getSmoke fun(self: RollingStock):number|boolean
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
---@field getAxisNamesKnown fun(self: RollingStock):boolean
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
local RollingStock = {}

function RollingStock.exists(rollingStockName)
    if not DataClass.isCallable(EEPRollingstockGetTrainName) then return false end
    return EEPRollingstockGetTrainName(rollingStockName) == true
end

-- Field update policies (see RollingStockStaticDtoTypes.d.lua / RollingStockDynamicDtoTypes.d.lua):
--   always   -> real value always included in DTO
--   ondemand -> real value only when InterestSyncRegistry.isSelected; placeholder (0/false/"") otherwise
--   never    -> always placeholder, never sent to clients

local function markDirty(rollingStock, fieldName)
    rollingStock.dirtyFields[fieldName] = true
end

local function markLoaded(rollingStock, fieldName)
    DataClass.markLoaded(rollingStock, fieldName)
end

local function setCachedAxisValue(rollingStock, axisKey, axisValue)
    local value = tonumber(axisValue)
    if not axisKey or not value then return false end
    local key = tostring(axisKey)
    rollingStock.axisValues = rollingStock.axisValues or {}
    local oldValue = rollingStock.axisValues[key]
    rollingStock.axisValues[key] = value
    markLoaded(rollingStock, "axisValues")
    if oldValue ~= value then markDirty(rollingStock, "axisValues") end
    return true
end

---Create a new RollingStock and init it
---@param o table
---@return RollingStock
function RollingStock:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(o.rollingStockName, "Provide a rollingStockName")
    assert(type(o.rollingStockName) == "string", "Need 'o.id' as string")
    return RollingStock.fromSnapshot(o)
end

function RollingStock.fromSnapshot(snapshot)
    assert(type(snapshot) == "table", "Need snapshot as table")
    assert(type(snapshot.rollingStockName) == "string", "Need snapshot.rollingStockName as string")

    local xmlModel = snapshot.xmlModel
    modelInfoForXmlModel(xmlModel, snapshot.deferModelInfo == true)
    local tag = snapshot.tag or ""
    local o = {
        id = snapshot.rollingStockName,
        rollingStockName = snapshot.rollingStockName,
        type = "RollingStock",
        trainName = snapshot.trainName or "",
        positionInTrain = snapshotNumber(snapshot, "positionInTrain") or -1,
        couplingFront = snapshotNumber(snapshot, "couplingFront") or 1,
        couplingRear = snapshotNumber(snapshot, "couplingRear") or 1,
        length = snapshotNumber(snapshot, "length") or -1,
        propelled = snapshot.propelled ~= false,
        modelType = snapshotNumber(snapshot, "modelType") or -1,
        modelTypeText = snapshot.modelTypeText or EEPRollingstockModelTypeText[snapshot.modelType] or "",
        tag = tag,
        values = StorageUtility.parseTableFromString(tag),
        orientationForward = snapshot.orientationForward == true,
        smoke = snapshot.smoke or 0,
        hookStatus = snapshotNumber(snapshot, "hookStatus") or 0,
        hookGlueMode = snapshotNumber(snapshot, "hookGlueMode") or 0,
        active = snapshot.active == true,
        textureTexts = copyTableWithStringKeys(snapshot.textureTexts or {}),
        axisValues = snapshot.axisValues or {},
        trackId = snapshotNumber(snapshot, "trackId") or -1,
        trackDistance = round2(snapshot.trackDistance) or -1,
        trackDirection = snapshotNumber(snapshot, "trackDirection") or -1,
        trackSystem = snapshotNumber(snapshot, "trackSystem") or -1,
        x = snapshotNumber(snapshot, "x") or -1,
        y = snapshotNumber(snapshot, "y") or -1,
        z = snapshotNumber(snapshot, "z") or -1,
        mileage = snapshotNumber(snapshot, "mileage") or -1,
        rotX = round2(snapshot.rotX) or 0,
        rotY = round2(snapshot.rotY) or 0,
        rotZ = round2(snapshot.rotZ) or 0,
        xmlModel = xmlModel,
        model = RollingStockModels.modelFor(snapshot.rollingStockName, xmlModel),
        dirtyFields = {},
        needsFullSend = true
    }

    RollingStock.__index = RollingStock
    setmetatable(o, RollingStock)
    DataClass.init(o)
    markLoadedFromSnapshot(o, snapshot, "trainName")
    markLoadedFromSnapshot(o, snapshot, "positionInTrain")
    markLoadedFromSnapshot(o, snapshot, "couplingFront")
    markLoadedFromSnapshot(o, snapshot, "couplingRear")
    markLoadedFromSnapshot(o, snapshot, "length")
    markLoadedFromSnapshot(o, snapshot, "propelled")
    markLoadedFromSnapshot(o, snapshot, "modelType")
    markLoadedFromSnapshot(o, snapshot, "modelType", "modelTypeText")
    markLoadedFromSnapshot(o, snapshot, "modelTypeText")
    markLoadedFromSnapshot(o, snapshot, "tag")
    markLoadedFromSnapshot(o, snapshot, "orientationForward")
    markLoadedFromSnapshot(o, snapshot, "smoke")
    markLoadedFromSnapshot(o, snapshot, "hookStatus")
    markLoadedFromSnapshot(o, snapshot, "hookGlueMode")
    markLoadedFromSnapshot(o, snapshot, "active")
    markLoadedFromSnapshot(o, snapshot, "textureTexts")
    markLoadedFromSnapshot(o, snapshot, "axisValues")
    markLoadedFromSnapshot(o, snapshot, "trackId")
    markLoadedFromSnapshot(o, snapshot, "trackDistance")
    markLoadedFromSnapshot(o, snapshot, "trackDirection")
    markLoadedFromSnapshot(o, snapshot, "trackSystem")
    markLoadedFromSnapshot(o, snapshot, "x")
    markLoadedFromSnapshot(o, snapshot, "y")
    markLoadedFromSnapshot(o, snapshot, "z")
    markLoadedFromSnapshot(o, snapshot, "mileage")
    markLoadedFromSnapshot(o, snapshot, "rotX")
    markLoadedFromSnapshot(o, snapshot, "rotY")
    markLoadedFromSnapshot(o, snapshot, "rotZ")
    markLoadedFromSnapshot(o, snapshot, "xmlModel")
    return o
end

function RollingStock:pullInitial()
    self:pullCouplingFront()
    self:pullCouplingRear()
    self:pullLength()
    self:pullPropelled()
    self:pullModelType()
    self:pullTag()
    self:pullOrientationForward()
    self:pullSmoke()
    self:pullHookStatus()
    self:pullHookGlueMode()
    self:pullActive()
    self:pullTextureTexts()
    self:pullAxisValues()
    self:pullTrack()
    self:pullPosition()
    self:pullMileage()
    self:pullRotation()
    self:resetDirty()
    return self
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
    if not DataClass.isLoaded(self, "tag") then self:pullTag() end
    return self.values[key]
end

function RollingStock:save(clearCurrentInfo)
    local t = clearCurrentInfo and {} or self.values
    local newTag = StorageUtility.encodeTable(t)
    if self.tag == newTag then return true end
    local hresult = EEPRollingstockSetTagText(self.rollingStockName, newTag)
    assert(hresult)
    self:setTag(newTag)
    return true
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

function RollingStock:setLicencePlate(licencePlate)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(licencePlate) == "string", "Need 'licencePlate' as string")
    local oldLicencePlate = self:getLicencePlate()
    self:setValue(TagKeys.RollingStock.licencePlate, licencePlate)
    self.model:setLicencePlate(self.rollingStockName, licencePlate)
    if oldLicencePlate ~= licencePlate then
        markDirty(self, "licencePlate")
    end
end

function RollingStock:getLicencePlate() return self:getValue(TagKeys.RollingStock.licencePlate) end

function RollingStock:setWagonNumber(wagonNumber)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(wagonNumber) == "string", "Need 'wagonNumber' as string")
    local oldWagonNumber = self:getWagonNumber()
    self:setValue(TagKeys.RollingStock.wagonNumber, wagonNumber)
    if rawget(self.model, "setWagonNumber") then
        self.model:setWagonNumber(self.rollingStockName, wagonNumber)
    elseif rawget(self.model, "setWagonNr") then
        self.model:setWagonNr(self.rollingStockName, wagonNumber)
    else
        self.model:setWagonNumber(self.rollingStockName, wagonNumber)
    end
    if oldWagonNumber ~= wagonNumber then
        markDirty(self, "vehicleNumber")
        markDirty(self, "nr")
    end
end

function RollingStock:getWagonNumber() return self:getValue(TagKeys.RollingStock.wagonNumber) end

function RollingStock:setWagonNr(nr) self:setWagonNumber(nr) end

function RollingStock:getWagonNr() return self:getWagonNumber() end

--- Updates the trains trainName
---@param trainName string train trainName
function RollingStock:setTrainName(trainName)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(trainName) == "string", "Need 'trainName' as string")
    local oldTrainName = self.trainName
    self.trainName = trainName
    markLoaded(self, "trainName")
    if oldTrainName ~= trainName then
        markDirty(self, "trainName")
    end
end

--- Get the trains trainName
---@return string train trainName
function RollingStock:getTrainName()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "trainName") then self:pullTrainName() end
    return self.trainName
end

function RollingStock:pullTrainName()
    if not DataClass.isCallable(EEPRollingstockGetTrainName) then return nil end
    local ok, trainName = EEPRollingstockGetTrainName(self.rollingStockName)
    if ok then self:setTrainName(trainName or "") end
    return self.trainName
end

--- Updates the rolling stock position in the train
---@param positionInTrain number rolling stock position in the train
function RollingStock:setPositionInTrain(positionInTrain)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(positionInTrain) == "number", "Need 'positionInTrain' as number")
    local oldPositionInTrain = self.positionInTrain
    self.positionInTrain = positionInTrain
    markLoaded(self, "positionInTrain")
    if oldPositionInTrain ~= positionInTrain then
        markDirty(self, "positionInTrain")
    end
end

--- Get the rolling stock position in the train
---@return number rolling stock position in the train
function RollingStock:getPositionInTrain()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "positionInTrain") then self:pullPositionInTrain() end
    return self.positionInTrain
end

function RollingStock:pullPositionInTrain()
    local trainName = self:getTrainName()
    if not trainName or trainName == "" then return nil end
    if not DataClass.isCallable(EEPGetRollingstockItemsCount)
        or not DataClass.isCallable(EEPGetRollingstockItemName) then
        return nil
    end
    local rollingStockCount = EEPGetRollingstockItemsCount(trainName) or 0
    for positionInTrain = 0, rollingStockCount - 1 do
        if EEPGetRollingstockItemName(trainName, positionInTrain) == self.rollingStockName then
            self:setPositionInTrain(positionInTrain)
            return self.positionInTrain
        end
    end
    return nil
end

--- Get the length of this rolling stock
---@return number length of this rolling stock
function RollingStock:getLength()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "length") then self:pullLength() end
    return self.length
end

function RollingStock:setLength(length)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(length) == "number", "Need 'length' as number")
    length = tonumber(string.format("%.2f", length)) or 0
    local oldLength = self.length
    self.length = length
    markLoaded(self, "length")
    if oldLength ~= length then markDirty(self, "length") end
end

function RollingStock:pullLength()
    if not DataClass.isCallable(EEPRollingstockGetLength) then return nil end
    local _, length = EEPRollingstockGetLength(self.rollingStockName)
    if length then self:setLength(length) end
    return self.length
end

--- Get the type of this rolling stock
---@return number type of this rolling stock
function RollingStock:getModelType()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "modelType") then self:pullModelType() end
    return self.modelType
end

function RollingStock:setModelType(modelType)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(modelType) == "number", "Need 'modelType' as number")
    local oldModelType = self.modelType
    local oldModelTypeText = self.modelTypeText
    self.modelType = modelType
    self.modelTypeText = EEPRollingstockModelTypeText[modelType] or ""
    markLoaded(self, "modelType")
    markLoaded(self, "modelTypeText")
    if oldModelType ~= modelType then markDirty(self, "modelType") end
    if oldModelTypeText ~= self.modelTypeText then markDirty(self, "modelTypeText") end
end

function RollingStock:pullModelType()
    if not DataClass.isCallable(EEPRollingstockGetModelType) then return nil, nil end
    local _, modelType = EEPRollingstockGetModelType(self.rollingStockName)
    if modelType then self:setModelType(modelType) end
    return self.modelType, self.modelTypeText
end

--- Get the type of this rolling stock
---@return string type of this rolling stock
function RollingStock:getModelTypeText()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "modelTypeText") then self:pullModelType() end
    return self.modelTypeText
end

--- Get the type of this rolling stock
---@return string type of this rolling stock
function RollingStock:getTag()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "tag") then self:pullTag() end
    return self.tag
end

function RollingStock:peekTag() return self.tag end

function RollingStock:setTag(tag)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(tag) == "string", "Need 'tag' as string")
    local oldTag = self.tag
    local oldLicencePlate = self:peekLicencePlate()
    local oldWagonNumber = self:peekWagonNumber()
    self.tag = tag
    self.values = StorageUtility.parseTableFromString(tag)
    markLoaded(self, "tag")
    if oldTag ~= tag then markDirty(self, "tag") end
    if oldLicencePlate ~= self:peekLicencePlate() then markDirty(self, "licencePlate") end
    if oldWagonNumber ~= self:peekWagonNumber() then
        markDirty(self, "vehicleNumber")
        markDirty(self, "nr")
    end
end

function RollingStock:pullTag()
    if not DataClass.isCallable(EEPRollingstockGetTagText) then return nil end
    local _, tag = EEPRollingstockGetTagText(self.rollingStockName)
    self:setTag(tag or "")
    return self.tag
end

--- Get the propelled value of this rolling stock
---@return boolean propelled value of this rolling stock
function RollingStock:getPropelled()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "propelled") then self:pullPropelled() end
    return self.propelled
end

function RollingStock:setPropelled(propelled)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(propelled) == "boolean", "Need 'propelled' as boolean")
    local oldPropelled = self.propelled
    self.propelled = propelled
    markLoaded(self, "propelled")
    if oldPropelled ~= propelled then markDirty(self, "propelled") end
end

function RollingStock:pullPropelled()
    if not DataClass.isCallable(EEPRollingstockGetMotor) then return nil end
    local _, propelled = EEPRollingstockGetMotor(self.rollingStockName)
    self:setPropelled(propelled ~= false)
    return self.propelled
end

function RollingStock:setOrientationForward(orientationForward)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(orientationForward) == "boolean", "Need 'orientationForward' as boolean")
    local oldOrientationForward = self.orientationForward
    self.orientationForward = orientationForward
    markLoaded(self, "orientationForward")
    if oldOrientationForward ~= orientationForward then markDirty(self, "orientationForward") end
end

function RollingStock:pullOrientationForward()
    if not DataClass.isCallable(EEPRollingstockGetOrientation) then return nil end
    local ok, orientationForward = EEPRollingstockGetOrientation(self.rollingStockName)
    if ok then self:setOrientationForward(orientationForward == true) end
    return self.orientationForward
end

function RollingStock:getOrientationForward()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "orientationForward") then self:pullOrientationForward() end
    return self.orientationForward
end

function RollingStock:setSmoke(smoke)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(smoke) == "number" or type(smoke) == "boolean", "Need 'smoke' as number|boolean")
    local oldSmoke = self.smoke
    self.smoke = smoke
    markLoaded(self, "smoke")
    if oldSmoke ~= smoke then markDirty(self, "smoke") end
end

function RollingStock:pullSmoke()
    if not DataClass.isCallable(EEPRollingstockGetSmoke) then return nil end
    local ok, smoke = EEPRollingstockGetSmoke(self.rollingStockName)
    if ok then self:setSmoke(smoke) end
    return self.smoke
end

function RollingStock:getSmoke()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "smoke") then self:pullSmoke() end
    return self.smoke
end

function RollingStock:setHookStatus(hookStatus)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(hookStatus) == "number", "Need 'hookStatus' as number")
    local oldHookStatus = self.hookStatus
    self.hookStatus = hookStatus
    markLoaded(self, "hookStatus")
    if oldHookStatus ~= hookStatus then markDirty(self, "hookStatus") end
end

function RollingStock:pullHookStatus()
    if not DataClass.isCallable(EEPRollingstockGetHook) then return nil end
    local ok, hookStatus = EEPRollingstockGetHook(self.rollingStockName)
    if ok then self:setHookStatus(hookStatus) end
    return self.hookStatus
end

function RollingStock:getHookStatus()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "hookStatus") then self:pullHookStatus() end
    return self.hookStatus
end

function RollingStock:setHookGlueMode(hookGlueMode)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(hookGlueMode) == "number", "Need 'hookGlueMode' as number")
    local oldHookGlueMode = self.hookGlueMode
    self.hookGlueMode = hookGlueMode
    markLoaded(self, "hookGlueMode")
    if oldHookGlueMode ~= hookGlueMode then markDirty(self, "hookGlueMode") end
end

function RollingStock:pullHookGlueMode()
    if not DataClass.isCallable(EEPRollingstockGetHookGlue) then return nil end
    local ok, hookGlueMode = EEPRollingstockGetHookGlue(self.rollingStockName)
    if ok then self:setHookGlueMode(hookGlueMode) end
    return self.hookGlueMode
end

function RollingStock:getHookGlueMode()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "hookGlueMode") then self:pullHookGlueMode() end
    return self.hookGlueMode
end

function RollingStock:setActive(active)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(active) == "boolean", "Need 'active' as boolean")
    local oldActive = self.active
    self.active = active
    markLoaded(self, "active")
    if oldActive ~= active then markDirty(self, "active") end
end

function RollingStock:pullActive()
    local activeRollingStock = EEPRollingstockGetActive and EEPRollingstockGetActive() or ""
    self:setActive(activeRollingStock == self.rollingStockName)
    return self.active
end

function RollingStock:getActive()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "active") then self:pullActive() end
    return self.active
end

function RollingStock:setTextureTexts(textureTexts)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(textureTexts) == "table", "Need 'textureTexts' as table")
    local oldTextureTexts = self.textureTexts or {}
    local nextTextureTexts = copyTableWithStringKeys(textureTexts)
    self.textureTexts = nextTextureTexts
    markLoaded(self, "textureTexts")
    if not TableUtils.sameDictEntries(oldTextureTexts, nextTextureTexts) then markDirty(self, "surfaceTexts") end
end

function RollingStock:getTextureTexts()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "textureTexts") then self:pullTextureTexts() end
    return self.textureTexts or {}
end

function RollingStock:updateTextureTexts()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    self:setTextureTexts(collectTextureTexts(self.rollingStockName, textureSurfaceNumbersForPull(self),
                                            self.textureTexts))
end

function RollingStock:pullTextureTexts()
    self:updateTextureTexts()
    return self.textureTexts
end

function RollingStock:peekTextureText(surfaceNumber)
    return self.textureTexts and self.textureTexts[tostring(surfaceNumber)] or nil
end

function RollingStock:pullTextureText(surfaceNumber)
    local surface = tonumber(surfaceNumber)
    if not surface or not DataClass.isCallable(EEPRollingstockGetTextureText) then return nil end
    local ok, textureText = EEPRollingstockGetTextureText(self.rollingStockName, surface)
    if not ok then return nil end

    self.textureTexts = self.textureTexts or {}
    self.textureTexts[tostring(surface)] = textureText or ""
    markLoaded(self, "textureTexts")
    return self.textureTexts[tostring(surface)]
end

function RollingStock:getTextureText(surfaceNumber)
    local surface = tonumber(surfaceNumber)
    if not surface then return nil end
    local value = self:peekTextureText(surface)
    if value ~= nil then return value end
    return self:pullTextureText(surface)
end

function RollingStock:setTextureText(surfaceNumber, text)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    local surface = tonumber(surfaceNumber)
    if not surface then return false end
    local value = text or ""
    local cachedValue = self:peekTextureText(surface)
    if cachedValue == value then return true end

    local ok = true
    if EEPRollingstockSetTextureText then
        ok = EEPRollingstockSetTextureText(self.rollingStockName, surface, value) ~= false
    end
    if ok then
        self.textureTexts = self.textureTexts or {}
        self.textureTexts[tostring(surface)] = value
        markLoaded(self, "textureTexts")
        markDirty(self, "surfaceTexts")
    end
    return ok
end

function RollingStock:setAxisValues(axisValues)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(axisValues) == "table", "Need 'axisValues' as table")
    local nextAxisValues = copyTableWithStringKeys(axisValues)
    local oldAxisValues = self.axisValues or {}
    self.axisValues = nextAxisValues
    markLoaded(self, "axisValues")
    if not TableUtils.sameDictEntries(oldAxisValues, nextAxisValues) then markDirty(self, "axisValues") end
end

function RollingStock:getAxisValues()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "axisValues") then self:pullAxisValues() end
    return copyTableWithStringKeys(self.axisValues or {})
end

function RollingStock:updateAxisValues()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    self:setAxisValues(collectAxisValues(self.rollingStockName, RollingStockModelInfoRegistry.get(self.xmlModel)))
end

function RollingStock:pullAxisValues()
    self:updateAxisValues()
    return self.axisValues
end

function RollingStock:peekAxis(axisName)
    return self.axisValues and self.axisValues[tostring(axisName)] or nil
end

function RollingStock:setAxis(axisName, axisValue)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not axisName then return false end
    local value = tonumber(axisValue)
    if not value then return false end
    if self:peekAxis(axisName) == value then return true end
    if not DataClass.isCallable(EEPRollingstockSetAxis) then return false end

    local ok = EEPRollingstockSetAxis(self.rollingStockName, axisName, value) == true
    if ok then setCachedAxisValue(self, axisName, value) end
    return ok
end

function RollingStock:setAxisByNumber(axisNumber, axisValue)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    axisNumber = tonumber(axisNumber)
    axisValue = tonumber(axisValue)
    if not axisNumber or not axisValue then return false end

    local modelInfo = RollingStockModelInfoRegistry.get(self.xmlModel)
    if axisNameForNumber(modelInfo, axisNumber)
        and self:setAxisByNameFallback(axisNumber, axisValue) then
        setCachedAxisValue(self, axisNumber, axisValue)
        return true
    end

    if DataClass.isCallable(EEPRollingstockSetAxisByNumber) then
        local ok = EEPRollingstockSetAxisByNumber(self.rollingStockName, axisNumber, axisValue)
        if ok then
            setCachedAxisValue(self, axisNumber, axisValue)
            return true
        end
    end

    local ok = self:setAxisByNameFallback(axisNumber, axisValue)
    if ok then setCachedAxisValue(self, axisNumber, axisValue) end
    return ok
end

function RollingStock:setAxisByNameFallback(axisNumber, axisValue)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    axisNumber = tonumber(axisNumber)
    axisValue = tonumber(axisValue)
    if not axisNumber or not axisValue then return false end
    if not DataClass.isCallable(EEPRollingstockSetAxis) then return false end

    local axisName = axisNameForNumber(RollingStockModelInfoRegistry.get(self.xmlModel), axisNumber)
    if not axisName then
        print(string.format("[#RollingStock] No axis name for %s axis %s", self.rollingStockName, tostring(axisNumber)))
        return false
    end

    return self:setAxis(axisName, axisValue)
end

function RollingStock:getAxisNames()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    local modelInfo = RollingStockModelInfoRegistry.get(self.xmlModel)
    return copyTableWithStringKeys(modelInfo and modelInfo.axisNames or {})
end

function RollingStock:getAxisNamesKnown()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return axisNamesKnownForModelInfo(RollingStockModelInfoRegistry.get(self.xmlModel))
end

function RollingStock:getTextureNames()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    local modelInfo = RollingStockModelInfoRegistry.get(self.xmlModel)
    return copyTableWithStringKeys(modelInfo and modelInfo.textureNames or {})
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
    markLoaded(self, "rotX")
    markLoaded(self, "rotY")
    markLoaded(self, "rotZ")
    if oldRotX ~= rotX or oldRotY ~= rotY or oldRotZ ~= rotZ then
        markDirty(self, "rotX")
        markDirty(self, "rotY")
        markDirty(self, "rotZ")
    end
end

function RollingStock:pullRotation()
    if not DataClass.isCallable(EEPRollingstockGetRotation) then return nil, nil, nil end
    local ok, rotX, rotY, rotZ = EEPRollingstockGetRotation(self.rollingStockName)
    if ok then self:setRotation(rotX, rotY, rotZ) end
    return self.rotX, self.rotY, self.rotZ
end

function RollingStock:getRotX()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "rotX") then self:pullRotation() end
    return self.rotX
end

function RollingStock:getRotY()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "rotY") then self:pullRotation() end
    return self.rotY
end

function RollingStock:getRotZ()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "rotZ") then self:pullRotation() end
    return self.rotZ
end

--- Updates the front coupling of the rolling stock
---@param couplingFront number the front coupling of the rolling stock
function RollingStock:setCouplingFront(couplingFront)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(couplingFront) == "number", "Need 'positionInTrain' as number")
    local oldCoupling = self.couplingFront
    self.couplingFront = couplingFront
    markLoaded(self, "couplingFront")
    if oldCoupling ~= couplingFront then
        markDirty(self, "couplingFront")
    end
end

function RollingStock:pullCouplingFront()
    if not DataClass.isCallable(EEPRollingstockGetCouplingFront) then return nil end
    local ok, couplingFront = EEPRollingstockGetCouplingFront(self.rollingStockName)
    if ok then self:setCouplingFront(couplingFront) end
    return self.couplingFront
end

--- Get the front coupling of the rolling stock
---@return number the front coupling of the rolling stock
function RollingStock:getCouplingFront()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "couplingFront") then self:pullCouplingFront() end
    return self.couplingFront
end

--- Updates the rear coupling of the rolling stock
---@param couplingRear number the rear coupling of the rolling stock
function RollingStock:setCouplingRear(couplingRear)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(couplingRear) == "number", "Need 'positionInTrain' as number")
    local oldCoupling = self.couplingRear
    self.couplingRear = couplingRear
    markLoaded(self, "couplingRear")
    if oldCoupling ~= couplingRear then
        markDirty(self, "couplingRear")
    end
end

function RollingStock:pullCouplingRear()
    if not DataClass.isCallable(EEPRollingstockGetCouplingRear) then return nil end
    local ok, couplingRear = EEPRollingstockGetCouplingRear(self.rollingStockName)
    if ok then self:setCouplingRear(couplingRear) end
    return self.couplingRear
end

--- Get the rear coupling of the rolling stock
---@return number the rear coupling of the rolling stock
function RollingStock:getCouplingRear()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "couplingRear") then self:pullCouplingRear() end
    return self.couplingRear
end

--- Get the track id of the rolling stock
---@return number the track id of the rolling stock
function RollingStock:getTrackId()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "trackId") then self:pullTrack() end
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
    markLoaded(self, "trackId")
    markLoaded(self, "trackDistance")
    markLoaded(self, "trackDirection")
    markLoaded(self, "trackSystem")
    if oldId ~= trackId then markDirty(self, "trackId") end
    if oldDist ~= trackDistance then markDirty(self, "trackDistance") end
    if oldDir ~= trackDirection then markDirty(self, "trackDirection") end
    if oldSys ~= trackSystem then markDirty(self, "trackSystem") end
end

function RollingStock:pullTrack()
    if not DataClass.isCallable(EEPRollingstockGetTrack) then return nil, nil, nil, nil end
    local ok, trackId, trackDistance, trackDirection, trackSystem = EEPRollingstockGetTrack(self.rollingStockName)
    if ok then self:setTrack(trackId, trackDistance, trackDirection, trackSystem) end
    return self.trackId, self.trackDistance, self.trackDirection, self.trackSystem
end

--- Get the track distance of the rolling stock
---@return number the track distance of the rolling stock
function RollingStock:getTrackDistance()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "trackDistance") then self:pullTrack() end
    return self.trackDistance
end

--- Get the track direction of the rolling stock
---@return number the track direction of the rolling stock
function RollingStock:getTrackDirection()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "trackDirection") then self:pullTrack() end
    return self.trackDirection
end

--- Get the track system of the rolling stock
---@return number the track system of the rolling stock
function RollingStock:getTrackSystem()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "trackSystem") then self:pullTrack() end
    return self.trackSystem
end

--- Updates the trains trackType
---@param trackType string train trackType
function RollingStock:setTrackType(trackType)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(trackType) == "string", "Need 'trackType' as string")
    local oldValue = self.trackType
    self.trackType = trackType
    markLoaded(self, "trackType")
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
    markLoaded(self, "x")
    markLoaded(self, "y")
    markLoaded(self, "z")
    if oldX ~= x then markDirty(self, "posX") end
    if oldY ~= y then markDirty(self, "posY") end
    if oldZ ~= z then markDirty(self, "posZ") end
end

function RollingStock:pullPosition()
    if not DataClass.isCallable(EEPRollingstockGetPosition) then return nil, nil, nil end
    local hasPos, posX, posY, posZ = EEPRollingstockGetPosition(self.rollingStockName)
    if hasPos then self:setPosition(tonumber(posX) or -1, tonumber(posY) or -1, tonumber(posZ) or -1) end
    return self.x, self.y, self.z
end

--- Get the x coordinate of this rolling stock
---@return number x coordinate of this rolling stock
function RollingStock:getX()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "x") then self:pullPosition() end
    return self.x
end

--- Get the y coordinate of this rolling stock
---@return number y coordinate of this rolling stock
function RollingStock:getY()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "y") then self:pullPosition() end
    return self.y
end

--- Get the z coordinate of this rolling stock
---@return number z coordinate of this rolling stock
function RollingStock:getZ()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "z") then self:pullPosition() end
    return self.z
end

--- Get the mileage of this rolling stock
---@param mileage number mileage of this rolling stock
function RollingStock:setMileage(mileage)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    assert(type(mileage) == "number", "Need 'mileage' as number")
    local oldMileage = self.mileage
    self.mileage = mileage
    markLoaded(self, "mileage")
    if oldMileage ~= mileage then
        markDirty(self, "mileage")
    end
end

function RollingStock:pullMileage()
    if not DataClass.isCallable(EEPRollingstockGetMileage) then return nil end
    local hasMileage, mileage = EEPRollingstockGetMileage(self.rollingStockName)
    if hasMileage then self:setMileage(mileage) end
    return self.mileage
end

--- Get the mileage of this rolling stock
---@return number mileage of this rolling stock
function RollingStock:getMileage()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    if not DataClass.isLoaded(self, "mileage") then self:pullMileage() end
    return self.mileage
end

function RollingStock:getXmlModel()
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    return self.xmlModel
end

function RollingStock:peekRollingStockName() return self.rollingStockName end

function RollingStock:peekTrainName() return self.trainName end

function RollingStock:peekPositionInTrain() return self.positionInTrain end

function RollingStock:peekCouplingFront() return self.couplingFront end

function RollingStock:peekCouplingRear() return self.couplingRear end

function RollingStock:peekLength() return self.length end

function RollingStock:peekPropelled() return self.propelled end

function RollingStock:peekModelType() return self.modelType end

function RollingStock:peekModelTypeText() return self.modelTypeText end

function RollingStock:peekLicencePlate() return self.values[TagKeys.RollingStock.licencePlate] end

function RollingStock:peekWagonNumber() return self.values[TagKeys.RollingStock.wagonNumber] end

function RollingStock:peekWagonNr() return self:peekWagonNumber() end

function RollingStock:peekTrackType() return self.trackType end

function RollingStock:peekHookStatus() return self.hookStatus end

function RollingStock:peekHookGlueMode() return self.hookGlueMode end

function RollingStock:peekTextureTexts() return self.textureTexts end

function RollingStock:peekTrackId() return self.trackId end

function RollingStock:peekTrackDistance() return self.trackDistance end

function RollingStock:peekTrackDirection() return self.trackDirection end

function RollingStock:peekTrackSystem() return self.trackSystem end

function RollingStock:peekX() return self.x end

function RollingStock:peekY() return self.y end

function RollingStock:peekZ() return self.z end

function RollingStock:peekMileage() return self.mileage end

function RollingStock:peekOrientationForward() return self.orientationForward end

function RollingStock:peekSmoke() return self.smoke end

function RollingStock:peekActive() return self.active end

function RollingStock:peekAxisNamesKnown()
    return axisNamesKnownForModelInfo(RollingStockModelInfoRegistry.peek(self.xmlModel))
end

function RollingStock:peekAxisNames()
    local modelInfo = RollingStockModelInfoRegistry.peek(self.xmlModel)
    return copyTableWithStringKeys(modelInfo and modelInfo.axisNames or {})
end

function RollingStock:peekAxisValues() return copyTableWithStringKeys(self.axisValues or {}) end

function RollingStock:peekTextureNames()
    local modelInfo = RollingStockModelInfoRegistry.peek(self.xmlModel)
    return copyTableWithStringKeys(modelInfo and modelInfo.textureNames or {})
end

function RollingStock:peekRotX() return self.rotX end

function RollingStock:peekRotY() return self.rotY end

function RollingStock:peekRotZ() return self.rotZ end

function RollingStock:peekXmlModel() return self.xmlModel end

function RollingStock:refreshModelInfo(deferModelInfo, updateAxisValues)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    local oldAxisNames = self:peekAxisNames()
    local oldAxisNamesKnown = self:peekAxisNamesKnown()
    local oldTextureNames = self:peekTextureNames()
    local modelInfo = modelInfoForXmlModel(self.xmlModel, deferModelInfo == true)
    if updateAxisValues then self:setAxisValues(collectAxisValues(self.rollingStockName, modelInfo)) end
    if oldAxisNamesKnown ~= self:peekAxisNamesKnown() then markDirty(self, "axisNamesKnown") end
    if not TableUtils.sameDictEntries(oldAxisNames, self:peekAxisNames()) then markDirty(self, "axisNames") end
    if not TableUtils.sameDictEntries(oldTextureNames, self:peekTextureNames()) then markDirty(self, "textureNames") end
end

function RollingStock:markModelInfoDirtyFields(dirtyFields)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    dirtyFields = dirtyFields or {}
    if dirtyFields.axisNamesKnown then markDirty(self, "axisNamesKnown") end
    if dirtyFields.axisNames then markDirty(self, "axisNames") end
    if dirtyFields.textureNames then markDirty(self, "textureNames") end
end

function RollingStock:setXmlModel(model)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    local oldXmlModel = self.xmlModel
    self.xmlModel = model
    markLoaded(self, "xmlModel")
    self.model = RollingStockModels.modelFor(self.rollingStockName, self.xmlModel)
    self:refreshModelInfo(false, true)
    if oldXmlModel ~= model then markDirty(self, "xmlModel") end
end

function RollingStock:setXmlModelFromSnapshot(model, deferModelInfo)
    assert(type(self) == "table" and self.type == "RollingStock", "Call this method with ':'")
    local oldXmlModel = self.xmlModel
    self.xmlModel = model
    markLoaded(self, "xmlModel")
    self.model = RollingStockModels.modelFor(self.rollingStockName, self.xmlModel)
    self:refreshModelInfo(deferModelInfo == true, false)
    if oldXmlModel ~= model then markDirty(self, "xmlModel") end
end

function RollingStock:resetDirty()
    self.dirtyFields = {}
end

function RollingStock:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

local function rollingStockFromRegistry(rollingStockName)
    return require("ce.hub.data.rollingstock.RollingStockRegistry").get(rollingStockName)
end

local function printMissingRollingStock(rollingStockName)
    print(string.format(
        "[#RollingStock] Command ignored, rolling stock is not registered: %s",
        tostring(rollingStockName)
    ))
end

function RollingStock.setActiveByName(rollingStockName)
    local rollingStockToActivate = rollingStockFromRegistry(rollingStockName)
    if not rollingStockToActivate then
        printMissingRollingStock(rollingStockName)
        return false
    end
    if not DataClass.isCallable(EEPRollingstockSetActive) then return false end

    local ok = EEPRollingstockSetActive(rollingStockName) ~= false
    if ok then
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
        local ScenarioRegistry = require("ce.hub.data.scenario.ScenarioRegistry")
        for _, rollingStock in pairs(RollingStockRegistry.getAll()) do
            rollingStock:setActive(rollingStock.rollingStockName == rollingStockName)
        end
        ScenarioRegistry.getOrCreate():setActiveRollingStock(rollingStockName)
    end
    return ok
end

function RollingStock.setUserCameraByName(rollingStockName, posX, posY, posZ, rotH, rotV, setDirectly)
    local rollingStock = rollingStockFromRegistry(rollingStockName)
    local x = tonumber(posX)
    local y = tonumber(posY)
    local z = tonumber(posZ)
    local horizontal = tonumber(rotH)
    local vertical = tonumber(rotV)
    local activate = tonumber(setDirectly)
    if not rollingStock or not x or not y or not z or not horizontal or not vertical then
        if not rollingStock then printMissingRollingStock(rollingStockName) end
        return false
    end
    if not DataClass.isCallable(EEPRollingstockSetUserCamera) then return false end
    return EEPRollingstockSetUserCamera(rollingStockName, x, y, z, horizontal, vertical, activate) ~= false
end

function RollingStock.setAxisByName(rollingStockName, axisName, axisValue, axisNumber)
    local rollingStock = rollingStockFromRegistry(rollingStockName)
    if not rollingStock then
        printMissingRollingStock(rollingStockName)
        return false
    end

    local ok = rollingStock:setAxis(axisName, axisValue)
    if ok and axisNumber then setCachedAxisValue(rollingStock, axisNumber, axisValue) end
    return ok
end

function RollingStock.setAxisByNumberByName(rollingStockName, axisNumber, axisValue)
    local rollingStock = rollingStockFromRegistry(rollingStockName)
    if not rollingStock then
        printMissingRollingStock(rollingStockName)
        return false
    end
    return rollingStock:setAxisByNumber(axisNumber, axisValue)
end

function RollingStock:openDoors() self.model:openDoors(self.rollingStockName) end

function RollingStock:closeDoors() self.model:closeDoors(self.rollingStockName) end

return RollingStock
