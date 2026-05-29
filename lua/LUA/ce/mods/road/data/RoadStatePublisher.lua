if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadStatePublisher ...") end
local RoadPublisher = require("ce.mods.road.data.RoadPublisher")
local RoadFullSyncMarker = require("ce.mods.road.data.RoadFullSyncMarker")

---@class RoadStatePublisher
local RoadStatePublisher = {}
RoadStatePublisher.enabled = true
local initialized = false
RoadStatePublisher.name = "ce.mods.road.data.RoadStatePublisher"
RoadStatePublisher.ceTypes =
    require("ce.mods.road.data.RoadCeTypes").Intersection .. "," ..
    require("ce.mods.road.data.RoadCeTypes").IntersectionLane .. "," ..
    require("ce.mods.road.data.RoadCeTypes").IntersectionPhase .. "," ..
    require("ce.mods.road.data.RoadCeTypes").IntersectionTrafficLight .. "," ..
    require("ce.mods.road.data.RoadCeTypes").ModuleSetting

function RoadStatePublisher.initialize()
    if not RoadStatePublisher.enabled or initialized then return end
    initialized = true
end

function RoadStatePublisher.syncState()
    if not RoadStatePublisher.enabled then return end
    if not initialized then RoadStatePublisher.initialize() end

    RoadPublisher.syncState()
end

function RoadStatePublisher.requestFullSync()
    RoadFullSyncMarker.requestRoadFullSync()
end

return RoadStatePublisher
