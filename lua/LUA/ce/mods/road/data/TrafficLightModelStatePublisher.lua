if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.TrafficLightModelStatePublisher ...") end
local TrafficLightModelPublisher = require("ce.mods.road.data.TrafficLightModelPublisher")

---@class TrafficLightModelStatePublisher
TrafficLightModelStatePublisher = {}
local enabled = true
local initialized = false
TrafficLightModelStatePublisher.name = "ce.mods.road.data.TrafficLightModelStatePublisher"

function TrafficLightModelStatePublisher.initialize()
    if not enabled or initialized then return end
    initialized = true
end

function TrafficLightModelStatePublisher.syncState()
    if not enabled then return end
    if not initialized then TrafficLightModelStatePublisher.initialize() end

    TrafficLightModelPublisher.syncState()
end

return TrafficLightModelStatePublisher