-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/tracks/TrackLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.tracks.TrackDtoFactory ...") end

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

local function ceTypeForTrackType(trackType)
    local ceType = TRACK_CE_TYPES[trackType]
    assert(ceType, "unknown trackType: " .. tostring(trackType))
    return ceType
end

local function toTrackDto(trackType, track)
    return {
        ceType = ceTypeForTrackType(trackType),
        id = track.id,
        reserved = track.reserved,
        reservedByTrainName = track.reservedByTrainName
    }
end

function TrackDtoFactory.createTrackDto(trackType, track)
    local dto = toTrackDto(trackType, track)
    return dto.ceType, KEY_ID, dto[KEY_ID], dto
end

function TrackDtoFactory.createTrackDtoList(trackType, tracks)
    local trackDtos = {}
    for trackId, track in pairs(tracks) do
        local _, _, _, dto = TrackDtoFactory.createTrackDto(trackType, track)
        trackDtos[trackId] = dto
    end
    return ceTypeForTrackType(trackType), KEY_ID, trackDtos
end

return TrackDtoFactory
