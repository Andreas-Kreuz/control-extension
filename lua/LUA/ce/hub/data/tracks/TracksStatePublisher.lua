if CeDebugLoad then print("[#Start] Loading ce.hub.data.tracks.TracksStatePublisher ...") end
local TrackPublisher = require("ce.hub.data.tracks.TrackPublisher")

local TracksStatePublisher = {}
TracksStatePublisher.enabled = true
local initialized = false
TracksStatePublisher.name = "ce.hub.data.tracks.TracksStatePublisher"
TracksStatePublisher.ceTypes =
    require("ce.hub.data.HubCeTypes").AuxiliaryTrack .. "," ..
    require("ce.hub.data.HubCeTypes").ControlTrack .. "," ..
    require("ce.hub.data.HubCeTypes").RoadTrack .. "," ..
    require("ce.hub.data.HubCeTypes").RailTrack .. "," ..
    require("ce.hub.data.HubCeTypes").TramTrack

function TracksStatePublisher.initialize()
    if not TracksStatePublisher.enabled or initialized then return end
    initialized = true
end

function TracksStatePublisher.syncState()
    if not TracksStatePublisher.enabled then return end
    if not initialized then TracksStatePublisher.initialize() end
    return TrackPublisher.syncState()
end

return TracksStatePublisher
