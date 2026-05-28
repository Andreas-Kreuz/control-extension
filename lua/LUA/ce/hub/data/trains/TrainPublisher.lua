if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TrainDtoFactory = require("ce.hub.data.trains.TrainDtoFactory")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

local TrainPublisher = {}
local baselineSent = false
local sentTrainIds = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

local function createFullDto(train)
    local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Train, train.id)
    local needsInitialSend = InterestSyncRegistry.needsInitialSend(HubCeTypes.Train, train.id)
    local ceType, keyId, key, dto = TrainDtoFactory.createFullDto(train, isSelected)
    return ceType, keyId, key, dto, isSelected, needsInitialSend
end

local function resetTrainPublishState(train, isSelected, needsInitialSend)
    train.needsFullSend = false
    train:resetDirty()
    if isSelected or needsInitialSend then InterestSyncRegistry.markSent(HubCeTypes.Train, train.id) end
    sentTrainIds[train.id] = true
end

local function publishBaseline(trains)
    local list = {}
    sentTrainIds = {}

    for _, train in pairs(trains) do
        local _, _, _, dto, isSelected, needsInitialSend = createFullDto(train)
        table.insert(list, dto)
        resetTrainPublishState(train, isSelected, needsInitialSend)
    end

    DataChangeBus.fireListChange(HubCeTypes.Train, "id", list)
    baselineSent = true
end

local function allTrainsNeedFullSend(trains)
    local hasTrain = false
    for _, train in pairs(trains) do
        hasTrain = true
        if not train.needsFullSend then return false end
    end
    return hasTrain
end

function TrainPublisher.syncState()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

    if not HubOptionsRegistry.isPublishEnabled("trains") then
        TrainRegistry.clearPendingChanges()
        return
    end

    local trains = TrainRegistry.getAll()
    if not baselineSent or allTrainsNeedFullSend(trains) then
        publishBaseline(trains)
        TrainRegistry.clearPendingChanges()
        return
    end

    for trainId in pairs(TrainRegistry.getRemovedIds()) do
        DataChangeBus.fireDataRemoved(TrainDtoFactory.createRemovalDto(trainId))
        sentTrainIds[trainId] = nil
    end

    for _, train in pairs(trains) do
        local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Train, train.id)
        local needsInitialSend = InterestSyncRegistry.needsInitialSend(HubCeTypes.Train, train.id)

        if not sentTrainIds[train.id] then
            local ceType, keyId, key, dto = TrainDtoFactory.createFullDto(train, isSelected)
            DataChangeBus.fireDataAdded(ceType, keyId, key, dto)
            resetTrainPublishState(train, isSelected, needsInitialSend)
        elseif train.needsFullSend or needsInitialSend then
            local ceType, keyId, key, dto = TrainDtoFactory.createFullDto(train, isSelected)
            DataChangeBus.fireDataChanged(ceType, keyId, key, dto)
            resetTrainPublishState(train, isSelected, needsInitialSend)
        elseif train:hasDirtyFields() then
            local ceType, keyId, key, dto = TrainDtoFactory.createPatchDto(train, train.dirtyFields, isSelected)
            if hasPayloadFields(dto) then
                DataChangeBus.fireDataChanged(ceType, keyId, key, dto)
            end
            train:resetDirty()
        end
    end

    TrainRegistry.clearPendingChanges()
end

return TrainPublisher
