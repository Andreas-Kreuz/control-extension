 -- TypeScript LuaDto: apps/web-server/src/server/ce/dto/tracks/TrackLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.tracks.TrackDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TrackDtoFactory = {}

local KEY_ID = "id"
local TRACK_CE_TYPES = {
    auxiliary = HubCeTypes.AuxiliaryTrack,
    control = HubCeTypes.ControlTrack,
    road = HubCeTypes.RoadTrack,
    rail = HubCeTypes.RailTrack,
    tram = HubCeTypes.TramTrack
}
local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local function ceTypeForTrackType(trackType)
    local ceType = TRACK_CE_TYPES[trackType]
    assert(ceType, "unknown trackType: " .. tostring(trackType))
    return ceType
end

local function toTrackDto(trackType, track, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies(trackType .. "Tracks")
    local dto = {
        ceType = ceTypeForTrackType(trackType),
        id = track.id,
    }
    if SyncPolicy.shouldPublishField(fieldPolicies, "reserved", isSelected) then dto.reserved = track.reserved end
    if SyncPolicy.shouldPublishField(fieldPolicies, "reservedByTrainName", isSelected) then
        dto.reservedByTrainName = track.reservedByTrainName
    end
    return dto
end

function TrackDtoFactory.ceTypeForTrackType(trackType)
    return ceTypeForTrackType(trackType)
end

function TrackDtoFactory.createTrackDto(trackType, track, isSelected)
    local dto = toTrackDto(trackType, track, isSelected == true)
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
