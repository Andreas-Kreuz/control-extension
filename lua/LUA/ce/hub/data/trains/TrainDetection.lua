if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainDetection ...") end
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local RuntimeMetrics = require("ce.hub.data.runtime.RuntimeMetrics")
local TrackDetection = require("ce.hub.data.tracks.TrackDetection")
local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local TrainDetection = {}
TrainDetection.debug = AkStartWithDebug or false

local trackTypes = { "auxiliary", "control", "road", "rail", "tram" }
local trackCollectors = {}
do for _, trackType in ipairs(trackTypes) do trackCollectors[trackType] = TrackDetection:new(trackType) end end

local movedTrainNames = {}
local dirtyTrainNames = {}
local initialized = false
local currentSnapshot = nil

local function copySet(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[key] = value end
    return copy
end

local function removeTrain(trainName)
    TrainRegistry.trainDisappeared(trainName)
    for _, rsName in pairs(TrainRegistry.allRollingStockNamesOf(trainName)) do
        local ok = EEPRollingstockGetTrainName(rsName)
        if not ok then RollingStockRegistry.rollingStockDisappeared(rsName) end
    end
end

function TrainDetection.registerForTrainDetection()
    local _EEPOnTrainCoupling = EEPOnTrainCoupling or function (_, _, _)
    end
    EEPOnTrainCoupling = function (trainA, trainB, trainNew)
        dirtyTrainNames[trainA] = true
        dirtyTrainNames[trainB] = true
        dirtyTrainNames[trainNew] = true
        if TrainDetection.debug then
            print(string.format("[#TrainDetection] %s and %s were coupled to %s", trainA, trainB, trainNew))
        end
        return _EEPOnTrainCoupling(trainA, trainB, trainNew)
    end

    local _EEPOnTrainLooseCoupling = EEPOnTrainLooseCoupling or function (_, _, _)
    end
    EEPOnTrainLooseCoupling = function (trainA, trainB, trainOld)
        dirtyTrainNames[trainA] = true
        dirtyTrainNames[trainB] = true
        dirtyTrainNames[trainOld] = true
        if TrainDetection.debug then
            print(string.format("[#TrainDetection] %s lost coupling and got to %s and %s", trainOld, trainA, trainB))
        end
        return _EEPOnTrainLooseCoupling(trainA, trainB, trainOld)
    end

    local _EEPOnTrainExitTrainyard = EEPOnTrainExitTrainyard or function (_, _)
    end
    EEPOnTrainExitTrainyard = function (depotId, trainName)
        movedTrainNames[trainName] = true
        return _EEPOnTrainExitTrainyard(depotId, trainName)
    end
end

function TrainDetection.trainInfosForAllTrains(detected, dirtyTrains, movedTrains, trainTracks)
    assert(type(detected) == "table", "Need detected as table")
    assert(type(dirtyTrains) == "table", "Need dirtyTrains as table")
    assert(type(movedTrains) == "table", "Need movedTrains as table")
    assert(type(trainTracks) == "table", "Need trainTracks as table")

    local currentTrainInfos = {}
    local _ = trainTracks
    for trainName in pairs(detected) do
        local trainOnMap, speed = EEPGetTrainSpeed(trainName)
        if trainOnMap then
            local train, created = TrainRegistry.forName(trainName)
            local dirty = created or (dirtyTrains[trainName] and true or false)
            local moved = created or dirty or train:getSpeed() ~= 0 or speed ~= 0 or
                (movedTrains[trainName] and true or false)
            local info = { name = trainName, speed = speed, created = created, dirty = dirty, moved = moved }
            currentTrainInfos[trainName] = info

            if created then TrainRegistry.trainAppeared(train) end
        else
            removeTrain(trainName)
        end
    end

    for trackType, tt in pairs(trainTracks) do
        for trainName, tracks in pairs(tt) do
            local info = currentTrainInfos[trainName]
            if info then
                info.tracks = tracks
                info.trackType = trackType
            end
        end
    end

    return currentTrainInfos
end

TrainDetection.registerForTrainDetection()

function TrainDetection.initialize(selectedCeTypes, trackFieldOptions)
    if initialized then return end
    for _, trackDetection in pairs(trackCollectors) do trackDetection:initialize(selectedCeTypes, trackFieldOptions) end
    initialized = true
end

function TrainDetection.getCurrentSnapshot()
    return currentSnapshot
end

function TrainDetection.update(selectedCeTypes, trackFieldOptions)
    if not initialized then TrainDetection.initialize(selectedCeTypes, trackFieldOptions) end

    local time = os.clock()
    local dirty = dirtyTrainNames
    local moved = movedTrainNames
    local detected = {}
    local trainTracks = {}
    for trainName in pairs(TrainRegistry.getAllTrainNames()) do detected[trainName] = true end
    for trainName in pairs(dirty) do detected[trainName] = true end
    for trainName in pairs(moved) do detected[trainName] = true end
    for trackType, trackDetection in pairs(trackCollectors) do
        local trainsOnTracks = trackDetection:findTrainsOnTrack(selectedCeTypes, trackFieldOptions)
        for trainName in pairs(trainsOnTracks) do detected[trainName] = true end
        trainTracks[trackType] = trainsOnTracks
    end
    RuntimeMetrics.storeRunTime("TrainDetection.findTrainsOnTrack", os.clock() - time)

    time = os.clock()
    local allKnownTrains = TrainDetection.trainInfosForAllTrains(detected, dirty, moved, trainTracks)
    RuntimeMetrics.storeRunTime("TrainDetection.trainInfosForAllTrains", os.clock() - time)

    currentSnapshot = {
        selectedCeTypes = copySet(selectedCeTypes),
        trainTracks = trainTracks,
        allKnownTrains = allKnownTrains,
    }

    dirtyTrainNames = {}
    movedTrainNames = {}
    return currentSnapshot
end

return TrainDetection
