local RollingStock = require("ce.hub.data.rollingstock.RollingStock")

local RollingStockRegistry = {}

---@type table<string,RollingStock>
local allRollingStock = {}
local addedRollingStockIds = {}
local removedRollingStockIds = {}

function RollingStockRegistry.forName(rollingStockName)
    assert(rollingStockName, "Provide a rollingStockName")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    if allRollingStock[rollingStockName] then
        return allRollingStock[rollingStockName]
    end

    local rollingStock = RollingStock:new({ rollingStockName = rollingStockName })
    allRollingStock[rollingStock.rollingStockName] = rollingStock
    addedRollingStockIds[rollingStock.rollingStockName] = true
    removedRollingStockIds[rollingStock.rollingStockName] = nil
    return rollingStock
end

function RollingStockRegistry.has(rollingStockName)
    return allRollingStock[rollingStockName] ~= nil
end

function RollingStockRegistry.remove(rollingStockName)
    if allRollingStock[rollingStockName] == nil then return end

    allRollingStock[rollingStockName] = nil
    if addedRollingStockIds[rollingStockName] then
        addedRollingStockIds[rollingStockName] = nil
    else
        removedRollingStockIds[rollingStockName] = true
    end
end

function RollingStockRegistry.getAll()
    local copy = {}
    for rollingStockName, rollingStock in pairs(allRollingStock) do copy[rollingStockName] = rollingStock end
    return copy
end

function RollingStockRegistry.getRemovedIds()
    local copy = {}
    for rollingStockId in pairs(removedRollingStockIds) do copy[rollingStockId] = true end
    return copy
end

function RollingStockRegistry.clearPendingChanges()
    addedRollingStockIds = {}
    removedRollingStockIds = {}
end

return RollingStockRegistry
