if AkDebugLoad then print("[#Start] Loading ce.hub.data.tracks.TracksStatePublisher ...") end
local TrainDetection = require("ce.hub.data.trains.TrainDetection")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local TracksStatePublisher = {}
TracksStatePublisher.enabled = true
local initialized = false
TracksStatePublisher.name = "ce.hub.data.tracks.TracksStatePublisher"

TracksStatePublisher.options = {
    ceTypes = {
        auxiliaryTrack = { ceType = "ce.hub.AuxiliaryTrack", mode = "selected" },
        controlTrack = { ceType = "ce.hub.ControlTrack", mode = "selected" },
        roadTrack = { ceType = "ce.hub.RoadTrack", mode = "selected" },
        railTrack = { ceType = "ce.hub.RailTrack", mode = "selected" },
        tramTrack = { ceType = "ce.hub.TramTrack", mode = "selected" }
    },
    fields = {
        reserved = { collect = true },
        reservedByTrainName = { collect = true }
    }
}

local activeCeTypes = {}

local function rebuildActiveCeTypes()
    activeCeTypes = {}
    for _, ceTypeOptions in pairs(TracksStatePublisher.options.ceTypes) do
        if SyncPolicy.isActive(ceTypeOptions, false) then
            activeCeTypes[ceTypeOptions.ceType] = true
        end
    end
end

function TracksStatePublisher.initialize()
    if not TracksStatePublisher.enabled or initialized then return end
    rebuildActiveCeTypes()
    TrainDetection.initialize(activeCeTypes, TracksStatePublisher.options.fields)
    initialized = true
end

function TracksStatePublisher.syncState()
    if not TracksStatePublisher.enabled then return end
    if not initialized then TracksStatePublisher.initialize() end
    rebuildActiveCeTypes()
    TrainDetection.update(activeCeTypes, TracksStatePublisher.options.fields)
    return {}
end

return TracksStatePublisher
