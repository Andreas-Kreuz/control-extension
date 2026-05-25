if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataUpdater ...") end

local FrameData = require("ce.hub.data.framedata.FrameData")
local FrameDataRegistry = require("ce.hub.data.framedata.FrameDataRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local FrameDataUpdater = {}

function FrameDataUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("frameData") then return end
    FrameDataRegistry.set({ FrameData.pullCurrent() })
end

return FrameDataUpdater
