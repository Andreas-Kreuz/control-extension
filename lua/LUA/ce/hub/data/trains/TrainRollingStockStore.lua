if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainRollingStockStore ...") end

local TrainRollingStockStore = {}

---@type table<string, Train>
local allTrains = {}
---@type table<string, RollingStock>
local allRollingStock = {}
---@type table<string,table<string,string>>
local trainRollingStockNames = {}
local addedTrainIds = {}
local removedTrainIds = {}
local addedRollingStockIds = {}
local removedRollingStockIds = {}

function TrainRollingStockStore.reset()
    allTrains = {}
    allRollingStock = {}
    trainRollingStockNames = {}
    addedTrainIds = {}
    removedTrainIds = {}
    addedRollingStockIds = {}
    removedRollingStockIds = {}
end

function TrainRollingStockStore.setRollingStockNames(trainName, rollingStockNamesByIndex)
    trainRollingStockNames[trainName] = rollingStockNamesByIndex or {}
end

function TrainRollingStockStore.allRollingStockNamesOf(trainName)
    return trainRollingStockNames[trainName] and trainRollingStockNames[trainName] or {}
end

function TrainRollingStockStore.rollingStockNameInTrain(name, index)
    return trainRollingStockNames[name] and trainRollingStockNames[name][tostring(index)] or nil
end

function TrainRollingStockStore.getTrain(name)
    if type(name) ~= "string" then return nil end
    return allTrains[name]
end

function TrainRollingStockStore.getOrCreateTrain(name, createTrain)
    assert(name, "Provide a name for the train")
    assert(type(name) == "string", "Need 'trainName' as string")
    if allTrains[name] then return allTrains[name], false end

    local train = createTrain(name)
    allTrains[train.name] = train
    addedTrainIds[train.name] = true
    removedTrainIds[train.name] = nil
    return train, true
end

function TrainRollingStockStore.seedTrainFromSnapshot(snapshot, createTrainFromSnapshot)
    assert(type(snapshot) == "table", "Need snapshot as table")
    assert(type(snapshot.name) == "string", "Need snapshot.name as string")

    if allTrains[snapshot.name] then
        local train = allTrains[snapshot.name]
        if snapshot.route then train:updateRoute(snapshot.route) end
        if snapshot.rollingStockCount then train:setRollingStockCount(snapshot.rollingStockCount) end
        if snapshot.length then train:setLength(snapshot.length) end
        if snapshot.speed then train:setSpeed(snapshot.speed) end
        if snapshot.targetSpeed then train:setTargetSpeed(snapshot.targetSpeed) end
        if snapshot.couplingFront then train:setCouplingFront(snapshot.couplingFront) end
        if snapshot.couplingRear then train:setCouplingRear(snapshot.couplingRear) end
        if snapshot.lights then train:setLights(snapshot.lights) end
        if snapshot.trackType then train:setTrackType(snapshot.trackType) end
        if snapshot.onTracks then train:setOnTrack(snapshot.onTracks) end
        return train, false
    end

    local train = createTrainFromSnapshot(snapshot)
    allTrains[train.name] = train
    addedTrainIds[train.name] = true
    removedTrainIds[train.name] = nil
    return train, true
end

function TrainRollingStockStore.removeAbsentTrains(trainNames)
    trainNames = trainNames or {}
    for trainName in pairs(allTrains) do
        if not trainNames[trainName] then TrainRollingStockStore.removeTrain(trainName) end
    end
end

function TrainRollingStockStore.removeTrain(trainName)
    if allTrains[trainName] == nil then return end

    allTrains[trainName] = nil
    trainRollingStockNames[trainName] = nil
    if addedTrainIds[trainName] then
        addedTrainIds[trainName] = nil
    else
        removedTrainIds[trainName] = true
    end
end

function TrainRollingStockStore.getAllTrainNames()
    local names = {}
    for trainName in pairs(allTrains) do names[trainName] = true end
    return names
end

function TrainRollingStockStore.getAllTrains()
    local copy = {}
    for trainName, train in pairs(allTrains) do copy[trainName] = train end
    return copy
end

function TrainRollingStockStore.getRemovedTrainIds()
    local copy = {}
    for trainId in pairs(removedTrainIds) do copy[trainId] = true end
    return copy
end

function TrainRollingStockStore.clearPendingTrainChanges()
    addedTrainIds = {}
    removedTrainIds = {}
end

function TrainRollingStockStore.getRollingStock(rollingStockName)
    if type(rollingStockName) ~= "string" then return nil end
    return allRollingStock[rollingStockName]
end

function TrainRollingStockStore.getOrCreateRollingStock(rollingStockName, createRollingStock)
    assert(rollingStockName, "Provide a rollingStockName")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    if allRollingStock[rollingStockName] then return allRollingStock[rollingStockName] end

    local rollingStock = createRollingStock(rollingStockName)
    allRollingStock[rollingStock.rollingStockName] = rollingStock
    addedRollingStockIds[rollingStock.rollingStockName] = true
    removedRollingStockIds[rollingStock.rollingStockName] = nil
    return rollingStock
end

function TrainRollingStockStore.seedRollingStockFromSnapshot(snapshot, createRollingStockFromSnapshot)
    assert(type(snapshot) == "table", "Need snapshot as table")
    assert(type(snapshot.rollingStockName) == "string", "Need snapshot.rollingStockName as string")

    if allRollingStock[snapshot.rollingStockName] then
        local rollingStock = allRollingStock[snapshot.rollingStockName]
        if snapshot.xmlModel then rollingStock:setXmlModelFromSnapshot(snapshot.xmlModel, snapshot.deferModelInfo) end
        if snapshot.tag ~= nil then rollingStock:setTag(snapshot.tag) end
        if snapshot.smoke ~= nil then rollingStock:setSmoke(snapshot.smoke) end
        if snapshot.textureTexts ~= nil then rollingStock:setTextureTexts(snapshot.textureTexts) end
        if snapshot.trainName then rollingStock:setTrainName(snapshot.trainName) end
        if snapshot.positionInTrain then rollingStock:setPositionInTrain(snapshot.positionInTrain) end
        if snapshot.trackType then rollingStock:setTrackType(snapshot.trackType) end
        if snapshot.trackId and snapshot.trackDistance and snapshot.trackDirection and snapshot.trackSystem then
            rollingStock:setTrack(snapshot.trackId, snapshot.trackDistance, snapshot.trackDirection,
                                  snapshot.trackSystem)
        end
        return rollingStock, false
    end

    local rollingStock = createRollingStockFromSnapshot(snapshot)
    allRollingStock[rollingStock.rollingStockName] = rollingStock
    addedRollingStockIds[rollingStock.rollingStockName] = true
    removedRollingStockIds[rollingStock.rollingStockName] = nil
    return rollingStock, true
end

function TrainRollingStockStore.removeAbsentRollingStock(rollingStockNames)
    rollingStockNames = rollingStockNames or {}
    for rollingStockName in pairs(allRollingStock) do
        if not rollingStockNames[rollingStockName] then
            TrainRollingStockStore.removeRollingStock(rollingStockName)
        end
    end
end

function TrainRollingStockStore.hasRollingStock(rollingStockName)
    return allRollingStock[rollingStockName] ~= nil
end

function TrainRollingStockStore.removeRollingStock(rollingStockName)
    if allRollingStock[rollingStockName] == nil then return end

    allRollingStock[rollingStockName] = nil
    if addedRollingStockIds[rollingStockName] then
        addedRollingStockIds[rollingStockName] = nil
    else
        removedRollingStockIds[rollingStockName] = true
    end
end

function TrainRollingStockStore.getAllRollingStock()
    local copy = {}
    for rollingStockName, rollingStock in pairs(allRollingStock) do
        copy[rollingStockName] = rollingStock
    end
    return copy
end

function TrainRollingStockStore.getRemovedRollingStockIds()
    local copy = {}
    for rollingStockId in pairs(removedRollingStockIds) do copy[rollingStockId] = true end
    return copy
end

function TrainRollingStockStore.clearPendingRollingStockChanges()
    addedRollingStockIds = {}
    removedRollingStockIds = {}
end

return TrainRollingStockStore
