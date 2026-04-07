if CeDebugLoad then print("[#Start] Loading ce.hub.data.tracks.TrackPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local TrackDtoFactory = require("ce.hub.data.tracks.TrackDtoFactory")
local TrackRegistry = require("ce.hub.data.tracks.TrackRegistry")
local TrackPublisher = {}

local aliases = {
    auxiliaryTracks = "auxiliary",
    controlTracks = "control",
    roadTracks = "road",
    railTracks = "rail",
    tramTracks = "tram"
}

function TrackPublisher.syncState()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")

    for alias, trackType in pairs(aliases) do
        if HubOptionsRegistry.isPublishEnabled(alias) then
            if TrackRegistry.isInitialListPending(trackType) then
                DataChangeBus.fireListChange(
                    TrackDtoFactory.createTrackDtoList(trackType, TrackRegistry.getAll(trackType), true)
                )
                TrackRegistry.clearInitialListPending(trackType)
            end

            for trackId in pairs(TrackRegistry.getChangedIds(trackType)) do
                local track = TrackRegistry.get(trackType, trackId)
                if track then
                    local isSelected = DynamicUpdateRegistry.isSelected(TrackDtoFactory.ceTypeForTrackType(trackType),
                                                                        tostring(track.id))
                    DataChangeBus.fireDataChanged(TrackDtoFactory.createTrackDto(trackType, track, isSelected))
                end
            end

            for _, track in pairs(TrackRegistry.getAll(trackType)) do
                local ceType = TrackDtoFactory.ceTypeForTrackType(trackType)
                local trackId = tostring(track.id)
                if DynamicUpdateRegistry.needsInitialSend(ceType, trackId) then
                    DataChangeBus.fireDataChanged(TrackDtoFactory.createTrackDto(trackType, track, true))
                    DynamicUpdateRegistry.markSent(ceType, trackId)
                end
            end
        end

        TrackRegistry.clearChanged(trackType)
    end

    return {}
end

return TrackPublisher
