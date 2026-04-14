if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitTrainPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")
local TransitTrainDtoFactory = require("ce.mods.transit.data.TransitTrainDtoFactory")
local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")

local TransitTrainPublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

function TransitTrainPublisher.syncState()
    if not TransitOptionsRegistry.isPublishEnabled("transitTrains") then
        TransitTrainRegistry.clearPendingChanges()
        return {}
    end

    for trainId in pairs(TransitTrainRegistry.getRemovedIds()) do
        DataChangeBus.fireDataRemoved(TransitTrainDtoFactory.createRefDto(trainId))
    end

    for _, transitTrain in pairs(TransitTrainRegistry.getAll()) do
        local isSelected = InterestSyncRegistry.isSelected(TransitCeTypes.TransitTrain, transitTrain.id)
        local needsInitialSend = InterestSyncRegistry.needsInitialSend(TransitCeTypes.TransitTrain, transitTrain.id)
        if transitTrain.needsFullSend or needsInitialSend then
            DataChangeBus.fireDataChanged(TransitTrainDtoFactory.createFullDto(transitTrain, isSelected))
            transitTrain.needsFullSend = false
            transitTrain:resetDirty()
            if isSelected then InterestSyncRegistry.markSent(TransitCeTypes.TransitTrain, transitTrain.id) end
        elseif transitTrain:hasDirtyFields() then
            local ceType, keyId, key, dto = TransitTrainDtoFactory.createPatchDto(transitTrain,
                                                                                  transitTrain.dirtyFields,
                                                                                  isSelected)
            if hasPayloadFields(dto) then
                DataChangeBus.fireDataChanged(ceType, keyId, key, dto)
            end
            transitTrain:resetDirty()
        end
    end

    TransitTrainRegistry.clearPendingChanges()
    return {}
end

return TransitTrainPublisher
