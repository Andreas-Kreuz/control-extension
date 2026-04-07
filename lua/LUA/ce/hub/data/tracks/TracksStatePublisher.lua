if CeDebugLoad then print("[#Start] Loading ce.hub.data.tracks.TracksStatePublisher ...") end
local TrackPublisher = require("ce.hub.data.tracks.TrackPublisher")

local TracksStatePublisher = {}
TracksStatePublisher.enabled = true
local initialized = false
TracksStatePublisher.name = "ce.hub.data.tracks.TracksStatePublisher"

TracksStatePublisher.options = {
    ceTypes = {
        auxiliaryTracks = { ceType = "ce.hub.AuxiliaryTrack", mode = "selected" },
        controlTracks = { ceType = "ce.hub.ControlTrack", mode = "selected" },
        roadTracks = { ceType = "ce.hub.RoadTrack", mode = "selected" },
        railTracks = { ceType = "ce.hub.RailTrack", mode = "selected" },
        tramTracks = { ceType = "ce.hub.TramTrack", mode = "selected" }
    },
    fields = {
        reserved = { collect = true },
        reservedByTrainName = { collect = true }
    }
}

function TracksStatePublisher.initialize()
    if not TracksStatePublisher.enabled or initialized then return end
    initialized = true
end

function TracksStatePublisher.syncState()
    if not TracksStatePublisher.enabled then return end
    if not initialized then TracksStatePublisher.initialize() end
    return TrackPublisher.syncState(TracksStatePublisher.options)
end

return TracksStatePublisher
