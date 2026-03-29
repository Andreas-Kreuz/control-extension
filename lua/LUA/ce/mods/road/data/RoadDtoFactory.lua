-- TypeScript LuaDtos: apps/web-server/src/server/ce/dto/roads/
--   IntersectionLuaDto, IntersectionLaneLuaDto, IntersectionSwitchingLuaDto, IntersectionTrafficLightLuaDto
if AkDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadDtoFactory ...") end

local RoadCeTypes = require("ce.mods.road.data.RoadCeTypes")
local RoadDtoFactory = {}

local function copyTable(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[key] = value end
    return copy
end

local function toIntersectionDto(intersection)
    return {
        ceType = RoadCeTypes.Intersection,
        id = intersection.id,
        name = intersection.name,
        currentSwitching = intersection.currentSwitching,
        manualSwitching = intersection.manualSwitching,
        nextSwitching = intersection.nextSwitching,
        ready = intersection.ready,
        timeForGreen = intersection.timeForGreen,
        staticCams = copyTable(intersection.staticCams)
    }
end

local function toIntersectionLaneDto(lane)
    return {
        ceType = RoadCeTypes.IntersectionLane,
        id = lane.id,
        intersectionId = lane.intersectionId,
        name = lane.name,
        phase = lane.phase,
        vehicleMultiplier = lane.vehicleMultiplier,
        eepSaveId = lane.eepSaveId,
        type = lane.type,
        countType = lane.countType,
        waitingTrains = copyTable(lane.waitingTrains),
        waitingForGreenCyclesCount = lane.waitingForGreenCyclesCount,
        directions = copyTable(lane.directions),
        switchings = copyTable(lane.switchings),
        tracks = copyTable(lane.tracks)
    }
end

local function toIntersectionSwitchingDto(switching)
    return {
        ceType = RoadCeTypes.IntersectionSwitching,
        id = switching.id,
        intersectionId = switching.intersectionId,
        name = switching.name,
        prio = switching.prio
    }
end

local function toIntersectionTrafficLightStructureDto(lightStructure)
    return {
        structureRed = lightStructure.structureRed,
        structureGreen = lightStructure.structureGreen,
        structureYellow = lightStructure.structureYellow,
        structureRequest = lightStructure.structureRequest
    }
end

local function toIntersectionTrafficLightAxisStructureDto(axisStructure)
    return {
        structureName = axisStructure.structureName,
        axisName = axisStructure.axisName,
        positionDefault = axisStructure.positionDefault,
        positionRed = axisStructure.positionRed,
        positionGreen = axisStructure.positionGreen,
        positionYellow = axisStructure.positionYellow,
        positionPedestrian = axisStructure.positionPedestrian,
        positionRedYellow = axisStructure.positionRedYellow
    }
end

local function toIntersectionTrafficLightDto(trafficLight)
    local lightStructures = {}
    for key, lightStructure in pairs(trafficLight.lightStructures or {}) do
        lightStructures[key] = toIntersectionTrafficLightStructureDto(lightStructure)
    end

    local axisStructures = {}
    for key, axisStructure in pairs(trafficLight.axisStructures or {}) do
        axisStructures[key] = toIntersectionTrafficLightAxisStructureDto(axisStructure)
    end

    return {
        ceType = RoadCeTypes.IntersectionTrafficLight,
        id = trafficLight.id,
        signalId = trafficLight.signalId,
        modelId = trafficLight.modelId,
        currentPhase = trafficLight.currentPhase,
        intersectionId = trafficLight.intersectionId,
        lightStructures = lightStructures,
        axisStructures = axisStructures
    }
end

local function toIntersectionModuleSettingDto(setting)
    return {
        ceType = RoadCeTypes.ModuleSetting,
        category = setting.category,
        name = setting.name,
        description = setting.description,
        type = setting.type,
        value = setting.value,
        eepFunction = setting.eepFunction
    }
end

local function createDto(ceType, keyId, value, toDto)
    local dto = toDto(value)
    return ceType, keyId, dto[keyId], dto
end

local function createDtoList(ceType, keyId, values, createSingleDto)
    local dtos = {}
    for key, value in pairs(values) do
        local _, _, _, dto = createSingleDto(value)
        dtos[key] = dto
    end
    return ceType, keyId, dtos
end

function RoadDtoFactory.createIntersectionDto(intersection)
    return createDto(RoadCeTypes.Intersection, "id", intersection, toIntersectionDto)
end

function RoadDtoFactory.createIntersectionDtoList(intersections)
    return createDtoList(RoadCeTypes.Intersection, "id", intersections, RoadDtoFactory.createIntersectionDto)
end

function RoadDtoFactory.createIntersectionLaneDto(lane)
    return createDto(RoadCeTypes.IntersectionLane, "id", lane, toIntersectionLaneDto)
end

function RoadDtoFactory.createIntersectionLaneDtoList(lanes)
    return createDtoList(RoadCeTypes.IntersectionLane, "id", lanes, RoadDtoFactory.createIntersectionLaneDto)
end

function RoadDtoFactory.createIntersectionSwitchingDto(switching)
    return createDto(RoadCeTypes.IntersectionSwitching, "id", switching, toIntersectionSwitchingDto)
end

function RoadDtoFactory.createIntersectionSwitchingDtoList(switchings)
    return createDtoList(RoadCeTypes.IntersectionSwitching, "id", switchings,
                         RoadDtoFactory.createIntersectionSwitchingDto)
end

function RoadDtoFactory.createIntersectionTrafficLightDto(trafficLight)
    return createDto(RoadCeTypes.IntersectionTrafficLight, "id", trafficLight, toIntersectionTrafficLightDto)
end

function RoadDtoFactory.createIntersectionTrafficLightDtoList(trafficLights)
    return createDtoList(RoadCeTypes.IntersectionTrafficLight, "id", trafficLights,
                         RoadDtoFactory.createIntersectionTrafficLightDto)
end

function RoadDtoFactory.createIntersectionModuleSettingDto(setting)
    return createDto(RoadCeTypes.ModuleSetting, "name", setting, toIntersectionModuleSettingDto)
end

function RoadDtoFactory.createIntersectionModuleSettingDtoList(settings)
    return createDtoList(RoadCeTypes.ModuleSetting, "name", settings,
                         RoadDtoFactory.createIntersectionModuleSettingDto)
end

return RoadDtoFactory
