if CeDebugLoad then print("[#Start] Loading ce.hub.data.tracks.TrackPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local TrackDtoFactory = require("ce.hub.data.tracks.TrackDtoFactory")
local TrackRegistry = require("ce.hub.data.tracks.TrackRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local TrackPublisher = {}

local aliases = {
    auxiliaryTrack = "auxiliary",
    controlTrack = "control",
    roadTrack = "road",
    railTrack = "rail",
    tramTrack = "tram"
}

function TrackPublisher.syncState(options)
    local opts = options or {}
    local ceTypes = opts.ceTypes or {}
    local fields = opts.fields or {}

    for alias, trackType in pairs(aliases) do
        if SyncPolicy.isActive(ceTypes[alias], false) then
            if TrackRegistry.isInitialListPending(trackType) then
                DataChangeBus.fireListChange(
                    TrackDtoFactory.createTrackDtoList(trackType, TrackRegistry.getAll(trackType), fields)
                )
                TrackRegistry.clearInitialListPending(trackType)
            end

            for trackId in pairs(TrackRegistry.getChangedIds(trackType)) do
                local track = TrackRegistry.get(trackType, trackId)
                if track then
                    DataChangeBus.fireDataChanged(TrackDtoFactory.createTrackDto(trackType, track, fields))
                end
            end
        end

        TrackRegistry.clearChanged(trackType)
    end

    return {}
end

return TrackPublisher
