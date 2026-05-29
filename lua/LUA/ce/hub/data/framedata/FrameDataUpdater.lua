if CeDebugLoad then print("[#Start] Loading ce.hub.data.framedata.FrameDataUpdater ...") end

local FrameData = require("ce.hub.data.framedata.FrameData")
local FrameDataRegistry = require("ce.hub.data.framedata.FrameDataRegistry")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local FrameDataUpdater = {}
local FIELD_NAMES = { "framesPerSecond", "currentFrame", "currentRenderFrame" }

function FrameDataUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("frameData") then return end

    local frameData = FrameDataRegistry.get()
    local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.FrameData, "frameData")
    local fieldPolicies = HubOptionsRegistry.getFieldUpdatePolicies("frameData")
    local updatedFields = {}
    local shouldPull = frameData == nil
    for _, fieldName in ipairs(FIELD_NAMES) do
        if SyncPolicy.shouldUpdateField(fieldPolicies, fieldName, isSelected) then
            updatedFields[fieldName] = true
            shouldPull = true
        end
    end
    if not shouldPull then return end

    FrameDataRegistry.set({ FrameData.pullCurrent() }, frameData and updatedFields or nil)
end

return FrameDataUpdater
