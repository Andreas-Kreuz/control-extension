if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitTrainUpdater ...") end

local TagKeys = require("ce.hub.data.rollingstock.TagKeys")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")

local TransitTrainUpdater = {}

function TransitTrainUpdater.runUpdate()
    local hubTrains = TrainRegistry.getAll()
    local seenTrainIds = {}

    for trainId, hubTrain in pairs(hubTrains) do
        seenTrainIds[trainId] = true
        local transitTrain = TransitTrainRegistry.forTrain(hubTrain)
        local values = hubTrain:load()
        transitTrain:updateLine(values[TagKeys.Train.line])
        transitTrain:updateDestination(values[TagKeys.Train.destination])
        transitTrain:updateDirection(values[TagKeys.Train.direction])
    end

    for trainId in pairs(TransitTrainRegistry.getAll()) do
        if not seenTrainIds[trainId] then
            TransitTrainRegistry.remove(trainId)
        end
    end
end

return TransitTrainUpdater
