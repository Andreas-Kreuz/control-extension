if CeDebugLoad then print("[#Start] Loading ce.mods.transit.DepotSignalReleaseUpdater ...") end

local DepotSignalRegistry = require("ce.mods.transit.DepotSignalRegistry")
local Line = require("ce.mods.transit.Line")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local WaitingOnSignalRegistry = require("ce.hub.data.signals.WaitingOnSignalRegistry")

local DepotSignalReleaseUpdater = {}
local releasedFirstVehicleBySignal = {}

local function firstWaitingEntryId(signalId)
    return tostring(signalId) .. "-1"
end

local function getKnownTrain(trainName)
    return TrainRegistry.getAll()[trainName]
end

function DepotSignalReleaseUpdater.runUpdate()
    for signalId in pairs(DepotSignalRegistry.getAll()) do
        local waiting = WaitingOnSignalRegistry.get(firstWaitingEntryId(signalId))
        local trainName = waiting and waiting.vehicleName or nil

        if not trainName or trainName == "" then
            releasedFirstVehicleBySignal[signalId] = nil
        elseif releasedFirstVehicleBySignal[signalId] ~= trainName then
            local train = getKnownTrain(trainName)
            if train and Line.applyCachedRouteForTrain(train, {
                    suppressUnknownRouteLog = true,
                    requireDepotSignalAutoRelease = true
                }) then
                SignalRegistry.getOrCreate(signalId):setPosition(DepotSignalRegistry.getReleasePosition(signalId))
                releasedFirstVehicleBySignal[signalId] = trainName
            end
        end
    end
end

return DepotSignalReleaseUpdater
