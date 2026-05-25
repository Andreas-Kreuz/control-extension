-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/tracks/TrackLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.tracks.TrackDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local peek = DtoFieldAccess.peek
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

---@class TrackDtoFactory
---@field ceTypeForTrackType fun(trackType: string):string
---@field createTrackDto fun(trackType: string, track: table, isSelected: boolean|nil):string,string,
---string|number,TrackDto
---@field createTrackPatchDto fun(trackType: string, track: table, dirtyFields: table<string, boolean>,
---isSelected: boolean|nil):string,string,string|number,TrackDto
---@field createTrackDtoList fun(trackType: string, tracks: table, isSelected: boolean|nil):string,string,table
local TrackDtoFactory = {}

local KEY_ID = "id"
local TRACK_CE_TYPES = {
    auxiliary = HubCeTypes.AuxiliaryTrack,
    control = HubCeTypes.ControlTrack,
    road = HubCeTypes.RoadTrack,
    rail = HubCeTypes.RailTrack,
    tram = HubCeTypes.TramTrack
}

-- DtoFields: class definition in TrackDtoTypes.d.lua
local dtoFields = {
    reserved = {
        getValue = peek(function (source) return source:peekReserved() end, "reserved"),
        placeholder = false
    },
    reservedByTrainName = {
        getValue = peek(function (source) return source:peekReservedByTrainName() end, "reservedByTrainName"),
        placeholder = ""
    },
}

local function ceTypeForTrackType(trackType)
    local ceType = TRACK_CE_TYPES[trackType]
    assert(ceType, "unknown trackType: " .. tostring(trackType))
    return ceType
end

local function buildTrackDto(trackType, track, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies(trackType .. "Tracks")
    return DtoBuilder.buildFullDto({
                                       ceType = ceTypeForTrackType(trackType),
                                       id = track.id
                                   }, track, dtoFields, fieldPolicies, isSelected)
end

local function buildTrackPatchDto(trackType, track, dirtyFields, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies(trackType .. "Tracks")
    return DtoBuilder.buildPatchDto({
                                        ceType = ceTypeForTrackType(trackType),
                                        id = track.id
                                    }, track, dirtyFields, dtoFields, fieldPolicies, isSelected)
end

function TrackDtoFactory.ceTypeForTrackType(trackType)
    return ceTypeForTrackType(trackType)
end

function TrackDtoFactory.createTrackDto(trackType, track, isSelected)
    local dto = buildTrackDto(trackType, track, isSelected == true)
    return dto.ceType, KEY_ID, dto[KEY_ID], dto
end

function TrackDtoFactory.createTrackPatchDto(trackType, track, dirtyFields, isSelected)
    local dto = buildTrackPatchDto(trackType, track, dirtyFields, isSelected == true)
    return dto.ceType, KEY_ID, dto[KEY_ID], dto
end

function TrackDtoFactory.createTrackDtoList(trackType, tracks, isSelected)
    local trackDtos = {}
    for trackId, track in pairs(tracks) do
        local _, _, _, dto = TrackDtoFactory.createTrackDto(trackType, track, isSelected)
        trackDtos[trackId] = dto
    end
    return ceTypeForTrackType(trackType), KEY_ID, trackDtos
end

return TrackDtoFactory
