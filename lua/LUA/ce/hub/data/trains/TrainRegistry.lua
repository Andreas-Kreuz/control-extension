if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainRegistry ...") end

local Train = require("ce.hub.data.trains.Train")

local TrainRegistry = {}
TrainRegistry.debug = CeStartWithDebug or false

---@type table<string, Train>
local allTrains = {}
---@type table<string,table<string,string>>
local trainRollingStockNames = {}
local addedTrainIds = {}
local removedTrainIds = {}

function TrainRegistry.setRollingStockNames(trainName, rollingStockNamesByIndex)
    trainRollingStockNames[trainName] = rollingStockNamesByIndex or {}
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
    end

    local train = Train:new({ name = name })
    allTrains[train.name] = train
    addedTrainIds[train.name] = true
    removedTrainIds[train.name] = nil
    return train, true
end

function TrainRegistry.remove(trainName)
    if TrainRegistry.debug then print(string.format("[#TrainRegistry] train removed: %s", trainName)) end
    if allTrains[trainName] == nil then return end

    allTrains[trainName] = nil
    trainRollingStockNames[trainName] = nil
    if addedTrainIds[trainName] then
        addedTrainIds[trainName] = nil
    else
        removedTrainIds[trainName] = true
    end
end

function TrainRegistry.getAllTrainNames()
    local names = {}
    for trainName in pairs(allTrains) do names[trainName] = true end
    return names
end

function TrainRegistry.getAll()
    local copy = {}
    for trainName, train in pairs(allTrains) do copy[trainName] = train end
    return copy
end

function TrainRegistry.getRemovedIds()
    local copy = {}
    for trainId in pairs(removedTrainIds) do copy[trainId] = true end
    return copy
end

function TrainRegistry.clearPendingChanges()
    addedTrainIds = {}
    removedTrainIds = {}
end

return TrainRegistry
