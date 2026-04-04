-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockDynamicLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockDynamicDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStockDynamicDtoFactory = {}

local CE_TYPE = HubCeTypes.RollingStockDynamic
local KEY_ID = "id"

-- ondemand fields use typed zero-value placeholders when isSubscribed is false
local function toDto(stock, isSubscribed)
    return {
        ceType = CE_TYPE,
        id = stock.rollingStockName,
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
    }
end

function RollingStockDynamicDtoFactory.createDto(stock, isSubscribed)
    if isSubscribed == nil then isSubscribed = true end
    local dto = toDto(stock, isSubscribed)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockDynamicDtoFactory.createRefDto(stockId)
    local dto = { ceType = CE_TYPE, id = stockId }
    return CE_TYPE, KEY_ID, stockId, dto
end

return RollingStockDynamicDtoFactory
