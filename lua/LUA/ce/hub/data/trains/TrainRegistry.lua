if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainRegistry ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local DynamicUpdateRegistry = require("ce.hub.data.dynamic.DynamicUpdateRegistry")
local Train = require("ce.hub.data.trains.Train")
local TrainDtoFactory = require("ce.hub.data.trains.TrainDtoFactory")
local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local TrainRegistry = {}
TrainRegistry.debug = AkStartWithDebug or false
---@type table<string, Train>
local allTrains = {}
---@type table<string,table<string,string>> table of trainName -> index(string) -> rollingstockname
local trainRollingStockNames = {}

function TrainRegistry.initRollingStock(train)
    trainRollingStockNames[train.name] = {}
    local count = EEPGetRollingstockItemsCount(train.name)
    train:setRollingStockCount(count)
    for i = 0, (count - 1) do
        local rollingStockName = EEPGetRollingstockItemName(train.name, i)
        RollingStockRegistry.forName(rollingStockName)
        trainRollingStockNames[train.name][tostring(i)] = rollingStockName
    end
end

function TrainRegistry.allRollingStockNamesOf(trainName)
    return trainRollingStockNames[trainName] and trainRollingStockNames[trainName] or {}
end

function TrainRegistry.rollingStockNameInTrain(name, index)
    return trainRollingStockNames[name] and trainRollingStockNames[name][tostring(index)] or nil
end

function TrainRegistry.forName(name)
    assert(name, "Provide a name for the train")
    assert(type(name) == "string", "Need 'trainName' as string")
    if allTrains[name] then
        return allTrains[name], false
    else
        local train = Train:new({ name = name })
        allTrains[train.name] = train
        TrainRegistry.initRollingStock(train)
        return train, true
    end
end

function TrainRegistry.trainAppeared(train)
    if TrainRegistry.debug then
        print(string.format("[#TrainRegistry] train created: %s (%s)", train:getName(), train:getTrackType()))
    end
end

function TrainRegistry.trainDisappeared(trainName)
    if TrainRegistry.debug then print(string.format("[#TrainRegistry] train removed: %s", trainName)) end
    allTrains[trainName] = nil
    trainRollingStockNames[trainName] = nil
    DataChangeBus.fireDataRemoved(TrainDtoFactory.createRefDto(trainName))
end

function TrainRegistry.fireChangeTrainEvents(ceTypeOptionsByAlias)
    local trainOptions = ceTypeOptionsByAlias and ceTypeOptionsByAlias["train"] or nil
    local mode = SyncPolicy.getMode(trainOptions, true)

    for _, train in pairs(allTrains) do
        local isSelected = DynamicUpdateRegistry.isSelected(HubCeTypes.Train, train.id)
        local needsInitialSend = DynamicUpdateRegistry.needsInitialSend(HubCeTypes.Train, train.id)
        local isSubscribed = mode == "all" or (mode == "selected" and isSelected)

        -- Handle subscription transitions: send full DTO or placeholder patch
        if train.needsFullSend or needsInitialSend then
            DataChangeBus.fireDataChanged(TrainDtoFactory.createFullDto(train, isSubscribed))
            train.needsFullSend = false
            train:resetDirty()
            if isSelected then DynamicUpdateRegistry.markSent(HubCeTypes.Train, train.id) end
        elseif train:hasDirtyFields() then
            local shouldSend = mode == "all"
                or (mode == "selected" and isSelected)
                or not train.dirtyFields.speed -- send non-ondemand dirty fields always
            if shouldSend then
                DataChangeBus.fireDataChanged(TrainDtoFactory.createPatchDto(train, train.dirtyFields, isSubscribed))
            end
            train:resetDirty()
        end
    end
end

function TrainRegistry.getAllTrainNames()
    local names = {}
    for trainName in pairs(allTrains) do names[trainName] = true end
    return names
end

return TrainRegistry
