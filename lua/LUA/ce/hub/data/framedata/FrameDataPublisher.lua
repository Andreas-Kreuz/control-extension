if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local FrameDataDtoFactory = require("ce.hub.data.framedata.FrameDataDtoFactory")
local FrameDataRegistry = require("ce.hub.data.framedata.FrameDataRegistry")

local FrameDataPublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

function FrameDataPublisher.syncState()
    local frameData = FrameDataRegistry.get()
    if not frameData then return end

    if frameData.needsFullSend then
        DataChangeBus.fireDataChanged(FrameDataDtoFactory.createFullDto(frameData))
        frameData.needsFullSend = false
        frameData:resetDirty()
    elseif frameData:hasDirtyFields() then
        local ceType, keyId, key, dto = FrameDataDtoFactory.createPatchDto(frameData, frameData.dirtyFields)
        if hasPayloadFields(dto) then DataChangeBus.fireDataChanged(ceType, keyId, key, dto) end
        frameData:resetDirty()
    end
end

return FrameDataPublisher
