if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local TrainDtoFactory = require("ce.hub.data.trains.TrainDtoFactory")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

local TrainPublisher = {}

function TrainPublisher.syncState(options)
    local opts = options or {}
    local trainOptions = opts.ceTypes and opts.ceTypes.train or nil
    local mode = SyncPolicy.getMode(trainOptions, true)
    local fieldOptions = opts.fields or {}

    for trainId in pairs(TrainRegistry.getRemovedIds()) do
        DataChangeBus.fireDataRemoved(TrainDtoFactory.createRefDto(trainId))
    end

    for _, train in pairs(TrainRegistry.getAll()) do
        local isSelected = DynamicUpdateRegistry.isSelected(HubCeTypes.Train, train.id)
        local needsInitialSend = DynamicUpdateRegistry.needsInitialSend(HubCeTypes.Train, train.id)
        local isSubscribed = mode == "all" or (mode == "selected" and isSelected)

        if train.needsFullSend or needsInitialSend then
            DataChangeBus.fireDataChanged(TrainDtoFactory.createFullDto(train, isSubscribed, fieldOptions))
            train.needsFullSend = false
            train:resetDirty()
            if isSelected then DynamicUpdateRegistry.markSent(HubCeTypes.Train, train.id) end
        elseif train:hasDirtyFields() then
            local shouldSend = mode == "all"
                or (mode == "selected" and isSelected)
                or not train.dirtyFields.speed
            if shouldSend then
                DataChangeBus.fireDataChanged(TrainDtoFactory.createPatchDto(train, train.dirtyFields, isSubscribed,
                                                                             fieldOptions))
            end
            train:resetDirty()
        end
    end

    TrainRegistry.clearPendingChanges()
    return {}
end

return TrainPublisher
