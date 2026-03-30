if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainRegistry ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local DynamicUpdateRegistry = require("ce.hub.data.dynamic.DynamicUpdateRegistry")
local Train = require("ce.hub.data.trains.Train")
local TrainStaticDtoFactory = require("ce.hub.data.trains.TrainStaticDtoFactory")
local TrainDynamicDtoFactory = require("ce.hub.data.trains.TrainDynamicDtoFactory")
local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")

local TrainRegistry = {}
TrainRegistry.debug = AkStartWithDebug or false
---@type table<string, Train>
local allTrains = {}
---@type table<string,table<string,string>> table of trainName -> index(string) -> rollingstockname
local trainRollingStockNames = {}

local function isSelected(selectedCeTypes, ceType)
    if not selectedCeTypes or next(selectedCeTypes) == nil then return true end
    return selectedCeTypes[ceType] == true
end

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
    DataChangeBus.fireDataRemoved(TrainStaticDtoFactory.createRefDto(trainName))
    DataChangeBus.fireDataRemoved(TrainDynamicDtoFactory.createRefDto(trainName))
end

function TrainRegistry.fireChangeTrainEvents(selectedCeTypes)
    local modifiedStaticTrains = {}
    local modifiedDynamicTrains = {}
    for _, train in pairs(allTrains) do
        if isSelected(selectedCeTypes, HubCeTypes.TrainStatic) and train.staticValuesUpdated then
            modifiedStaticTrains[train.id] = train
            train.staticValuesUpdated = false
        end
        if isSelected(selectedCeTypes, HubCeTypes.TrainDynamic)
                and DynamicUpdateRegistry.isSelected(HubCeTypes.TrainDynamic, train.id)
                and (
                    train.dynamicValuesUpdated
                    or DynamicUpdateRegistry.needsInitialSend(HubCeTypes.TrainDynamic, train.id)
                ) then
            modifiedDynamicTrains[train.id] = train
            train.dynamicValuesUpdated = false
        end
    end
    for _, train in pairs(modifiedStaticTrains) do
        DataChangeBus.fireDataChanged(TrainStaticDtoFactory.createDto(train))
    end
    for _, train in pairs(modifiedDynamicTrains) do
        DataChangeBus.fireDataChanged(TrainDynamicDtoFactory.createDto(train))
        DynamicUpdateRegistry.markSent(HubCeTypes.TrainDynamic, train.id)
    end
end

function TrainRegistry.getAllTrainNames()
    local names = {}
    for trainName in pairs(allTrains) do names[trainName] = true end
    return names
end

return TrainRegistry
