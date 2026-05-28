if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadStatePublisher ...") end
local RoadPublisher = require("ce.mods.road.data.RoadPublisher")

---@class RoadStatePublisher
RoadStatePublisher = {}
local enabled = true
local initialized = false
RoadStatePublisher.name = "ce.mods.road.data.RoadStatePublisher"

function RoadStatePublisher.initialize()
    if not enabled or initialized then return end
    initialized = true
end

function RoadStatePublisher.syncState()
    if not enabled then return end
    if not initialized then RoadStatePublisher.initialize() end

    RoadPublisher.syncState()
end

function RoadStatePublisher.requestFullSync()
    if RoadPublisher.requestFullSync then RoadPublisher.requestFullSync() end
end

return RoadStatePublisher
