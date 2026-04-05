if AkDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataStatePublisher ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local FrameDataDtoFactory = require("ce.hub.data.framedata.FrameDataDtoFactory")

FrameDataStatePublisher = {}
local enabled = true
local initialized = false
FrameDataStatePublisher.name = "ce.hub.data.framedata.FrameDataStatePublisher"

FrameDataStatePublisher.options = {
    sendFrameData = true
}

function FrameDataStatePublisher.initialize()
    if not enabled or initialized then return end

    initialized = true
end

function FrameDataStatePublisher.syncState()
    if not enabled then return end
    if not initialized then FrameDataStatePublisher.initialize() end

    local entries = {
        {
            id = "frameData",
            framesPerSecond = EEPGetFramesPerSecond and EEPGetFramesPerSecond() or nil,
            currentFrame = EEPGetCurrentFrame and EEPGetCurrentFrame() or nil,
            currentRenderFrame = EEPGetCurrentRenderFrame and EEPGetCurrentRenderFrame() or nil,
        }
    }

    DataChangeBus.fireListChange(FrameDataDtoFactory.createFrameDataDtoList(entries))
    return {}
end

return FrameDataStatePublisher
