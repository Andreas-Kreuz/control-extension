-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/traffic-light-models/TrafficLightModelLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.TrafficLightModelDtoFactory ...") end

local RoadCeTypes = require("ce.mods.road.data.RoadCeTypes")

---@class TrafficLightModelDtoFactory
---@field createTrafficLightModelDto fun(definition: table):string,string,string|number,TrafficLightModelDto
---@field createTrafficLightModelDtoList fun(definitions: table):string,string,table
local TrafficLightModelDtoFactory = {}

local CE_TYPE = RoadCeTypes.TrafficLightModel
local KEY_ID = "id"

local function toTrafficLightModelPositionsDto(positions)
    return {
        positionRed = positions.positionRed,
        positionGreen = positions.positionGreen,
        positionYellow = positions.positionYellow,
        positionRedYellow = positions.positionRedYellow,
        positionPedestrians = positions.positionPedestrians,
        positionOff = positions.positionOff,
        positionOffBlinking = positions.positionOffBlinking
    }
end

local function toTrafficLightModelDto(definition)
    local positions = toTrafficLightModelPositionsDto(definition.positions or {})
    return {
        ceType = CE_TYPE,
        id = definition.id,
        name = definition.name,
        type = definition.type,
        modelNamePatterns = definition.modelNamePatterns or {},
        modelNameMatchOrder = definition.modelNameMatchOrder,
        positionRed = positions.positionRed,
        positionGreen = positions.positionGreen,
        positionYellow = positions.positionYellow,
        positionRedYellow = positions.positionRedYellow,
        positionPedestrians = positions.positionPedestrians,
        positionOff = positions.positionOff,
        positionOffBlinking = positions.positionOffBlinking,
        positions = positions
    }
end

function TrafficLightModelDtoFactory.createTrafficLightModelDto(definition)
    local dto = toTrafficLightModelDto(definition)
    return CE_TYPE, KEY_ID, dto.id, dto
end

function TrafficLightModelDtoFactory.createTrafficLightModelDtoList(definitions)
    local dtos = {}
    for key, definition in pairs(definitions) do
        local _, _, _, dto = TrafficLightModelDtoFactory.createTrafficLightModelDto(definition)
        dtos[key] = dto
    end
    return CE_TYPE, KEY_ID, dtos
end

return TrafficLightModelDtoFactory
