if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitTrainRegistry ...") end

local TransitTrain = require("ce.mods.transit.data.TransitTrain")

local TransitTrainRegistry = {}

---@type table<string, TransitTrain>
local allTransitTrains = {}
local addedTransitTrainIds = {}
local removedTransitTrainIds = {}

function TransitTrainRegistry.forTrain(hubTrain)
    assert(type(hubTrain) == "table" and hubTrain.type == "Train", "Need 'hubTrain' as Train")
    local existing = allTransitTrains[hubTrain.id]
    if existing then
        existing:setHubTrain(hubTrain)
        return existing, false
    end

    local transitTrain = TransitTrain:new(hubTrain)
    allTransitTrains[transitTrain.id] = transitTrain
    addedTransitTrainIds[transitTrain.id] = true
    removedTransitTrainIds[transitTrain.id] = nil
    return transitTrain, true
end

function TransitTrainRegistry.forName(trainId)
    local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
    return TransitTrainRegistry.forTrain(TrainRegistry.forName(trainId))
end

function TransitTrainRegistry.remove(trainId)
    if allTransitTrains[trainId] == nil then return end

    allTransitTrains[trainId] = nil
    if addedTransitTrainIds[trainId] then
        addedTransitTrainIds[trainId] = nil
    else
        removedTransitTrainIds[trainId] = true
    end
end

function TransitTrainRegistry.getAll()
    local copy = {}
    for trainId, transitTrain in pairs(allTransitTrains) do copy[trainId] = transitTrain end
    return copy
end

function TransitTrainRegistry.getRemovedIds()
    local copy = {}
    for trainId in pairs(removedTransitTrainIds) do copy[trainId] = true end
    return copy
end

function TransitTrainRegistry.clearPendingChanges()
    addedTransitTrainIds = {}
    removedTransitTrainIds = {}
end

return TransitTrainRegistry
