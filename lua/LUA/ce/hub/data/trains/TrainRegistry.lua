if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainRegistry ...") end

local Train = require("ce.hub.data.trains.Train")
local TrainRollingStockStore = require("ce.hub.data.trains.TrainRollingStockStore")

if _G.CeTestingMode then TrainRollingStockStore.reset() end

local TrainRegistry = {}
TrainRegistry.debug = CeStartWithDebug or false

function TrainRegistry.setRollingStockNames(trainName, rollingStockNamesByIndex)
    TrainRollingStockStore.setRollingStockNames(trainName, rollingStockNamesByIndex)
end

function TrainRegistry.allRollingStockNamesOf(trainName)
    return TrainRollingStockStore.allRollingStockNamesOf(trainName)
end

function TrainRegistry.rollingStockNameInTrain(name, index)
    return TrainRollingStockStore.rollingStockNameInTrain(name, index)
end

function TrainRegistry.get(name)
    return TrainRollingStockStore.getTrain(name)
end

function TrainRegistry.getOrCreate(name)
    return TrainRollingStockStore.getOrCreateTrain(name, function (trainName)
        return Train:new({ name = trainName }):pullInitial()
    end)
end

function TrainRegistry.seedFromSnapshot(snapshot)
    return TrainRollingStockStore.seedTrainFromSnapshot(snapshot, Train.fromSnapshot)
end

function TrainRegistry.removeAbsentFromSnapshot(trainNames)
    TrainRollingStockStore.removeAbsentTrains(trainNames)
end

function TrainRegistry.remove(trainName)
    if TrainRegistry.debug then print(string.format("[#TrainRegistry] train removed: %s", trainName)) end
    TrainRollingStockStore.removeTrain(trainName)
end

function TrainRegistry.getAllTrainNames()
    return TrainRollingStockStore.getAllTrainNames()
end

function TrainRegistry.getAll()
    return TrainRollingStockStore.getAllTrains()
end

function TrainRegistry.getRemovedIds()
    return TrainRollingStockStore.getRemovedTrainIds()
end

function TrainRegistry.clearPendingChanges()
    TrainRollingStockStore.clearPendingTrainChanges()
end

return TrainRegistry
