-- TypeScript LuaDtos: apps/web-server/src/server/ce/dto/roads/
--   IntersectionLuaDto, IntersectionLaneLuaDto, IntersectionSwitchingLuaDto, IntersectionTrafficLightLuaDto
if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadDtoFactory ...") end

local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local RoadCeTypes = require("ce.mods.road.data.RoadCeTypes")
local RoadOptionsRegistry = require("ce.mods.road.options.RoadOptionsRegistry")
local RoadDtoFactory = {}

local function copyTable(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[key] = value end
    return copy
end

local function toIntersectionDto(intersection)
    local fieldPolicies = RoadOptionsRegistry.getFieldPublishPolicies("intersections")
    local isSelected = false
    local dto = {
        ceType = RoadCeTypes.Intersection,
        id = intersection.id,
    }
    dto.name             = SyncPolicy.shouldPublishField(fieldPolicies, "name", isSelected)             and intersection.name             or ""
    dto.currentSwitching = SyncPolicy.shouldPublishField(fieldPolicies, "currentSwitching", isSelected) and intersection.currentSwitching or ""
    dto.manualSwitching  = SyncPolicy.shouldPublishField(fieldPolicies, "manualSwitching", isSelected)  and intersection.manualSwitching  or ""
    dto.nextSwitching    = SyncPolicy.shouldPublishField(fieldPolicies, "nextSwitching", isSelected)    and intersection.nextSwitching    or ""
    dto.timeForGreen     = SyncPolicy.shouldPublishField(fieldPolicies, "timeForGreen", isSelected)     and intersection.timeForGreen     or 0
    dto.staticCams       = SyncPolicy.shouldPublishField(fieldPolicies, "staticCams", isSelected)       and copyTable(intersection.staticCams) or {}
    if SyncPolicy.shouldPublishField(fieldPolicies, "ready", isSelected) then
        dto.ready = intersection.ready
    else
        dto.ready = false
    end
    return dto
end

local function toIntersectionLaneDto(lane)
    local fieldPolicies = RoadOptionsRegistry.getFieldPublishPolicies("intersectionLanes")
    local isSelected = false
    local dto = {
        ceType = RoadCeTypes.IntersectionLane,
        id = lane.id,
    }
    dto.intersectionId            = SyncPolicy.shouldPublishField(fieldPolicies, "intersectionId", isSelected)            and lane.intersectionId            or 0
    dto.name                      = SyncPolicy.shouldPublishField(fieldPolicies, "name", isSelected)                      and lane.name                      or ""
    dto.phase                     = SyncPolicy.shouldPublishField(fieldPolicies, "phase", isSelected)                     and lane.phase                     or ""
    dto.vehicleMultiplier         = SyncPolicy.shouldPublishField(fieldPolicies, "vehicleMultiplier", isSelected)         and lane.vehicleMultiplier         or 0
    dto.eepSaveId                 = SyncPolicy.shouldPublishField(fieldPolicies, "eepSaveId", isSelected)                 and lane.eepSaveId                 or 0
    dto.type                      = SyncPolicy.shouldPublishField(fieldPolicies, "type", isSelected)                      and lane.type                      or ""
    dto.countType                 = SyncPolicy.shouldPublishField(fieldPolicies, "countType", isSelected)                 and lane.countType                 or ""
    dto.waitingTrains             = SyncPolicy.shouldPublishField(fieldPolicies, "waitingTrains", isSelected)             and copyTable(lane.waitingTrains)  or {}
    dto.waitingForGreenCyclesCount = SyncPolicy.shouldPublishField(fieldPolicies, "waitingForGreenCyclesCount", isSelected) and lane.waitingForGreenCyclesCount or 0
    dto.directions                = SyncPolicy.shouldPublishField(fieldPolicies, "directions", isSelected)                and copyTable(lane.directions)     or {}
    dto.switchings                = SyncPolicy.shouldPublishField(fieldPolicies, "switchings", isSelected)                and copyTable(lane.switchings)     or {}
    dto.tracks                    = SyncPolicy.shouldPublishField(fieldPolicies, "tracks", isSelected)                    and copyTable(lane.tracks)         or {}
    return dto
end

local function toIntersectionSwitchingDto(switching)
    local fieldPolicies = RoadOptionsRegistry.getFieldPublishPolicies("intersectionSwitchings")
    local isSelected = false
    local dto = {
        ceType = RoadCeTypes.IntersectionSwitching,
        id = switching.id,
    }
    dto.intersectionId = SyncPolicy.shouldPublishField(fieldPolicies, "intersectionId", isSelected) and switching.intersectionId or ""
    dto.name           = SyncPolicy.shouldPublishField(fieldPolicies, "name", isSelected)           and switching.name           or ""
    dto.prio           = SyncPolicy.shouldPublishField(fieldPolicies, "prio", isSelected)           and switching.prio           or 0
    return dto
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
    local fieldPolicies = RoadOptionsRegistry.getFieldPublishPolicies("intersectionTrafficLights")
    local isSelected = false
    local dto = {
        ceType = RoadCeTypes.IntersectionTrafficLight,
        id = trafficLight.id,
    }
    dto.signalId      = SyncPolicy.shouldPublishField(fieldPolicies, "signalId", isSelected)      and trafficLight.signalId      or 0
    dto.modelId       = SyncPolicy.shouldPublishField(fieldPolicies, "modelId", isSelected)       and trafficLight.modelId       or ""
    dto.currentPhase  = SyncPolicy.shouldPublishField(fieldPolicies, "currentPhase", isSelected)  and trafficLight.currentPhase  or ""
    dto.intersectionId = SyncPolicy.shouldPublishField(fieldPolicies, "intersectionId", isSelected) and trafficLight.intersectionId or 0
    if SyncPolicy.shouldPublishField(fieldPolicies, "lightStructures", isSelected) then
        local lightStructures = {}
        for key, lightStructure in pairs(trafficLight.lightStructures or {}) do
            lightStructures[key] = toIntersectionTrafficLightStructureDto(lightStructure)
        end
        dto.lightStructures = lightStructures
    else
        dto.lightStructures = {}
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "axisStructures", isSelected) then
        local axisStructures = {}
        for key, axisStructure in pairs(trafficLight.axisStructures or {}) do
            axisStructures[key] = toIntersectionTrafficLightAxisStructureDto(axisStructure)
        end
        dto.axisStructures = axisStructures
    else
        dto.axisStructures = {}
    end
    return dto
end

local function toIntersectionModuleSettingDto(setting)
    local fieldPolicies = RoadOptionsRegistry.getFieldPublishPolicies("moduleSettings")
    local isSelected = false
    local dto = {
        ceType = RoadCeTypes.ModuleSetting,
        name = setting.name,
    }
    dto.category    = SyncPolicy.shouldPublishField(fieldPolicies, "category", isSelected)    and setting.category    or ""
    dto.description = SyncPolicy.shouldPublishField(fieldPolicies, "description", isSelected) and setting.description or ""
    dto.eepFunction = SyncPolicy.shouldPublishField(fieldPolicies, "eepFunction", isSelected) and setting.eepFunction or ""
    dto.type        = SyncPolicy.shouldPublishField(fieldPolicies, "type", isSelected)        and setting.type        or ""
    if SyncPolicy.shouldPublishField(fieldPolicies, "value", isSelected) then
        dto.value = setting.value
    else
        dto.value = false
    end
    return dto
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
