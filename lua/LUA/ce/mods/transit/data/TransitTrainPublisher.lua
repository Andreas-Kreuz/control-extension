if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitTrainPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")
local TransitTrainDtoFactory = require("ce.mods.transit.data.TransitTrainDtoFactory")
local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")

local TransitTrainPublisher = {}
local baselineSent = false
local needsFullBaseline = false
local sentTrainIds = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

local function createFullDto(transitTrain)
    local isSelected = InterestSyncRegistry.isSelected(TransitCeTypes.TransitTrain, transitTrain.id)
    local needsInitialSend = InterestSyncRegistry.needsInitialSend(TransitCeTypes.TransitTrain, transitTrain.id)
    local ceType, keyId, key, dto = TransitTrainDtoFactory.createFullDto(transitTrain, isSelected)
    return ceType, keyId, key, dto, isSelected, needsInitialSend
end

local function resetTransitTrainPublishState(transitTrain, isSelected, needsInitialSend)
    transitTrain.needsFullSend = false
    transitTrain:resetDirty()
    if isSelected or needsInitialSend then
        InterestSyncRegistry.markSent(TransitCeTypes.TransitTrain, transitTrain.id)
    end
    sentTrainIds[transitTrain.id] = true
end

local function publishBaseline(transitTrains)
    local list = {}
    sentTrainIds = {}

    for _, transitTrain in pairs(transitTrains) do
        local _, _, _, dto, isSelected, needsInitialSend = createFullDto(transitTrain)
        table.insert(list, dto)
        resetTransitTrainPublishState(transitTrain, isSelected, needsInitialSend)
    end

    DataChangeBus.fireListChange(TransitCeTypes.TransitTrain, "id", list)
    baselineSent = true
    needsFullBaseline = false
end

function TransitTrainPublisher.requestFullSync()
    needsFullBaseline = true
end

function TransitTrainPublisher.syncState()
    if not TransitOptionsRegistry.isPublishEnabled("transitTrains") then
        TransitTrainRegistry.clearPendingChanges()
        return
    end

    local transitTrains = TransitTrainRegistry.getAll()
    if needsFullBaseline or not baselineSent then
        publishBaseline(transitTrains)
        TransitTrainRegistry.clearPendingChanges()
        return
    end

    for trainId in pairs(TransitTrainRegistry.getRemovedIds()) do
        DataChangeBus.fireDataRemoved(TransitTrainDtoFactory.createRefDto(trainId))
        sentTrainIds[trainId] = nil
    end

    for _, transitTrain in pairs(transitTrains) do
        local isSelected = InterestSyncRegistry.isSelected(TransitCeTypes.TransitTrain, transitTrain.id)
        local needsInitialSend = InterestSyncRegistry.needsInitialSend(TransitCeTypes.TransitTrain, transitTrain.id)
        if not sentTrainIds[transitTrain.id] then
            local ceType, keyId, key, dto = TransitTrainDtoFactory.createFullDto(transitTrain, isSelected)
            DataChangeBus.fireDataAdded(ceType, keyId, key, dto)
            resetTransitTrainPublishState(transitTrain, isSelected, needsInitialSend)
        elseif transitTrain.needsFullSend or needsInitialSend then
            local ceType, keyId, key, dto = TransitTrainDtoFactory.createFullDto(transitTrain, isSelected)
            DataChangeBus.fireDataChanged(ceType, keyId, key, dto)
            resetTransitTrainPublishState(transitTrain, isSelected, needsInitialSend)
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
end

return TransitTrainPublisher
