-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockStaticLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockStaticDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStockStaticDtoFactory = {}

local CE_TYPE = HubCeTypes.RollingStockStatic
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
        nr = stock:getWagonNr(),
        trackType = stock:getTrackType(),
        hookStatus = stock:getHookStatus(),
        hookGlueMode = stock:getHookGlueMode()
    }
end

function RollingStockStaticDtoFactory.createDto(stock)
    local dto = toDto(stock)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockStaticDtoFactory.createRefDto(stockId)
    local dto = { ceType = CE_TYPE, id = stockId }
    return CE_TYPE, KEY_ID, stockId, dto
end

return RollingStockStaticDtoFactory
