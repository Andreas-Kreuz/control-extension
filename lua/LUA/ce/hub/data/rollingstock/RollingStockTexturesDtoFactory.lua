-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockTexturesLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockTexturesDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStockTexturesDtoFactory = {}

local CE_TYPE = HubCeTypes.RollingStockTextures
local KEY_ID = "id"

local function copyTable(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[key] = value end
    return copy
end

local function toRollingStockTexturesDto(rollingStock)
    return {
        ceType = CE_TYPE,
        id = rollingStock.rollingStockName,
        surfaceTexts = copyTable(rollingStock:getTextureTexts())
    }
end

function RollingStockTexturesDtoFactory.createRollingStockTexturesDto(rollingStock)
    local dto = toRollingStockTexturesDto(rollingStock)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockTexturesDtoFactory.createRollingStockTexturesDtoList(rollingStocks)
    local rollingStockDtos = {}
    for rollingStockId, rollingStock in pairs(rollingStocks) do
        local _, _, _, dto = RollingStockTexturesDtoFactory.createRollingStockTexturesDto(rollingStock)
        rollingStockDtos[rollingStockId] = dto
    end
    return CE_TYPE, KEY_ID, rollingStockDtos
end

function RollingStockTexturesDtoFactory.createRollingStockTexturesReferenceDto(rollingStockId)
    local dto = { ceType = CE_TYPE, id = rollingStockId }
    return CE_TYPE, KEY_ID, rollingStockId, dto
end

return RollingStockTexturesDtoFactory
