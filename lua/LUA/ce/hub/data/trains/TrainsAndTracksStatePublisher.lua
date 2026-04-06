if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainsAndTracksStatePublisher ...") end
local TrainDetection = require("ce.hub.data.trains.TrainDetection")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

TrainsAndTracksStatePublisher = {}

TrainsAndTracksStatePublisher.enabled = true
local initialized = false
TrainsAndTracksStatePublisher.name = "ce.hub.data.trains.TrainsAndTracksStatePublisher"

TrainsAndTracksStatePublisher.options = {
    ceTypes = {
        train = { ceType = "ce.hub.Train", mode = "all" },
        rollingStock = { ceType = "ce.hub.RollingStock", mode = "all" },
        auxiliaryTrack = { ceType = "ce.hub.AuxiliaryTrack", mode = "all" },
        controlTrack = { ceType = "ce.hub.ControlTrack", mode = "all" },
        roadTrack = { ceType = "ce.hub.RoadTrack", mode = "all" },
        railTrack = { ceType = "ce.hub.RailTrack", mode = "all" },
        tramTrack = { ceType = "ce.hub.TramTrack", mode = "all" }
    }
}

local data = {}
local activeCeTypes = {}

local function rebuildActiveCeTypes()
    activeCeTypes = {}
    for _, ceTypeOptions in pairs(TrainsAndTracksStatePublisher.options.ceTypes) do
        if SyncPolicy.isActive(ceTypeOptions, ceTypeOptions.ceType == "ce.hub.Train"
                or ceTypeOptions.ceType == "ce.hub.RollingStock") then
            activeCeTypes[ceTypeOptions.ceType] = true
        end
    end
end

local function hasActiveCeType(...)
    for i = 1, select("#", ...) do
        if activeCeTypes[select(i, ...)] then return true end
    end
    return false
end

function TrainsAndTracksStatePublisher.initialize()
    if not TrainsAndTracksStatePublisher.enabled or initialized then return end
    rebuildActiveCeTypes()
    TrainDetection.initialize(activeCeTypes)

    initialized = true
end

function TrainsAndTracksStatePublisher.syncState()
    if not TrainsAndTracksStatePublisher.enabled then return end

    if not initialized then TrainsAndTracksStatePublisher.initialize() end
    rebuildActiveCeTypes()
    TrainDetection.update(activeCeTypes)

    if hasActiveCeType("ce.hub.Train") then
        TrainRegistry.fireChangeTrainEvents(TrainsAndTracksStatePublisher.options.ceTypes)
    end
    if hasActiveCeType("ce.hub.RollingStock") then
        RollingStockRegistry.fireChangeRollingStockEvents(TrainsAndTracksStatePublisher.options.ceTypes)
    end

    return data
end

return TrainsAndTracksStatePublisher
