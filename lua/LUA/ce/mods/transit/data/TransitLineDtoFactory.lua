-- TypeScript LuaDtos: apps/web-server/src/server/ce/dto/transit/
--   TransitLineLuaDto, TransitLineSegmentLuaDto
if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitLineDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")

---@class TransitLineDtoFactory
---@field createLineSegmentDto fun(lineSegment: LineSegment|table):TransitLineSegmentDto
---@field createFullDto fun(line: Line|table, isSelected?: boolean):string,string,string|number,TransitLineDto
---@field createDtoList fun(lines: table, isSelectedByValue?: fun(value: table): boolean):string,string,table
---@field createLineNameFullDto fun(line: Line|table, isSelected?: boolean):string,string,string|number,TransitLineDto
---@field createLineNameDtoList fun(lines: table, isSelectedByValue?: fun(value: table): boolean):string,string,table
local TransitLineDtoFactory = {}

local KEY_ID = "id"

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

local function toTransitLineSegmentsDto(line)
    local lineSegments = {}
    for _, lineSegment in pairs(line.lineSegments or {}) do
        table.insert(lineSegments, toTransitLineSegmentDto(lineSegment))
    end
    return lineSegments
end

local dtoFields = {
    nr = {
        getValue = function (line) return line.nr end,
        placeholder = ""
    },
    trafficType = {
        getValue = function (line) return line.trafficType end,
        placeholder = ""
    },
    lineSegments = {
        getValue = toTransitLineSegmentsDto,
        placeholder = {}
    }
}

local function baseDto(line, ceType)
    return {
        ceType = ceType,
        id = line.id or line.nr
    }
end

local function buildFullDto(line, ceType, alias, isSelected)
    local fieldPolicies = TransitOptionsRegistry.getFieldPublishPolicies(alias)
    return DtoBuilder.buildFullDto(baseDto(line, ceType), line, dtoFields, fieldPolicies, isSelected)
end

local function createDto(ceType, alias, line, isSelected)
    local dto = buildFullDto(line, ceType, alias, isSelected == true)
    return ceType, KEY_ID, dto[KEY_ID], dto
end

local function createDtoList(ceType, values, createSingleDto, isSelectedByValue)
    local dtos = {}
    for key, value in pairs(values or {}) do
        local _, _, _, dto = createSingleDto(value, isSelectedByValue and isSelectedByValue(value) or false)
        dtos[key] = dto
    end
    return ceType, KEY_ID, dtos
end

function TransitLineDtoFactory.createLineSegmentDto(lineSegment)
    return toTransitLineSegmentDto(lineSegment)
end

function TransitLineDtoFactory.createFullDto(line, isSelected)
    return createDto(TransitCeTypes.Line, "lines", line, isSelected)
end

function TransitLineDtoFactory.createDtoList(lines, isSelectedByValue)
    return createDtoList(TransitCeTypes.Line, lines, TransitLineDtoFactory.createFullDto, isSelectedByValue)
end

function TransitLineDtoFactory.createLineNameFullDto(line, isSelected)
    return createDto(TransitCeTypes.LineName, "lineNames", line, isSelected)
end

function TransitLineDtoFactory.createLineNameDtoList(lines, isSelectedByValue)
    return createDtoList(TransitCeTypes.LineName, lines, TransitLineDtoFactory.createLineNameFullDto, isSelectedByValue)
end

return TransitLineDtoFactory
