if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local FrameDataDtoFactory = require("ce.hub.data.framedata.FrameDataDtoFactory")
local FrameDataRegistry = require("ce.hub.data.framedata.FrameDataRegistry")

local FrameDataPublisher = {}

function FrameDataPublisher.syncState()
    DataChangeBus.fireListChange(FrameDataDtoFactory.createFrameDataDtoList(FrameDataRegistry.get() or {}))
    return {}
end

return FrameDataPublisher
