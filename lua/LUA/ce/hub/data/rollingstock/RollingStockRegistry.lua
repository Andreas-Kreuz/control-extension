local RollingStock = require("ce.hub.data.rollingstock.RollingStock")
local TrainRollingStockStore = require("ce.hub.data.trains.TrainRollingStockStore")

local RollingStockRegistry = {}

function RollingStockRegistry.get(rollingStockName)
    return TrainRollingStockStore.getRollingStock(rollingStockName)
end

function RollingStockRegistry.getOrCreate(rollingStockName)
    return TrainRollingStockStore.getOrCreateRollingStock(rollingStockName, function (name)
        return RollingStock:new({ rollingStockName = name }):pullInitial()
    end)
end

function RollingStockRegistry.seedFromSnapshot(snapshot)
    return TrainRollingStockStore.seedRollingStockFromSnapshot(snapshot, RollingStock.fromSnapshot)
end

function RollingStockRegistry.removeAbsentFromSnapshot(rollingStockNames)
    TrainRollingStockStore.removeAbsentRollingStock(rollingStockNames)
end

function RollingStockRegistry.has(rollingStockName)
    return TrainRollingStockStore.hasRollingStock(rollingStockName)
end

function RollingStockRegistry.remove(rollingStockName)
    TrainRollingStockStore.removeRollingStock(rollingStockName)
end

function RollingStockRegistry.getAll()
    return TrainRollingStockStore.getAllRollingStock()
end

function RollingStockRegistry.getRemovedIds()
    return TrainRollingStockStore.getRemovedRollingStockIds()
end

function RollingStockRegistry.clearPendingChanges()
    TrainRollingStockStore.clearPendingRollingStockChanges()
end

return RollingStockRegistry
