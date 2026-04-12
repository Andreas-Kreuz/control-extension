-- TypeScript LuaDtos: apps/web-server/src/server/ce/dto/transit/
--   TransitStationLuaDto, TransitLineLuaDto, TransitLineSegmentLuaDto
if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitDtoFactory ...") end

local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")
local TransitDtoFactory = {}

local function buildPlatformsDto(routePlatforms)
    local byNr = {}
    for route, assignment in pairs(routePlatforms or {}) do
        local nr = assignment.platform
        if nr then
            byNr[nr] = byNr[nr] or { nr = nr, routes = {} }
            table.insert(byNr[nr].routes, route)
        end
    end
    local result = {}
    for _, platformDto in pairs(byNr) do
        table.sort(platformDto.routes)
        table.insert(result, platformDto)
    end
    table.sort(result, function (a, b) return a.nr < b.nr end)
    return result
end

local function buildQueueDto(queue)
    local entries = queue:getTrainEntries()
    local result = {}
    for _, entry in ipairs(entries) do
        table.insert(result, {
            trainName = entry.trainName,
            line = entry.line,
            destination = entry.destination,
            timeInMinutes = entry.timeInMinutes,
            platform = entry.platform
        })
    end
    return result
end

local function toTransitStationDto(station, isSelected)
    local fieldPolicies = TransitOptionsRegistry.getFieldPublishPolicies("stations")
    local dto = {
        ceType = TransitCeTypes.Station,
        id = station.name,
        name = station.name,
    }
    if SyncPolicy.shouldPublishField(fieldPolicies, "platforms", isSelected) then
        dto.platforms = buildPlatformsDto(station.routePlatforms)
    else
        dto.platforms = {}
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "queue", isSelected) then
        dto.queue = buildQueueDto(station.queue)
    else
        dto.queue = {}
    end
    return dto
end

local function toTransitLineSegmentStationDto(stationInfo)
    local station = stationInfo.station or {}
    return {
        station = {
            name = station.name
        },
        timeToStation = stationInfo.timeToStation
    }
end

local function toTransitLineSegmentDto(lineSegment)
    local stations = {}
    local stationInfos = lineSegment.stationInfos or lineSegment.stations or {}
    for _, stationInfo in pairs(stationInfos) do
        table.insert(stations, toTransitLineSegmentStationDto(stationInfo))
    end
    return {
        id = lineSegment.id,
        destination = lineSegment.destination,
        routeName = lineSegment.routeName,
        lineNr = lineSegment.lineNr or (lineSegment.line and lineSegment.line.nr),
        stations = stations
    }
end

local function toTransitLineDto(line, ceType, isSelected)
    local alias = (ceType == TransitCeTypes.LineName) and "lineNames" or "lines"
    local fieldPolicies = TransitOptionsRegistry.getFieldPublishPolicies(alias)
    local dto = {
        ceType = ceType,
        id = line.id or line.nr,
    }
    if SyncPolicy.shouldPublishField(fieldPolicies, "nr", isSelected) then
        dto.nr = line.nr
    else
        dto.nr = ""
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "trafficType", isSelected) then
        dto.trafficType = line.trafficType
    else
        dto.trafficType = ""
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "lineSegments", isSelected) then
        local lineSegments = {}
        for _, lineSegment in pairs(line.lineSegments or {}) do
            table.insert(lineSegments, toTransitLineSegmentDto(lineSegment))
        end
        dto.lineSegments = lineSegments
    else
        dto.lineSegments = {}
    end
    return dto
end

local function toTransitModuleSettingDto(setting, _, isSelected)
    local fieldPolicies = TransitOptionsRegistry.getFieldPublishPolicies("moduleSettings")
    local dto           = {
        ceType = TransitCeTypes.ModuleSetting,
        name = setting.name,
    }
    dto.category        = SyncPolicy.shouldPublishField(fieldPolicies, "category", isSelected)
        and setting.category or ""
    dto.description     = SyncPolicy.shouldPublishField(fieldPolicies, "description", isSelected)
        and setting.description or
    ""
    dto.eepFunction     = SyncPolicy.shouldPublishField(fieldPolicies, "eepFunction", isSelected)
        and setting.eepFunction or
    ""
    dto.type            = SyncPolicy.shouldPublishField(fieldPolicies, "type", isSelected) and setting.type or ""
    if SyncPolicy.shouldPublishField(fieldPolicies, "value", isSelected) then
        dto.value = setting.value
    else
        dto.value = false
    end
    return dto
end

local function toTransitTrainDto(transitTrain, _, isSelected)
    local fieldPolicies = TransitOptionsRegistry.getFieldPublishPolicies("transitTrains")
    local dto           = {
        ceType = TransitCeTypes.TransitTrain,
        id = transitTrain.id,
    }
    dto.line            = SyncPolicy.shouldPublishField(fieldPolicies, "line", isSelected)
        and (transitTrain.getLine and transitTrain:getLine() or transitTrain.line) or ""
    dto.destination     = SyncPolicy.shouldPublishField(fieldPolicies, "destination", isSelected)
        and (transitTrain.getDestination and transitTrain:getDestination() or transitTrain.destination) or ""
    dto.direction       = SyncPolicy.shouldPublishField(fieldPolicies, "direction", isSelected)
        and (transitTrain.getDirection and transitTrain:getDirection() or transitTrain.direction) or ""
    return dto
end

local function createDto(ceType, keyId, value, toDto, isSelected)
    local dto = toDto(value, ceType, isSelected == true)
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

function TransitDtoFactory.createStationDto(station, isSelected)
    local dto = toTransitStationDto(station, isSelected == true)
    return TransitCeTypes.Station, "id", dto.id, dto
end

function TransitDtoFactory.createStationDtoList(stations)
    return createDtoList(TransitCeTypes.Station, "id", stations, TransitDtoFactory.createStationDto)
end

function TransitDtoFactory.createLineDto(line, isSelected)
    return createDto(TransitCeTypes.Line, "id", line, toTransitLineDto, isSelected)
end

function TransitDtoFactory.createLineDtoList(lines, isSelectedByValue)
    return createDtoList(TransitCeTypes.Line, "id", lines, TransitDtoFactory.createLineDto, isSelectedByValue)
end

function TransitDtoFactory.createModuleSettingDto(setting, isSelected)
    return createDto(TransitCeTypes.ModuleSetting, "name", setting, toTransitModuleSettingDto, isSelected)
end

function TransitDtoFactory.createModuleSettingDtoList(settings, isSelectedByValue)
    return createDtoList(TransitCeTypes.ModuleSetting, "name", settings,
                         TransitDtoFactory.createModuleSettingDto, isSelectedByValue)
end

function TransitDtoFactory.createLineNameDto(line, isSelected)
    return createDto(TransitCeTypes.LineName, "id", line, toTransitLineDto, isSelected)
end

function TransitDtoFactory.createLineNameDtoList(lines, isSelectedByValue)
    return createDtoList(TransitCeTypes.LineName, "id", lines, TransitDtoFactory.createLineNameDto, isSelectedByValue)
end

function TransitDtoFactory.createTransitTrainDto(transitTrain, isSelected)
    return createDto(TransitCeTypes.TransitTrain, "id", transitTrain, toTransitTrainDto, isSelected)
end

return TransitDtoFactory
