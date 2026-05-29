if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.TrafficLightModelStatePublisher ...") end
local TrafficLightModelPublisher = require("ce.mods.road.data.TrafficLightModelPublisher")
local RoadFullSyncMarker = require("ce.mods.road.data.RoadFullSyncMarker")

---@class TrafficLightModelStatePublisher
local TrafficLightModelStatePublisher = {}
TrafficLightModelStatePublisher.enabled = true
local initialized = false
TrafficLightModelStatePublisher.name = "ce.mods.road.data.TrafficLightModelStatePublisher"
TrafficLightModelStatePublisher.ceTypes = require("ce.mods.road.data.RoadCeTypes").TrafficLightModel

function TrafficLightModelStatePublisher.initialize()
    if not TrafficLightModelStatePublisher.enabled or initialized then return end
    initialized = true
end

function TrafficLightModelStatePublisher.syncState()
    if not TrafficLightModelStatePublisher.enabled then return end
    if not initialized then TrafficLightModelStatePublisher.initialize() end

    TrafficLightModelPublisher.syncState()
end

function TrafficLightModelStatePublisher.requestFullSync()
    RoadFullSyncMarker.requestTrafficLightModelFullSync()
end

return TrafficLightModelStatePublisher
