-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockDynamicLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockDynamicDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStockDynamicDtoFactory = {}

local CE_TYPE = HubCeTypes.RollingStockDynamic
local KEY_ID = "id"

local function toDto(stock)
    return {
        ceType = CE_TYPE,
        id = stock.rollingStockName,
        trackId = stock:getTrackId(),
        trackDistance = stock:getTrackDistance(),
        trackDirection = stock:getTrackDirection(),
        trackSystem = stock:getTrackSystem(),
        posX = stock:getX(),
        posY = stock:getY(),
        posZ = stock:getZ(),
        mileage = stock:getMileage(),
        orientationForward = stock:getOrientationForward(),
        smoke = stock:getSmoke(),
        active = stock:getActive()
    }
end

function RollingStockDynamicDtoFactory.createDto(stock)
    local dto = toDto(stock)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockDynamicDtoFactory.createRefDto(stockId)
    local dto = { ceType = CE_TYPE, id = stockId }
    return CE_TYPE, KEY_ID, stockId, dto
end

return RollingStockDynamicDtoFactory
