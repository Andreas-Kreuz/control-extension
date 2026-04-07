 -- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStockDtoFactory = {}

local CE_TYPE = HubCeTypes.RollingStock
local KEY_ID = "id"
local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local function copyTable(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[key] = value end
    return copy
end

local placeHolders = {
    trackId = 0,
    trackDistance = 0,
    trackDirection = 0,
    trackSystem = 0,
    posX = 0,
    posY = 0,
    posZ = 0,
    mileage = 0,
    orientationForward = false,
    smoke = 0,
    active = false,
    rotX = 0,
    rotY = 0,
    rotZ = 0,
}

local fieldGetters = {
    name = function (s) return s.rollingStockName end,
    trainName = function (s) return s:getTrainName() end,
    positionInTrain = function (s) return s:getPositionInTrain() end,
    couplingFront = function (s) return s:getCouplingFront() end,
    couplingRear = function (s) return s:getCouplingRear() end,
    length = function (s) return s:getLength() end,
    propelled = function (s) return s:getPropelled() end,
    modelType = function (s) return s:getModelType() end,
    modelTypeText = function (s) return s:getModelTypeText() end,
    tag = function (s) return s:getTag() end,
    nr = function (s) return s:getWagonNr() end,
    trackType = function (s) return s:getTrackType() end,
    hookStatus = function (s) return s:getHookStatus() end,
    hookGlueMode = function (s) return s:getHookGlueMode() end,
    surfaceTexts = function (s) return copyTable(s:getTextureTexts()) end,
    trackId = function (s) return s:getTrackId() end,
    trackDistance = function (s) return s:getTrackDistance() end,
    trackDirection = function (s) return s:getTrackDirection() end,
    trackSystem = function (s) return s:getTrackSystem() end,
    posX = function (s) return s:getX() end,
    posY = function (s) return s:getY() end,
    posZ = function (s) return s:getZ() end,
    mileage = function (s) return s:getMileage() end,
    orientationForward = function (s) return s:getOrientationForward() end,
    smoke = function (s) return s:getSmoke() end,
    active = function (s) return s:getActive() end,
    rotX = function (s) return s:getRotX() end,
    rotY = function (s) return s:getRotY() end,
    rotZ = function (s) return s:getRotZ() end,
}

local function toFullDto(stock, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("rollingStocks")
    local dto = {
        ceType = CE_TYPE,
        id = stock.rollingStockName,
        name = stock.rollingStockName,
    }
    for field, getter in pairs(fieldGetters) do
        if field ~= "name" then
            if SyncPolicy.shouldPublishField(fieldPolicies, field, isSelected) then
                dto[field] = getter(stock)
            elseif placeHolders[field] ~= nil
                and SyncPolicy.shouldPublishPlaceholder(fieldPolicies, field, isSelected) then
                dto[field] = placeHolders[field]
            end
        end
    end
    return dto
end

local function toPatchDto(stock, dirtyFields, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("rollingStocks")
    local dto = {
        ceType = CE_TYPE,
        id = stock.rollingStockName,
    }
    for field in pairs(dirtyFields) do
        local getter = fieldGetters[field]
        if getter and SyncPolicy.shouldPublishField(fieldPolicies, field, isSelected) then
            dto[field] = getter(stock)
        elseif getter and placeHolders[field] ~= nil and SyncPolicy.shouldPublishPlaceholder(fieldPolicies, field,
                                                                                             isSelected) then
            dto[field] = placeHolders[field]
        end
    end
    return dto
end

function RollingStockDtoFactory.createFullDto(stock, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = toFullDto(stock, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockDtoFactory.createPatchDto(stock, dirtyFields, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = toPatchDto(stock, dirtyFields, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockDtoFactory.createOndemandPlaceholderPatch(stock)
    local dto = {
        ceType = CE_TYPE,
        id = stock.rollingStockName,
    }
    for field, placeholder in pairs(placeHolders) do
        dto[field] = placeholder
    end
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockDtoFactory.createRefDto(stockId)
    local dto = { ceType = CE_TYPE, id = stockId }
    return CE_TYPE, KEY_ID, stockId, dto
end

return RollingStockDtoFactory
