-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/rolling-stocks/RollingStockRotationLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockRotationDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStockRotationDtoFactory = {}

local CE_TYPE = HubCeTypes.RollingStockRotation
local KEY_ID = "id"

local function toRollingStockRotationDto(rollingStock)
    return {
        ceType = CE_TYPE,
        id = rollingStock.rollingStockName,
        rotX = rollingStock:getRotX(),
        rotY = rollingStock:getRotY(),
        rotZ = rollingStock:getRotZ()
    }
end

function RollingStockRotationDtoFactory.createRollingStockRotationDto(rollingStock)
    local dto = toRollingStockRotationDto(rollingStock)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function RollingStockRotationDtoFactory.createRollingStockRotationDtoList(rollingStocks)
    local rollingStockDtos = {}
    for rollingStockId, rollingStock in pairs(rollingStocks) do
        local _, _, _, dto = RollingStockRotationDtoFactory.createRollingStockRotationDto(rollingStock)
        rollingStockDtos[rollingStockId] = dto
    end
    return CE_TYPE, KEY_ID, rollingStockDtos
end

function RollingStockRotationDtoFactory.createRollingStockRotationReferenceDto(rollingStockId)
    local dto = { ceType = CE_TYPE, id = rollingStockId }
    return CE_TYPE, KEY_ID, rollingStockId, dto
end

return RollingStockRotationDtoFactory
