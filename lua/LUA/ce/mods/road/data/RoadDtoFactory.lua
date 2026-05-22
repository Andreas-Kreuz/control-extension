-- TypeScript LuaDtos: apps/web-server/src/server/ce/dto/roads/
--   IntersectionLuaDto, IntersectionLaneLuaDto, IntersectionPhaseLuaDto, IntersectionTrafficLightLuaDto
if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadDtoFactory ...") end

local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local RoadCeTypes = require("ce.mods.road.data.RoadCeTypes")
local RoadOptionsRegistry = require("ce.mods.road.options.RoadOptionsRegistry")

---@class RoadDtoFactory
---@field createIntersectionDto fun(intersection: table, isSelected?: boolean):string,string,string|number,IntersectionDto
---@field createIntersectionDtoList fun(intersections: table, isSelectedByValue?: fun(value: table): boolean):string,string,table
---@field createIntersectionLaneDto fun(lane: table, isSelected?: boolean):string,string,string|number,IntersectionLaneDto
---@field createIntersectionLaneDtoList fun(lanes: table, isSelectedByValue?: fun(value: table): boolean):string,string,table
---@field createIntersectionPhaseDto fun(phase: table, isSelected?: boolean):string,string,string|number,IntersectionPhaseDto
---@field createIntersectionPhaseDtoList fun(phases: table, isSelectedByValue?: fun(value: table): boolean):string,string,table
---@field createIntersectionTrafficLightDto fun(trafficLight: table, isSelected?: boolean):string,string,string|number,IntersectionTrafficLightDto
---@field createIntersectionTrafficLightDtoList fun(signals: table, isSelectedByValue?: fun(value: table): boolean):string,string,table
---@field createIntersectionModuleSettingDto fun(setting: table, isSelected?: boolean):string,string,string|number,IntersectionModuleSettingDto
---@field createIntersectionModuleSettingDtoList fun(settings: table, isSelectedByValue?: fun(value: table): boolean):string,string,table
local RoadDtoFactory = {}

local function copyTable(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[key] = value end
    return copy
end

local function copyPhases(phases)
    local copy = {}
    for key, phase in pairs(phases or {}) do
        local signalHeads = {}
        for tlKey, signalHead in pairs(phase.signalHeads or {}) do
            signalHeads[tlKey] = {
                signalId = signalHead.signalId,
                signalHeadKind = signalHead.signalHeadKind,
                signalHeadKey = signalHead.signalHeadKey,
                signalHeadName = signalHead.signalHeadName,
                type = signalHead.type,
                vehicleSignalHeadName = signalHead.vehicleSignalHeadName,
                pedestrianSignalHeadName = signalHead.pedestrianSignalHeadName,
                use = signalHead.use
            }
        end
        copy[key] = {
            id = phase.id,
            name = phase.name,
            order = phase.order,
            prio = phase.prio,
            greenTimeSeconds = phase.greenTimeSeconds,
            signalGroups = copyTable(phase.signalGroups),
            signalHeads = signalHeads
        }
    end
    return copy
end

local function copySignalGroupDefinitions(signalGroupDefinitions)
    local copy = {}
    for key, signalGroup in pairs(signalGroupDefinitions or {}) do
        copy[key] = {
            name = signalGroup.name,
            scriptVariableName = signalGroup.scriptVariableName,
            approach = signalGroup.approach,
            turnDirections = copyTable(signalGroup.turnDirections),
            trafficType = signalGroup.trafficType,
            signalIds = copyTable(signalGroup.signalIds),
            pedestrianCrossingNames = copyTable(signalGroup.pedestrianCrossingNames)
        }
    end
    return copy
end

local function copyPedestrianCrossings(pedestrianCrossings)
    local copy = {}
    for key, crossing in pairs(pedestrianCrossings or {}) do
        copy[key] = {
            name = crossing.name,
            scriptVariableName = crossing.scriptVariableName,
            approach = crossing.approach,
            signalGroups = copyTable(crossing.signalGroups)
        }
    end
    return copy
end

local function copyLaneRouteRules(routeRules)
    local copy = {}
    for key, routeRule in pairs(routeRules or {}) do
        copy[key] = {
            routeNames = copyTable(routeRule.routeNames),
            signalGroups = copyTable(routeRule.signalGroups),
            mode = routeRule.mode,
            showRequests = routeRule.showRequests == true
        }
    end
    return copy
end

local function toIntersectionDto(intersection, isSelected)
    local fieldPolicies        = RoadOptionsRegistry.getFieldPublishPolicies("intersections")
    local dto                  = {
        ceType = RoadCeTypes.Intersection,
        id = intersection.id,
    }
    dto.name                   = SyncPolicy.shouldPublishField(fieldPolicies, "name", isSelected) and intersection.name or
    ""
    dto.eepSaveId              = SyncPolicy.shouldPublishField(fieldPolicies, "eepSaveId", isSelected) and
        intersection.eepSaveId or -1
    dto.scriptVariableName     = SyncPolicy.shouldPublishField(fieldPolicies, "scriptVariableName", isSelected) and
        intersection.scriptVariableName or nil
    dto.currentPhase           = SyncPolicy.shouldPublishField(fieldPolicies, "currentPhase", isSelected) and
        intersection.currentPhase or ""
    dto.manualPhase            = SyncPolicy.shouldPublishField(fieldPolicies, "manualPhase", isSelected) and
        intersection.manualPhase or ""
    dto.nextPhase              = SyncPolicy.shouldPublishField(fieldPolicies, "nextPhase", isSelected) and
        intersection.nextPhase or ""
    dto.greenTimeSeconds       = SyncPolicy.shouldPublishField(fieldPolicies, "greenTimeSeconds", isSelected) and
        intersection.greenTimeSeconds or 0
    dto.switchInStrictOrder    = SyncPolicy.shouldPublishField(fieldPolicies, "switchInStrictOrder", isSelected) and
        intersection.switchInStrictOrder or false
    dto.tippStructure          = SyncPolicy.shouldPublishField(fieldPolicies, "tippStructure", isSelected) and
        intersection.tippStructure or nil
    dto.staticCams             = SyncPolicy.shouldPublishField(fieldPolicies, "staticCams", isSelected) and
        copyTable(intersection.staticCams) or {}
    dto.phases                 = SyncPolicy.shouldPublishField(fieldPolicies, "phases", isSelected) and
        copyPhases(intersection.phases) or {}
    dto.signalGroupDefinitions = SyncPolicy.shouldPublishField(fieldPolicies, "signalGroupDefinitions", isSelected) and
        copySignalGroupDefinitions(intersection.signalGroupDefinitions) or {}
    dto.pedestrianCrossings    = SyncPolicy.shouldPublishField(fieldPolicies, "pedestrianCrossings", isSelected) and
        copyPedestrianCrossings(intersection.pedestrianCrossings) or {}
    if SyncPolicy.shouldPublishField(fieldPolicies, "ready", isSelected) then
        dto.ready = intersection.ready
    else
        dto.ready = false
    end
    return dto
end

local function toIntersectionLaneDto(lane, isSelected)
    local fieldPolicies            = RoadOptionsRegistry.getFieldPublishPolicies("intersectionLanes")
    local dto                      = {
        ceType = RoadCeTypes.IntersectionLane,
        id = lane.id,
    }
    dto.intersectionId             = SyncPolicy.shouldPublishField(fieldPolicies, "intersectionId", isSelected) and
        lane.intersectionId or 0
    dto.name                       = SyncPolicy.shouldPublishField(fieldPolicies, "name", isSelected) and
        lane.name or ""
    dto.kpId                       = lane.kpId or nil
    dto.scriptVariableName         = SyncPolicy.shouldPublishField(fieldPolicies, "scriptVariableName", isSelected) and
        lane.kpId or nil
    dto.currentIndication          = SyncPolicy.shouldPublishField(fieldPolicies, "currentIndication", isSelected) and
        lane.currentIndication or
        ""
    dto.vehicleMultiplier          = SyncPolicy.shouldPublishField(fieldPolicies, "vehicleMultiplier", isSelected) and
        lane.vehicleMultiplier or 0
    dto.laneSignalId               = SyncPolicy.shouldPublishField(fieldPolicies, "laneSignalId", isSelected) and
        lane.laneSignalId or nil
    dto.type                       = SyncPolicy.shouldPublishField(fieldPolicies, "type", isSelected) and
        lane.type or ""
    dto.countType                  = SyncPolicy.shouldPublishField(fieldPolicies, "countType", isSelected) and
        lane.countType or ""
    dto.waitingTrains              = SyncPolicy.shouldPublishField(fieldPolicies, "waitingTrains", isSelected) and
        copyTable(lane.waitingTrains) or {}
    dto.waitingForGreenCyclesCount = SyncPolicy.shouldPublishField(fieldPolicies, "waitingForGreenCyclesCount",
                                                                   isSelected) and lane.waitingForGreenCyclesCount or 0
    dto.approach                   = SyncPolicy.shouldPublishField(fieldPolicies, "approach", isSelected) and
        lane.approach or nil
    dto.directions                 = SyncPolicy.shouldPublishField(fieldPolicies, "directions", isSelected) and
        copyTable(lane.directions) or {}
    dto.phases                     = SyncPolicy.shouldPublishField(fieldPolicies, "phases", isSelected) and
        copyTable(lane.phases) or {}
    dto.defaultSignalGroups        = SyncPolicy.shouldPublishField(fieldPolicies, "defaultSignalGroups", isSelected) and
        copyTable(lane.defaultSignalGroups) or {}
    dto.routeRules                 = SyncPolicy.shouldPublishField(fieldPolicies, "routeRules", isSelected) and
        copyLaneRouteRules(lane.routeRules) or {}
    dto.defaultRequestSignalGroups = SyncPolicy.shouldPublishField(fieldPolicies, "defaultRequestSignalGroups",
                                                                   isSelected) and
        copyTable(lane.defaultRequestSignalGroups) or {}
    dto.requestTrackIds            = SyncPolicy.shouldPublishField(fieldPolicies, "requestTrackIds", isSelected) and
        copyTable(lane.requestTrackIds) or {}
    dto.highlightTrackIds          = SyncPolicy.shouldPublishField(fieldPolicies, "highlightTrackIds", isSelected) and
        copyTable(lane.highlightTrackIds) or {}
    dto.tracks                     = SyncPolicy.shouldPublishField(fieldPolicies, "tracks", isSelected) and
        copyTable(lane.tracks) or {}
    return dto
end

local function toIntersectionPhaseDto(phase, isSelected)
    local fieldPolicies = RoadOptionsRegistry.getFieldPublishPolicies("intersectionPhases")
    local dto           = {
        ceType = RoadCeTypes.IntersectionPhase,
        id = phase.id,
    }
    dto.intersectionId  = SyncPolicy.shouldPublishField(fieldPolicies, "intersectionId", isSelected) and
        phase.intersectionId or ""
    dto.name            = SyncPolicy.shouldPublishField(fieldPolicies, "name", isSelected) and phase.name or ""
    dto.prio            = SyncPolicy.shouldPublishField(fieldPolicies, "prio", isSelected) and phase.prio or 0
    return dto
end

local function toIntersectionTrafficLightStructureDto(lightStructure)
    return {
        structureRed = lightStructure.structureRed,
        structureGreen = lightStructure.structureGreen,
        structureYellow = lightStructure.structureYellow,
        structureRequest = lightStructure.structureRequest,
        structureHousing = lightStructure.structureHousing,
        structureBlend = lightStructure.structureBlend
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

local function toIntersectionTrafficLightDto(signal, isSelected)
    local fieldPolicies      = RoadOptionsRegistry.getFieldPublishPolicies("intersectionTrafficLights")
    local dto                = {
        ceType = RoadCeTypes.IntersectionTrafficLight,
        id = signal.id,
    }
    dto.signalId             = SyncPolicy.shouldPublishField(fieldPolicies, "signalId", isSelected) and
        signal.signalId or 0
    dto.vehicleSignalName    = SyncPolicy.shouldPublishField(fieldPolicies, "vehicleSignalName", isSelected) and
        signal.vehicleSignalName or ""
    dto.pedestrianSignalName = SyncPolicy.shouldPublishField(fieldPolicies, "pedestrianSignalName", isSelected) and
        signal.pedestrianSignalName or ""
    dto.use                  = SyncPolicy.shouldPublishField(fieldPolicies, "use", isSelected) and
        signal.use or ""
    dto.modelId              = SyncPolicy.shouldPublishField(fieldPolicies, "modelId", isSelected) and
        signal.modelId or ""
    dto.currentIndication    = SyncPolicy.shouldPublishField(fieldPolicies, "currentIndication", isSelected) and
        signal.currentIndication or ""
    dto.intersectionId       = SyncPolicy.shouldPublishField(fieldPolicies, "intersectionId", isSelected) and
        signal.intersectionId or 0
    if SyncPolicy.shouldPublishField(fieldPolicies, "lightStructures", isSelected) then
        local lightStructures = {}
        for key, lightStructure in pairs(signal.lightStructures or {}) do
            lightStructures[key] = toIntersectionTrafficLightStructureDto(lightStructure)
        end
        dto.lightStructures = lightStructures
    else
        dto.lightStructures = {}
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "axisStructures", isSelected) then
        local axisStructures = {}
        for key, axisStructure in pairs(signal.axisStructures or {}) do
            axisStructures[key] = toIntersectionTrafficLightAxisStructureDto(axisStructure)
        end
        dto.axisStructures = axisStructures
    else
        dto.axisStructures = {}
    end
    return dto
end

local function toIntersectionModuleSettingDto(setting, isSelected)
    local fieldPolicies = RoadOptionsRegistry.getFieldPublishPolicies("moduleSettings")
    local dto           = {
        ceType = RoadCeTypes.ModuleSetting,
        name = setting.name,
    }
    dto.category        = SyncPolicy.shouldPublishField(fieldPolicies, "category", isSelected) and
        setting.category or ""
    dto.description     = SyncPolicy.shouldPublishField(fieldPolicies, "description", isSelected) and setting
        .description or ""
    dto.eepFunction     = SyncPolicy.shouldPublishField(fieldPolicies, "eepFunction", isSelected) and setting
        .eepFunction or ""
    dto.type            = SyncPolicy.shouldPublishField(fieldPolicies, "type", isSelected) and setting.type or ""
    if SyncPolicy.shouldPublishField(fieldPolicies, "value", isSelected) then
        dto.value = setting.value
    else
        dto.value = false
    end
    return dto
end

local function createDto(ceType, keyId, value, toDto, isSelected)
    local dto = toDto(value, isSelected == true)
    return ceType, keyId, dto[keyId], dto
end

local function createDtoList(ceType, keyId, values, createSingleDto, isSelectedByValue)
    local dtos = {}
    for key, value in pairs(values) do
        local _, _, _, dto = createSingleDto(value, isSelectedByValue and isSelectedByValue(value) or false)
        dtos[key] = dto
    end
    return ceType, keyId, dtos
end

function RoadDtoFactory.createIntersectionDto(intersection, isSelected)
    return createDto(RoadCeTypes.Intersection, "id", intersection, toIntersectionDto, isSelected)
end

function RoadDtoFactory.createIntersectionDtoList(intersections, isSelectedByValue)
    return createDtoList(RoadCeTypes.Intersection, "id", intersections, RoadDtoFactory.createIntersectionDto,
                         isSelectedByValue)
end

function RoadDtoFactory.createIntersectionLaneDto(lane, isSelected)
    return createDto(RoadCeTypes.IntersectionLane, "id", lane, toIntersectionLaneDto, isSelected)
end

function RoadDtoFactory.createIntersectionLaneDtoList(lanes, isSelectedByValue)
    return createDtoList(RoadCeTypes.IntersectionLane, "id", lanes, RoadDtoFactory.createIntersectionLaneDto,
                         isSelectedByValue)
end

function RoadDtoFactory.createIntersectionPhaseDto(phase, isSelected)
    return createDto(RoadCeTypes.IntersectionPhase, "id", phase, toIntersectionPhaseDto, isSelected)
end

function RoadDtoFactory.createIntersectionPhaseDtoList(phases, isSelectedByValue)
    return createDtoList(RoadCeTypes.IntersectionPhase, "id", phases,
                         RoadDtoFactory.createIntersectionPhaseDto, isSelectedByValue)
end

function RoadDtoFactory.createIntersectionTrafficLightDto(signal, isSelected)
    return createDto(RoadCeTypes.IntersectionTrafficLight, "id", signal, toIntersectionTrafficLightDto,
                     isSelected)
end

function RoadDtoFactory.createIntersectionTrafficLightDtoList(signals, isSelectedByValue)
    return createDtoList(RoadCeTypes.IntersectionTrafficLight, "id", signals,
                         RoadDtoFactory.createIntersectionTrafficLightDto, isSelectedByValue)
end

function RoadDtoFactory.createIntersectionModuleSettingDto(setting, isSelected)
    return createDto(RoadCeTypes.ModuleSetting, "name", setting, toIntersectionModuleSettingDto, isSelected)
end

function RoadDtoFactory.createIntersectionModuleSettingDtoList(settings, isSelectedByValue)
    return createDtoList(RoadCeTypes.ModuleSetting, "name", settings,
                         RoadDtoFactory.createIntersectionModuleSettingDto, isSelectedByValue)
end

return RoadDtoFactory
