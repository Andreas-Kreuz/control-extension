-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local StockDtoFactory = {}

local CE_TYPE = HubCeTypes.RollingStock
local KEY_ID = "id"

local function toDto(stock)
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
        orientationForward = stock:getOrientationForward(),
        smoke = stock:getSmoke(),
        hookStatus = stock:getHookStatus(),
        hookGlueMode = stock:getHookGlueMode(),
        active = stock:getActive(),
        nr = stock:getWagonNr(),
        trackId = stock:getTrackId(),
        trackDistance = stock:getTrackDistance(),
        trackDirection = stock:getTrackDirection(),
        trackSystem = stock:getTrackSystem(),
        trackType = stock:getTrackType(),
        posX = stock:getX(),
        posY = stock:getY(),
        posZ = stock:getZ(),
        mileage = stock:getMileage()
    }
end

function StockDtoFactory.createDto(stock)
    local dto = toDto(stock)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function StockDtoFactory.createDtoList(stocks)
    local dtos = {}
    for stockId, stock in pairs(stocks) do
        local _, _, _, dto = StockDtoFactory.createDto(stock)
        dtos[stockId] = dto
    end
    return CE_TYPE, KEY_ID, dtos
end

function StockDtoFactory.createRefDto(stockId)
    local dto = { ceType = CE_TYPE, id = stockId }
    return CE_TYPE, KEY_ID, stockId, dto
end

return StockDtoFactory
