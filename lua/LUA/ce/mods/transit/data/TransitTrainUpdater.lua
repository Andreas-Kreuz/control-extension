if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitTrainUpdater ...") end

local TagKeys = require("ce.hub.data.rollingstock.TagKeys")
local Line = require("ce.mods.transit.Line")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")

local TransitTrainUpdater = {}

function TransitTrainUpdater.runUpdate()
    local hubTrains = TrainRegistry.getAll()
    local seenTrainIds = {}

    for trainId, hubTrain in pairs(hubTrains) do
        seenTrainIds[trainId] = true
        local transitTrain = TransitTrainRegistry.forTrain(hubTrain)
        transitTrain:updateLine(hubTrain:getValue(TagKeys.Train.line))
        transitTrain:updateDestination(hubTrain:getValue(TagKeys.Train.destination))
        transitTrain:updateDirection(hubTrain:getValue(TagKeys.Train.direction))
        Line.applyCachedRouteForTrain(hubTrain, { suppressUnknownRouteLog = true })
    end

    for trainId in pairs(TransitTrainRegistry.getAll()) do
        if not seenTrainIds[trainId] then
            TransitTrainRegistry.remove(trainId)
        end
    end
end

return TransitTrainUpdater
