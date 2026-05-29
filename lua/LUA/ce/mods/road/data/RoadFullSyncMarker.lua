if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadFullSyncMarker ...") end

local RoadFullSyncMarker = {}

function RoadFullSyncMarker.requestRoadFullSync()
    require("ce.mods.road.data.RoadPublisher").requestFullSync()
end

function RoadFullSyncMarker.requestTrafficLightModelFullSync()
    require("ce.mods.road.data.TrafficLightModelPublisher").requestFullSync()
end

function RoadFullSyncMarker.requestFullSync()
    RoadFullSyncMarker.requestRoadFullSync()
    RoadFullSyncMarker.requestTrafficLightModelFullSync()
end

return RoadFullSyncMarker
