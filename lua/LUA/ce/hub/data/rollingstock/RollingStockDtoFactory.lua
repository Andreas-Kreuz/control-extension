-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
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

local function getXmlModel(stock)
    if stock.getXmlModel then return stock:getXmlModel() end
    return stock.xmlModel or XML_MODEL_PLACEHOLDER
end

-- DtoFields: class definition in RollingStockDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = function (stock) return stock.rollingStockName end,
        placeholder = ""
    },
    trainName = {
        getValue = function (stock) return stock:getTrainName() end,
        placeholder = ""
    },
    positionInTrain = {
        getValue = function (stock) return stock:getPositionInTrain() end,
        placeholder = 0
    },
    couplingFront = {
        getValue = function (stock) return stock:getCouplingFront() end,
        placeholder = 0
    },
    couplingRear = {
        getValue = function (stock) return stock:getCouplingRear() end,
        placeholder = 0
    },
    length = {
        getValue = function (stock) return stock:getLength() end,
        placeholder = 0
    },
    propelled = {
        getValue = function (stock) return stock:getPropelled() end,
        placeholder = false
    },
    modelType = {
        getValue = function (stock) return stock:getModelType() end,
        placeholder = 0
    },
    modelTypeText = {
        getValue = function (stock) return stock:getModelTypeText() end,
        placeholder = ""
    },
    tag = {
        getValue = function (stock) return stock:getTag() end,
        placeholder = ""
    },
    nr = {
        getValue = function (stock) return stock:getWagonNr() end,
        placeholder = ""
    },
    trackType = {
        getValue = function (stock) return stock:getTrackType() end,
        placeholder = ""
    },
    hookStatus = {
        getValue = function (stock) return stock:getHookStatus() end,
        placeholder = 0
    },
    hookGlueMode = {
        getValue = function (stock) return stock:getHookGlueMode() end,
        placeholder = 0
    },
    surfaceTexts = {
        getValue = function (stock) return TableUtils.shallowcopy(stock:getTextureTexts() or {}) end,
        placeholder = {}
    },
    trackId = {
        getValue = function (stock) return stock:getTrackId() end,
        placeholder = 0
    },
    trackDistance = {
        getValue = function (stock) return stock:getTrackDistance() end,
        placeholder = 0
    },
    trackDirection = {
        getValue = function (stock) return stock:getTrackDirection() end,
        placeholder = 0
    },
    trackSystem = {
        getValue = function (stock) return stock:getTrackSystem() end,
        placeholder = 0
    },
    posX = {
        getValue = function (stock) return stock:getX() end,
        placeholder = 0
    },
    posY = {
        getValue = function (stock) return stock:getY() end,
        placeholder = 0
    },
    posZ = {
        getValue = function (stock) return stock:getZ() end,
        placeholder = 0
    },
    mileage = {
        getValue = function (stock) return stock:getMileage() end,
        placeholder = 0
    },
    orientationForward = {
        getValue = function (stock) return stock:getOrientationForward() end,
        placeholder = false
    },
    smoke = {
        getValue = function (stock) return stock:getSmoke() end,
        placeholder = 0
    },
    active = {
        getValue = function (stock) return stock:getActive() end,
        placeholder = false
    },
    axisNames = {
        getValue = function (stock) return TableUtils.shallowcopy(stock:getAxisNames() or {}) end,
        placeholder = {}
    },
    axisValues = {
        getValue = function (stock) return TableUtils.shallowcopy(stock:getAxisValues() or {}) end,
        placeholder = {}
    },
    textureNames = {
        getValue = function (stock) return TableUtils.shallowcopy(stock:getTextureNames() or {}) end,
        placeholder = {}
    },
    rotX = {
        getValue = function (stock) return stock:getRotX() end,
        placeholder = 0
    },
    rotY = {
        getValue = function (stock) return stock:getRotY() end,
        placeholder = 0
    },
    rotZ = {
        getValue = function (stock) return stock:getRotZ() end,
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
        id = stock.rollingStockName
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
