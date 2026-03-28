-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/traffic-light-models/TrafficLightModelLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.mods.road.data.TrafficLightModelDtoFactory ...") end

local RoadCeTypes = require("ce.mods.road.data.RoadCeTypes")
local TrafficLightModelDtoFactory = {}

local CE_TYPE = RoadCeTypes.SignalTypeDefinition
local KEY_ID = "id"

local function toSignalTypeDefinitionPositionsDto(positions)
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

local function toSignalTypeDefinitionDto(definition)
    local positions = toSignalTypeDefinitionPositionsDto(definition.positions or {})
    return {
        ceType = CE_TYPE,
        id = definition.id,
        name = definition.name,
        type = definition.type,
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

function TrafficLightModelDtoFactory.createSignalTypeDefinitionDto(definition)
    local dto = toSignalTypeDefinitionDto(definition)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TrafficLightModelDtoFactory.createSignalTypeDefinitionDtoList(definitions)
    local dtos = {}
    for key, definition in pairs(definitions) do
        local _, _, _, dto = TrafficLightModelDtoFactory.createSignalTypeDefinitionDto(definition)
        dtos[key] = dto
    end
    return CE_TYPE, KEY_ID, dtos
end

return TrafficLightModelDtoFactory
