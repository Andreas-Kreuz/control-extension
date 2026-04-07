if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataRegistry ...") end

local FrameDataRegistry = {}

local entries = nil

function FrameDataRegistry.set(value)
    entries = value
end

function FrameDataRegistry.get()
    return entries
end

return FrameDataRegistry
