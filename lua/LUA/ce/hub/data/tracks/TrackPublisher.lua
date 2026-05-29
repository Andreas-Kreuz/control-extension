if CeDebugLoad then print("[#Start] Loading ce.hub.data.tracks.TrackPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local TrackDtoFactory = require("ce.hub.data.tracks.TrackDtoFactory")
local TrackRegistry = require("ce.hub.data.tracks.TrackRegistry")

---@class TrackPublisher
---@field syncState fun(options: table|nil):nil
local TrackPublisher = {}

local aliases = {
    auxiliaryTracks = "auxiliary",
    controlTracks = "control",
    roadTracks = "road",
    railTracks = "rail",
    tramTracks = "tram"
}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

function TrackPublisher.syncState()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")

    for alias, trackType in pairs(aliases) do
        if HubOptionsRegistry.isPublishEnabled(alias) then
            for _, track in pairs(TrackRegistry.getAll(trackType)) do
                local ceType = TrackDtoFactory.ceTypeForTrackType(trackType)
                local trackId = tostring(track.id)
                local isSelected = InterestSyncRegistry.isSelected(ceType, trackId)
                local needsInitialSend = InterestSyncRegistry.needsInitialSend(ceType, trackId)
                if not TrackRegistry.isInitialListPending(trackType) and
                    (track.needsFullSend or needsInitialSend) then
                    DataChangeBus.fireDataChanged(TrackDtoFactory.createTrackDto(trackType, track, true))
                    InterestSyncRegistry.markSent(ceType, trackId)
                    track.needsFullSend = false
                    track:resetDirty()
                elseif track:hasDirtyFields() then
                    local dtoCeType, keyId, key, dto = TrackDtoFactory.createTrackPatchDto(trackType, track,
                                                                                           track.dirtyFields,
                                                                                           isSelected)
                    if hasPayloadFields(dto) then DataChangeBus.fireDataChanged(dtoCeType, keyId, key, dto) end
                    track:resetDirty()
                end
            end

            if TrackRegistry.isInitialListPending(trackType) then
                local ceType, keyId, list = TrackDtoFactory.createTrackDtoList(trackType,
                                                                               TrackRegistry.getAll(trackType),
                                                                               true)
                DataChangeBus.fireListChange(ceType, keyId, list)
                for _, track in pairs(TrackRegistry.getAll(trackType)) do
                    InterestSyncRegistry.markSent(TrackDtoFactory.ceTypeForTrackType(trackType), tostring(track.id))
                    track.needsFullSend = false
                    track:resetDirty()
                end
            end

            TrackRegistry.clearInitialListPending(trackType)
        end

        TrackRegistry.clearChanged(trackType)
    end
end

return TrackPublisher
