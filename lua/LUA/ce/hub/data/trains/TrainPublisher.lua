if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TrainDtoFactory = require("ce.hub.data.trains.TrainDtoFactory")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

local TrainPublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

function TrainPublisher.syncState()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

    if not HubOptionsRegistry.isPublishEnabled("trains") then
        TrainRegistry.clearPendingChanges()
        return {}
    end

    for trainId in pairs(TrainRegistry.getRemovedIds()) do
        DataChangeBus.fireDataRemoved(TrainDtoFactory.createRefDto(trainId))
    end

    for _, train in pairs(TrainRegistry.getAll()) do
        local isSelected = DynamicUpdateRegistry.isSelected(HubCeTypes.Train, train.id)
        local needsInitialSend = DynamicUpdateRegistry.needsInitialSend(HubCeTypes.Train, train.id)

        if train.needsFullSend or needsInitialSend then
            DataChangeBus.fireDataChanged(TrainDtoFactory.createFullDto(train, isSelected))
            train.needsFullSend = false
            train:resetDirty()
            if isSelected then DynamicUpdateRegistry.markSent(HubCeTypes.Train, train.id) end
        elseif train:hasDirtyFields() then
            local ceType, keyId, key, dto = TrainDtoFactory.createPatchDto(train, train.dirtyFields, isSelected)
            if hasPayloadFields(dto) then
                DataChangeBus.fireDataChanged(ceType, keyId, key, dto)
            end
            train:resetDirty()
        end
    end

    TrainRegistry.clearPendingChanges()
    return {}
end

return TrainPublisher
