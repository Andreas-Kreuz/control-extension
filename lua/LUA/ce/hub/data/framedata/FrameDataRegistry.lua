if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataRegistry ...") end

local FrameData = require("ce.hub.data.framedata.FrameData")

local FrameDataRegistry = {}

local frameData = nil

function FrameDataRegistry.set(value)
    local rawFrameData = value and value[1] or nil
    if not rawFrameData then
        frameData = nil
        return
    end

    if frameData then
        frameData:update(rawFrameData)
    else
        frameData = FrameData:new(rawFrameData)
    end
end

function FrameDataRegistry.get()
    return frameData
end

return FrameDataRegistry
