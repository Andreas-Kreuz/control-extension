if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataUpdater ...") end

local FrameDataRegistry = require("ce.hub.data.framedata.FrameDataRegistry")

local FrameDataUpdater = {}

function FrameDataUpdater.runUpdate()
    FrameDataRegistry.set({
        {
            id = "frameData",
            framesPerSecond = EEPGetFramesPerSecond and EEPGetFramesPerSecond() or nil,
            currentFrame = EEPGetCurrentFrame and EEPGetCurrentFrame() or nil,
            currentRenderFrame = EEPGetCurrentRenderFrame and EEPGetCurrentRenderFrame() or nil,
        }
    })
end

return FrameDataUpdater
