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

local function shouldInclude(fieldOptions, fieldName)
    local field = fieldOptions and fieldOptions[fieldName] or nil
    return field == nil or field.collect ~= false
end

local function ceTypeForTrackType(trackType)
    local ceType = TRACK_CE_TYPES[trackType]
    assert(ceType, "unknown trackType: " .. tostring(trackType))
    return ceType
end

local function toTrackDto(trackType, track, fieldOptions)
    local dto = {
        ceType = ceTypeForTrackType(trackType),
        id = track.id,
    }
    if shouldInclude(fieldOptions, "reserved") then dto.reserved = track.reserved end
    if shouldInclude(fieldOptions, "reservedByTrainName") then dto.reservedByTrainName = track.reservedByTrainName end
    return dto
end

function TrackDtoFactory.createTrackDto(trackType, track, fieldOptions)
    local dto = toTrackDto(trackType, track, fieldOptions)
    return dto.ceType, KEY_ID, dto[KEY_ID], dto
end

function TrackDtoFactory.createTrackDtoList(trackType, tracks, fieldOptions)
    local trackDtos = {}
    for trackId, track in pairs(tracks) do
        local _, _, _, dto = TrackDtoFactory.createTrackDto(trackType, track, fieldOptions)
        trackDtos[trackId] = dto
    end
    return ceTypeForTrackType(trackType), KEY_ID, trackDtos
end

return TrackDtoFactory
