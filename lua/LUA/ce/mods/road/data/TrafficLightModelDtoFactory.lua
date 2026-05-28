-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/traffic-light-models/TrafficLightModelLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.TrafficLightModelDtoFactory ...") end

local RoadCeTypes = require("ce.mods.road.data.RoadCeTypes")
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

---@class TrafficLightModelDtoFactory
---@field createTrafficLightModelDto fun(definition: table):string,string,string|number,TrafficLightModelDto
---@field createTrafficLightModelDtoList fun(definitions: table):string,string,table
---@field createTrafficLightModelDtoListFromModels fun():string,string,table
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

function TrafficLightModelDtoFactory.createTrafficLightModelDtoListFromModels()
    local trafficLightModels = {}
    for _, model in ipairs(TrafficLightModel.getAllOrdered()) do
        table.insert(trafficLightModels, {
            id = model.id,
            name = model.name,
            type = "road",
            modelNamePatterns = model.modelNamePatterns or {},
            modelNameMatchOrder = model.modelNameMatchOrder,
            positions = {
                positionRed = model.signalIndexRed,
                positionGreen = model.signalIndexGreen,
                positionYellow = model.signalIndexYellow,
                positionRedYellow = model.signalIndexRedYellow,
                positionPedestrians = model.signalIndexPedestrian,
                positionOff = model.signalIndexSwitchOff,
                positionOffBlinking = model.signalIndexBlinkYellow
            }
        })
    end
    return TrafficLightModelDtoFactory.createTrafficLightModelDtoList(trafficLightModels)
end

return TrafficLightModelDtoFactory