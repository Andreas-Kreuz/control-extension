if CeDebugLoad then print("[#Start] Loading ce.hub.data.time.TimeUpdater ...") end

local TimeData = require("ce.hub.data.time.TimeData")
local TimeRegistry = require("ce.hub.data.time.TimeRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local TimeUpdater = {}

function TimeUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("time") then return end
    TimeRegistry.set({ TimeData.pullCurrent() })
end

return TimeUpdater
