-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local cached = DtoFieldAccess.cached
local peek = DtoFieldAccess.peek
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local TableUtils = require("ce.hub.util.TableUtils")

---@class RollingStockDtoFactory
---@field createFullDto fun(stock: RollingStock, isSubscribed: boolean|nil):string,string,string,RollingStockDto
---@field createPatchDto fun(stock: RollingStock, dirtyFields: table<string,boolean>, isSubscribed: boolean|nil):
---string,string,string,RollingStockDto
---@field createRemovalDto fun(stockId: string):string,string,string,table
local RollingStockDtoFactory = {}

local CE_TYPE = HubCeTypes.RollingStock
local KEY_ID = "id"

local XML_MODEL_PLACEHOLDER = ""

local function getLicencePlate(stock)
    return cached(stock, function (source) return source:peekLicencePlate() end, "licencePlate") or ""
end

local function getWagonNumber(stock)
    return cached(stock, function (source) return source:peekWagonNumber() end, "vehicleNumber") or
        cached(stock, function (source) return source:peekWagonNr() end, "nr") or ""
end

local function getXmlModel(stock)
    return cached(stock, function (source) return source:peekXmlModel() end, "xmlModel") or XML_MODEL_PLACEHOLDER
end

local function getAxisNamesKnown(stock, isSelected)
    if isSelected and stock.getAxisNamesKnown then return stock:getAxisNamesKnown() end
    return cached(stock, function (source) return source:peekAxisNamesKnown() end, "axisNamesKnown") == true
end

local function copiedCachedTable(stock, readCachedValue, fieldName)
    return TableUtils.shallowcopy(cached(stock, readCachedValue, fieldName) or {})
end

local function getAxisNames(stock, isSelected)
    if isSelected and stock.getAxisNames then return TableUtils.shallowcopy(stock:getAxisNames()) end
    return copiedCachedTable(stock, function (source) return source:peekAxisNames() end, "axisNames")
end

local function getTextureNames(stock, isSelected)
    if isSelected and stock.getTextureNames then return TableUtils.shallowcopy(stock:getTextureNames()) end
    return copiedCachedTable(stock, function (source) return source:peekTextureNames() end, "textureNames")
end

-- DtoFields: class definition in RollingStockDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = peek(function (source) return source:peekRollingStockName() end, "rollingStockName"),
        placeholder = ""
    },
    trainName = {
        getValue = peek(function (source) return source:peekTrainName() end, "trainName"),
        placeholder = ""
    },
    positionInTrain = {
        getValue = peek(function (source) return source:peekPositionInTrain() end, "positionInTrain"),
        placeholder = 0
    },
    couplingFront = {
        getValue = peek(function (source) return source:peekCouplingFront() end, "couplingFront"),
        placeholder = 0
    },
    couplingRear = {
        getValue = peek(function (source) return source:peekCouplingRear() end, "couplingRear"),
        placeholder = 0
    },
    length = {
        getValue = peek(function (source) return source:peekLength() end, "length"),
        placeholder = 0
    },
    propelled = {
        getValue = peek(function (source) return source:peekPropelled() end, "propelled"),
        placeholder = false
    },
    modelType = {
        getValue = peek(function (source) return source:peekModelType() end, "modelType"),
        placeholder = 0
    },
    modelTypeText = {
        getValue = peek(function (source) return source:peekModelTypeText() end, "modelTypeText"),
        placeholder = ""
    },
    tag = {
        getValue = peek(function (source) return source:peekTag() end, "tag"),
        placeholder = ""
    },
    licencePlate = {
        getValue = function (stock) return getLicencePlate(stock) end,
        placeholder = ""
    },
    vehicleNumber = {
        getValue = function (stock) return getWagonNumber(stock) end,
        placeholder = ""
    },
    nr = {
        getValue = function (stock) return getWagonNumber(stock) end,
        placeholder = ""
    },
    trackType = {
        getValue = peek(function (source) return source:peekTrackType() end, "trackType"),
        placeholder = ""
    },
    hookStatus = {
        getValue = peek(function (source) return source:peekHookStatus() end, "hookStatus"),
        placeholder = 0
    },
    hookGlueMode = {
        getValue = peek(function (source) return source:peekHookGlueMode() end, "hookGlueMode"),
        placeholder = 0
    },
    surfaceTexts = {
        getValue = function (stock)
            return copiedCachedTable(stock, function (source) return source:peekTextureTexts() end, "textureTexts")
        end,
        placeholder = {}
    },
    trackId = {
        getValue = peek(function (source) return source:peekTrackId() end, "trackId"),
        placeholder = 0
    },
    trackDistance = {
        getValue = peek(function (source) return source:peekTrackDistance() end, "trackDistance"),
        placeholder = 0
    },
    trackDirection = {
        getValue = peek(function (source) return source:peekTrackDirection() end, "trackDirection"),
        placeholder = 0
    },
    trackSystem = {
        getValue = peek(function (source) return source:peekTrackSystem() end, "trackSystem"),
        placeholder = 0
    },
    posX = {
        getValue = peek(function (source) return source:peekX() end, "x"),
        placeholder = 0
    },
    posY = {
        getValue = peek(function (source) return source:peekY() end, "y"),
        placeholder = 0
    },
    posZ = {
        getValue = peek(function (source) return source:peekZ() end, "z"),
        placeholder = 0
    },
    mileage = {
        getValue = peek(function (source) return source:peekMileage() end, "mileage"),
        placeholder = 0
    },
    orientationForward = {
        getValue = peek(function (source) return source:peekOrientationForward() end, "orientationForward"),
        placeholder = false
    },
    smoke = {
        getValue = peek(function (source) return source:peekSmoke() end, "smoke"),
        placeholder = 0
    },
    active = {
        getValue = peek(function (source) return source:peekActive() end, "active"),
        placeholder = false
    },
    axisNamesKnown = {
        getValue = function (stock, isSelected) return getAxisNamesKnown(stock, isSelected) end,
        placeholder = false
    },
    axisNames = {
        getValue = function (stock, isSelected) return getAxisNames(stock, isSelected) end,
        placeholder = {}
    },
    axisValues = {
        getValue = function (stock)
            return copiedCachedTable(stock, function (source) return source:peekAxisValues() end, "axisValues")
        end,
        placeholder = {}
    },
    textureNames = {
        getValue = function (stock, isSelected) return getTextureNames(stock, isSelected) end,
        placeholder = {}
    },
    rotX = {
        getValue = peek(function (source) return source:peekRotX() end, "rotX"),
        placeholder = 0
    },
    rotY = {
        getValue = peek(function (source) return source:peekRotY() end, "rotY"),
        placeholder = 0
    },
    rotZ = {
        getValue = peek(function (source) return source:peekRotZ() end, "rotZ"),
        placeholder = 0
    },
    xmlModel = {
        getValue = function (stock) return getXmlModel(stock) end,
        placeholder = XML_MODEL_PLACEHOLDER
    },
}

local function baseDto(stock)
    return {
        ceType = CE_TYPE,
        id = cached(stock, function (source) return source:peekRollingStockName() end, "rollingStockName")
    }
end

local function buildFullDto(stock, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("rollingStocks")
    return DtoBuilder.buildFullDto(baseDto(stock), stock, dtoFields, fieldPolicies, isSelected)
end

local function buildPatchDto(stock, dirtyFields, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("rollingStocks")
    return DtoBuilder.buildPatchDto(baseDto(stock), stock, dirtyFields, dtoFields, fieldPolicies, isSelected)
end

function RollingStockDtoFactory.createFullDto(stock, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = buildFullDto(stock, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockDtoFactory.createPatchDto(stock, dirtyFields, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = buildPatchDto(stock, dirtyFields, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockDtoFactory.createRemovalDto(stockId)
    local dto = { ceType = CE_TYPE, id = stockId }
    return CE_TYPE, KEY_ID, stockId, dto
end

return RollingStockDtoFactory
