-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockRotationLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockRotationDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RotationDtoFactory = {}

local CE_TYPE = HubCeTypes.RollingStockRotation
local KEY_ID = "id"

local function toDto(stock)
    return {
        ceType = CE_TYPE,
        id = stock.rollingStockName,
        rotX = stock:getRotX(),
        rotY = stock:getRotY(),
        rotZ = stock:getRotZ()
    }
end

function RotationDtoFactory.createDto(stock)
    local dto = toDto(stock)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RotationDtoFactory.createDtoList(stocks)
    local dtos = {}
    for stockId, stock in pairs(stocks) do
        local _, _, _, dto = RotationDtoFactory.createDto(stock)
        dtos[stockId] = dto
    end
    return CE_TYPE, KEY_ID, dtos
end

function RotationDtoFactory.createRefDto(stockId)
    local dto = { ceType = CE_TYPE, id = stockId }
    return CE_TYPE, KEY_ID, stockId, dto
end

return RotationDtoFactory
