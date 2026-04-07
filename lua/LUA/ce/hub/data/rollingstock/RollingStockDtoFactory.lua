-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStockDtoFactory = {}

local CE_TYPE = HubCeTypes.RollingStock
local KEY_ID = "id"

local function copyTable(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[key] = value end
    return copy
end

local function shouldInclude(fieldOptions, fieldName)
    local field = fieldOptions and fieldOptions[fieldName] or nil
    return field == nil or field.collect ~= false
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

local function toFullDto(stock, isSubscribed, fieldOptions)
    local dto = {
        ceType = CE_TYPE,
        id = stock.rollingStockName,
        name = stock.rollingStockName,
    }
    if shouldInclude(fieldOptions, "trainName") then dto.trainName = stock:getTrainName() end
    if shouldInclude(fieldOptions, "positionInTrain") then dto.positionInTrain = stock:getPositionInTrain() end
    if shouldInclude(fieldOptions, "couplingFront") then dto.couplingFront = stock:getCouplingFront() end
    if shouldInclude(fieldOptions, "couplingRear") then dto.couplingRear = stock:getCouplingRear() end
    if shouldInclude(fieldOptions, "length") then dto.length = stock:getLength() end
    if shouldInclude(fieldOptions, "propelled") then dto.propelled = stock:getPropelled() end
    if shouldInclude(fieldOptions, "modelType") then dto.modelType = stock:getModelType() end
    if shouldInclude(fieldOptions, "modelTypeText") then dto.modelTypeText = stock:getModelTypeText() end
    if shouldInclude(fieldOptions, "tag") then dto.tag = stock:getTag() end
    if shouldInclude(fieldOptions, "nr") then dto.nr = stock:getWagonNr() end
    if shouldInclude(fieldOptions, "trackType") then dto.trackType = stock:getTrackType() end
    if shouldInclude(fieldOptions, "hookStatus") then dto.hookStatus = stock:getHookStatus() end
    if shouldInclude(fieldOptions, "hookGlueMode") then dto.hookGlueMode = stock:getHookGlueMode() end
    if shouldInclude(fieldOptions, "surfaceTexts") then dto.surfaceTexts = copyTable(stock:getTextureTexts()) end
    if shouldInclude(fieldOptions, "trackId") then dto.trackId = isSubscribed and stock:getTrackId() or 0 end
    if shouldInclude(fieldOptions, "trackDistance") then
        dto.trackDistance = isSubscribed and stock:getTrackDistance() or 0
    end
    if shouldInclude(fieldOptions, "trackDirection") then
        dto.trackDirection = isSubscribed and stock:getTrackDirection() or 0
    end
    if shouldInclude(fieldOptions, "trackSystem") then
        dto.trackSystem = isSubscribed and stock:getTrackSystem() or 0
    end
    if shouldInclude(fieldOptions, "posX") then dto.posX = isSubscribed and stock:getX() or 0 end
    if shouldInclude(fieldOptions, "posY") then dto.posY = isSubscribed and stock:getY() or 0 end
    if shouldInclude(fieldOptions, "posZ") then dto.posZ = isSubscribed and stock:getZ() or 0 end
    if shouldInclude(fieldOptions, "mileage") then dto.mileage = isSubscribed and stock:getMileage() or 0 end
    if shouldInclude(fieldOptions, "orientationForward") then
        dto.orientationForward = isSubscribed and stock:getOrientationForward() or false
    end
    if shouldInclude(fieldOptions, "smoke") then dto.smoke = isSubscribed and stock:getSmoke() or 0 end
    if shouldInclude(fieldOptions, "active") then dto.active = isSubscribed and stock:getActive() or false end
    if shouldInclude(fieldOptions, "rotX") then dto.rotX = isSubscribed and stock:getRotX() or 0 end
    if shouldInclude(fieldOptions, "rotY") then dto.rotY = isSubscribed and stock:getRotY() or 0 end
    if shouldInclude(fieldOptions, "rotZ") then dto.rotZ = isSubscribed and stock:getRotZ() or 0 end
    return dto
end

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

local function toPatchDto(stock, dirtyFields, isSubscribed, fieldOptions)
    local dto = {
        ceType = CE_TYPE,
        id = stock.rollingStockName,
    }
    for field in pairs(dirtyFields) do
        local getter = shouldInclude(fieldOptions, field) and fieldGetters[field] or nil
        if getter then
            if placeHolders[field] ~= nil then
                dto[field] = isSubscribed and getter(stock) or placeHolders[field]
            else
                dto[field] = getter(stock)
            end
        end
    end
    return dto
end

function RollingStockDtoFactory.createFullDto(stock, isSubscribed, fieldOptions)
    if isSubscribed == nil then isSubscribed = true end
    local dto = toFullDto(stock, isSubscribed, fieldOptions)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockDtoFactory.createPatchDto(stock, dirtyFields, isSubscribed, fieldOptions)
    if isSubscribed == nil then isSubscribed = true end
    local dto = toPatchDto(stock, dirtyFields, isSubscribed, fieldOptions)
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
