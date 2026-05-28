if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitTrainUpdater ...") end

local TagKeys = require("ce.hub.data.rollingstock.TagKeys")
local Line = require("ce.mods.transit.Line")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")

local TransitTrainUpdater = {}

local function cachedTrainValue(hubTrain, key)
    return hubTrain.values and hubTrain.values[key] or nil
end

local function hasValue(value)
    return value ~= nil and value ~= ""
end

local function hasCachedTransitValues(hubTrain)
    return hasValue(cachedTrainValue(hubTrain, TagKeys.Train.line))
        or hasValue(cachedTrainValue(hubTrain, TagKeys.Train.destination))
        or hasValue(cachedTrainValue(hubTrain, TagKeys.Train.direction))
end

local function updateFromCachedTransitValues(transitTrain, hubTrain)
    transitTrain:updateLine(cachedTrainValue(hubTrain, TagKeys.Train.line))
    transitTrain:updateDestination(cachedTrainValue(hubTrain, TagKeys.Train.destination))
    transitTrain:updateDirection(cachedTrainValue(hubTrain, TagKeys.Train.direction))
end

function TransitTrainUpdater.runUpdate()
    local hubTrains = TrainRegistry.getAll()
    local seenTrainIds = {}

    for trainId, hubTrain in pairs(hubTrains) do
        seenTrainIds[trainId] = true
        local _, routeTransitTrain = Line.applyCachedRouteForTrain(hubTrain, { suppressUnknownRouteLog = true })
        local transitTrain = routeTransitTrain or TransitTrainRegistry.get(trainId)

        if not transitTrain and hasCachedTransitValues(hubTrain) then
            transitTrain = TransitTrainRegistry.forTrain(hubTrain)
        end
        if transitTrain then
            transitTrain:setHubTrain(hubTrain)
            updateFromCachedTransitValues(transitTrain, hubTrain)
        end
    end

    for trainId in pairs(TransitTrainRegistry.getAll()) do
        if not seenTrainIds[trainId] then
            TransitTrainRegistry.remove(trainId)
        end
    end
end

return TransitTrainUpdater
