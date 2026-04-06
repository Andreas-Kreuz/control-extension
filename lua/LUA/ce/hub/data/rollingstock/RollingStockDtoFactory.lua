-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStockDtoFactory = {}

local CE_TYPE = HubCeTypes.RollingStock
local KEY_ID = "id"

local function copyTable(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[key] = value end
    return copy
end

-- ondemand fields use typed zero-value placeholders when isSubscribed is false
local ondemandFields = {
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

local function toFullDto(stock, isSubscribed)
    return {
        ceType = CE_TYPE,
        id = stock.rollingStockName,
        name = stock.rollingStockName,
        trainName = stock:getTrainName(),
        positionInTrain = stock:getPositionInTrain(),
        couplingFront = stock:getCouplingFront(),
        couplingRear = stock:getCouplingRear(),
        length = stock:getLength(),
        propelled = stock:getPropelled(),
        modelType = stock:getModelType(),
        modelTypeText = stock:getModelTypeText(),
        tag = stock:getTag(),
        nr = stock:getWagonNr(),
        trackType = stock:getTrackType(),
        hookStatus = stock:getHookStatus(),
        hookGlueMode = stock:getHookGlueMode(),
        surfaceTexts = copyTable(stock:getTextureTexts()),
        trackId = isSubscribed and stock:getTrackId() or 0,
        trackDistance = isSubscribed and stock:getTrackDistance() or 0,
        trackDirection = isSubscribed and stock:getTrackDirection() or 0,
        trackSystem = isSubscribed and stock:getTrackSystem() or 0,
        posX = isSubscribed and stock:getX() or 0,
        posY = isSubscribed and stock:getY() or 0,
        posZ = isSubscribed and stock:getZ() or 0,
        mileage = isSubscribed and stock:getMileage() or 0,
        orientationForward = isSubscribed and stock:getOrientationForward() or false,
        smoke = isSubscribed and stock:getSmoke() or 0,
        active = isSubscribed and stock:getActive() or false,
        rotX = isSubscribed and stock:getRotX() or 0,
        rotY = isSubscribed and stock:getRotY() or 0,
        rotZ = isSubscribed and stock:getRotZ() or 0,
    }
end

local fieldGetters = {
    name = function(s) return s.rollingStockName end,
    trainName = function(s) return s:getTrainName() end,
    positionInTrain = function(s) return s:getPositionInTrain() end,
    couplingFront = function(s) return s:getCouplingFront() end,
    couplingRear = function(s) return s:getCouplingRear() end,
    length = function(s) return s:getLength() end,
    propelled = function(s) return s:getPropelled() end,
    modelType = function(s) return s:getModelType() end,
    modelTypeText = function(s) return s:getModelTypeText() end,
    tag = function(s) return s:getTag() end,
    nr = function(s) return s:getWagonNr() end,
    trackType = function(s) return s:getTrackType() end,
    hookStatus = function(s) return s:getHookStatus() end,
    hookGlueMode = function(s) return s:getHookGlueMode() end,
    surfaceTexts = function(s) return copyTable(s:getTextureTexts()) end,
    trackId = function(s) return s:getTrackId() end,
    trackDistance = function(s) return s:getTrackDistance() end,
    trackDirection = function(s) return s:getTrackDirection() end,
    trackSystem = function(s) return s:getTrackSystem() end,
    posX = function(s) return s:getX() end,
    posY = function(s) return s:getY() end,
    posZ = function(s) return s:getZ() end,
    mileage = function(s) return s:getMileage() end,
    orientationForward = function(s) return s:getOrientationForward() end,
    smoke = function(s) return s:getSmoke() end,
    active = function(s) return s:getActive() end,
    rotX = function(s) return s:getRotX() end,
    rotY = function(s) return s:getRotY() end,
    rotZ = function(s) return s:getRotZ() end,
}

local function toPatchDto(stock, dirtyFields, isSubscribed)
    local dto = {
        ceType = CE_TYPE,
        id = stock.rollingStockName,
    }
    for field in pairs(dirtyFields) do
        local getter = fieldGetters[field]
        if getter then
            if ondemandFields[field] ~= nil then
                dto[field] = isSubscribed and getter(stock) or ondemandFields[field]
            else
                dto[field] = getter(stock)
            end
        end
    end
    return dto
end

function RollingStockDtoFactory.createFullDto(stock, isSubscribed)
    if isSubscribed == nil then isSubscribed = true end
    local dto = toFullDto(stock, isSubscribed)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockDtoFactory.createPatchDto(stock, dirtyFields, isSubscribed)
    if isSubscribed == nil then isSubscribed = true end
    local dto = toPatchDto(stock, dirtyFields, isSubscribed)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockDtoFactory.createOndemandPlaceholderPatch(stock)
    local dto = {
        ceType = CE_TYPE,
        id = stock.rollingStockName,
    }
    for field, placeholder in pairs(ondemandFields) do
        dto[field] = placeholder
    end
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockDtoFactory.createRefDto(stockId)
    local dto = { ceType = CE_TYPE, id = stockId }
    return CE_TYPE, KEY_ID, stockId, dto
end

return RollingStockDtoFactory
