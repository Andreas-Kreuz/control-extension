if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local FrameDataDtoFactory = require("ce.hub.data.framedata.FrameDataDtoFactory")
local FrameDataRegistry = require("ce.hub.data.framedata.FrameDataRegistry")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")

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

    local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.FrameData, tostring(frameData.id))
    local needsInitialSend = InterestSyncRegistry.needsInitialSend(HubCeTypes.FrameData, tostring(frameData.id))

    if frameData.needsFullSend or needsInitialSend then
        DataChangeBus.fireDataChanged(FrameDataDtoFactory.createFullDto(frameData, isSelected))
        frameData.needsFullSend = false
        frameData:resetDirty()
        if needsInitialSend then InterestSyncRegistry.markSent(HubCeTypes.FrameData, tostring(frameData.id)) end
    elseif frameData:hasDirtyFields() then
        local ceType, keyId, key, dto =
            FrameDataDtoFactory.createPatchDto(frameData, frameData.dirtyFields, isSelected)
        if hasPayloadFields(dto) then DataChangeBus.fireDataChanged(ceType, keyId, key, dto) end
        frameData:resetDirty()
    end
end

return FrameDataPublisher
