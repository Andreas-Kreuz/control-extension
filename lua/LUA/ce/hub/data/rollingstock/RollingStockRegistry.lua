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

function RollingStockRegistry.seedFromSnapshot(snapshot)
    assert(type(snapshot) == "table", "Need snapshot as table")
    assert(type(snapshot.rollingStockName) == "string", "Need snapshot.rollingStockName as string")

    if allRollingStock[snapshot.rollingStockName] then
        local rollingStock = allRollingStock[snapshot.rollingStockName]
        if snapshot.xmlModel then rollingStock:setXmlModelFromSnapshot(snapshot.xmlModel) end
        if snapshot.tag ~= nil then rollingStock:setTag(snapshot.tag) end
        if snapshot.smoke ~= nil then rollingStock:setSmoke(snapshot.smoke) end
        if snapshot.trainName then rollingStock:setTrainName(snapshot.trainName) end
        if snapshot.positionInTrain then rollingStock:setPositionInTrain(snapshot.positionInTrain) end
        if snapshot.trackType then rollingStock:setTrackType(snapshot.trackType) end
        if snapshot.trackId and snapshot.trackDistance and snapshot.trackDirection and snapshot.trackSystem then
            rollingStock:setTrack(snapshot.trackId, snapshot.trackDistance, snapshot.trackDirection,
                                  snapshot.trackSystem)
        end
        return rollingStock, false
    end

    local rollingStock = RollingStock.fromSnapshot(snapshot)
    allRollingStock[rollingStock.rollingStockName] = rollingStock
    addedRollingStockIds[rollingStock.rollingStockName] = true
    removedRollingStockIds[rollingStock.rollingStockName] = nil
    return rollingStock, true
end

function RollingStockRegistry.removeAbsentFromSnapshot(rollingStockNames)
    rollingStockNames = rollingStockNames or {}
    for rollingStockName in pairs(allRollingStock) do
        if not rollingStockNames[rollingStockName] then RollingStockRegistry.remove(rollingStockName) end
    end
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
