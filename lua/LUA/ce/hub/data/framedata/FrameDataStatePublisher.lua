if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataStatePublisher ...") end
local FrameDataPublisher = require("ce.hub.data.framedata.FrameDataPublisher")

FrameDataStatePublisher = {}
FrameDataStatePublisher.enabled = true
local initialized = false
FrameDataStatePublisher.name = "ce.hub.data.framedata.FrameDataStatePublisher"
FrameDataStatePublisher.ceTypes = require("ce.hub.data.HubCeTypes").FrameData

function FrameDataStatePublisher.initialize()
    if not FrameDataStatePublisher.enabled or initialized then return end

    initialized = true
end

function FrameDataStatePublisher.syncState()
    if not FrameDataStatePublisher.enabled then return end
    if not initialized then FrameDataStatePublisher.initialize() end
    return FrameDataPublisher.syncState()
end

return FrameDataStatePublisher
