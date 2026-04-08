-- TypeScript LuaDtos: apps/web-server/src/server/ce/dto/transit/
--   TransitStationLuaDto, TransitLineLuaDto, TransitLineSegmentLuaDto
if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitDtoFactory ...") end

local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitDtoFactory = {}

local function toTransitStationDto(station)
    return {
        ceType = TransitCeTypes.Station,
        id = station.id or station.name
    }
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

local function toTransitLineDto(line, ceType)
    local lineSegments = {}
    for _, lineSegment in pairs(line.lineSegments or {}) do
        table.insert(lineSegments, toTransitLineSegmentDto(lineSegment))
    end
    return {
        ceType = ceType,
        id = line.id or line.nr,
        nr = line.nr,
        trafficType = line.trafficType,
        lineSegments = lineSegments
    }
end

local function toTransitModuleSettingDto(setting)
    return {
        ceType = TransitCeTypes.ModuleSetting,
        category = setting.category,
        name = setting.name,
        description = setting.description,
        type = setting.type,
        value = setting.value,
        eepFunction = setting.eepFunction
    }
end

local function toTransitTrainDto(transitTrain)
    return {
        ceType = TransitCeTypes.TransitTrain,
        id = transitTrain.id,
        line = transitTrain.getLine and transitTrain:getLine() or transitTrain.line,
        destination = transitTrain.getDestination and transitTrain:getDestination() or transitTrain.destination,
        direction = transitTrain.getDirection and transitTrain:getDirection() or transitTrain.direction
    }
end

local function createDto(ceType, keyId, value, toDto)
    local dto = toDto(value, ceType)
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

function TransitDtoFactory.createStationDto(station)
    return createDto(TransitCeTypes.Station, "id", station, toTransitStationDto)
end

function TransitDtoFactory.createStationDtoList(stations)
    return createDtoList(TransitCeTypes.Station, "id", stations, TransitDtoFactory.createStationDto)
end

function TransitDtoFactory.createLineDto(line)
    return createDto(TransitCeTypes.Line, "id", line, toTransitLineDto)
end

function TransitDtoFactory.createLineDtoList(lines)
    return createDtoList(TransitCeTypes.Line, "id", lines, TransitDtoFactory.createLineDto)
end

function TransitDtoFactory.createModuleSettingDto(setting)
    return createDto(TransitCeTypes.ModuleSetting, "name", setting, toTransitModuleSettingDto)
end

function TransitDtoFactory.createModuleSettingDtoList(settings)
    return createDtoList(TransitCeTypes.ModuleSetting, "name", settings,
                         TransitDtoFactory.createModuleSettingDto)
end

function TransitDtoFactory.createLineNameDto(line)
    return createDto(TransitCeTypes.LineName, "id", line, toTransitLineDto)
end

function TransitDtoFactory.createLineNameDtoList(lines)
    return createDtoList(TransitCeTypes.LineName, "id", lines, TransitDtoFactory.createLineNameDto)
end

function TransitDtoFactory.createTransitTrainDto(transitTrain)
    return createDto(TransitCeTypes.TransitTrain, "id", transitTrain, toTransitTrainDto)
end

return TransitDtoFactory
