-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockTexturesLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockTexturesDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TexturesDtoFactory = {}

local CE_TYPE = HubCeTypes.RollingStockTextures
local KEY_ID = "id"

local function copyTable(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[key] = value end
    return copy
end

local function toDto(stock)
    return {
        ceType = CE_TYPE,
        id = stock.rollingStockName,
        surfaceTexts = copyTable(stock:getTextureTexts())
    }
end

function TexturesDtoFactory.createDto(stock)
    local dto = toDto(stock)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TexturesDtoFactory.createDtoList(stocks)
    local dtos = {}
    for stockId, stock in pairs(stocks) do
        local _, _, _, dto = TexturesDtoFactory.createDto(stock)
        dtos[stockId] = dto
    end
    return CE_TYPE, KEY_ID, dtos
end

function TexturesDtoFactory.createRefDto(stockId)
    local dto = { ceType = CE_TYPE, id = stockId }
    return CE_TYPE, KEY_ID, stockId, dto
end

return TexturesDtoFactory
