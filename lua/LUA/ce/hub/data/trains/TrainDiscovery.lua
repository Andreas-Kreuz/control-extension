if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainDiscovery ...") end

local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local RuntimeMetrics = require("ce.hub.data.runtime.RuntimeMetrics")
local TrackRegistry = require("ce.hub.data.tracks.TrackRegistry")
local TrainDiscoveryCache = require("ce.hub.data.trains.TrainDiscoveryCache")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local TrainDiscovery = {}
TrainDiscovery.debug = CeStartWithDebug or false

local MAX_TRACKS = 50000
local registerFunctions = {
    auxiliary = EEPRegisterAuxiliaryTrack,
    control = EEPRegisterControlTrack,
    road = EEPRegisterRoadTrack,
    rail = EEPRegisterRailTrack,
    tram = EEPRegisterTramTrack
}
local reservedFunctions = {
    auxiliary = EEPIsAuxiliaryTrackReserved,
    control = EEPIsControlTrackReserved,
    road = EEPIsRoadTrackReserved,
    rail = EEPIsRailTrackReserved,
    tram = EEPIsTramTrackReserved
}
local trackTypes = { "auxiliary", "control", "road", "rail", "tram" }

local movedTrainNames = {}
local dirtyTrainNames = {}
local hooksRegistered = false
local tracksInitialized = false

local function trackTypeFromSystemId(trackTypeId)
    if trackTypeId == 1 then return "rail" end
    if trackTypeId == 2 then return "tram" end
    if trackTypeId == 3 then return "road" end
    if trackTypeId == 4 then return "auxiliary" end
    return "control"
end

local function registerHooks()
    if hooksRegistered then return end

    local _EEPOnTrainCoupling = EEPOnTrainCoupling or function (_, _, _) end
    _G.EEPOnTrainCoupling = function (trainA, trainB, trainNew)
        dirtyTrainNames[trainA] = true
        dirtyTrainNames[trainB] = true
        dirtyTrainNames[trainNew] = true
        return _EEPOnTrainCoupling(trainA, trainB, trainNew)
    end

    local _EEPOnTrainLooseCoupling = EEPOnTrainLooseCoupling or function (_, _, _) end
    _G.EEPOnTrainLooseCoupling = function (trainA, trainB, trainOld)
        dirtyTrainNames[trainA] = true
        dirtyTrainNames[trainB] = true
        dirtyTrainNames[trainOld] = true
        return _EEPOnTrainLooseCoupling(trainA, trainB, trainOld)
    end

    local _EEPOnTrainExitTrainyard = EEPOnTrainExitTrainyard or function (_, _) end
    _G.EEPOnTrainExitTrainyard = function (depotId, trainName)
        local _ = depotId
        movedTrainNames[trainName] = true
        return _EEPOnTrainExitTrainyard(depotId, trainName)
    end

    hooksRegistered = true
end

local function initializeTracks()
    if tracksInitialized then return end

    for _, trackType in ipairs(trackTypes) do
        for id = 1, MAX_TRACKS do
            if registerFunctions[trackType](id) then
                TrackRegistry.add(trackType, {
                    id = id,
                    reserved = false,
                    reservedByTrainName = nil
                })
            end
        end
        TrackRegistry.markInitialListPending(trackType)
    end

    tracksInitialized = true
end

local function updateTracks()
    local trainsOnTrack = {}

    for _, trackType in ipairs(trackTypes) do
        for trackId, track in pairs(TrackRegistry.getAll(trackType)) do
            local _, occupied, trainName = reservedFunctions[trackType](track.id, true)
            local reservedByTrainName = occupied and trainName or nil

            if track.reserved ~= occupied or track.reservedByTrainName ~= reservedByTrainName then
                track.reserved = occupied
                track.reservedByTrainName = reservedByTrainName
                TrackRegistry.markChanged(trackType, trackId)
            end

            if occupied and trainName then
                trainsOnTrack[trainName] = trainsOnTrack[trainName] or {}
                trainsOnTrack[trainName][tostring(track.id)] = track.id
            end
        end
    end

    return trainsOnTrack
end

local function syncRollingStockComposition(train)
    local currentNames = {}
    local currentNamesByIndex = {}
    local count = EEPGetRollingstockItemsCount(train.name)

    train:setRollingStockCount(count)
    for i = 0, count - 1 do
        local rollingStockName = EEPGetRollingstockItemName(train.name, i)
        currentNamesByIndex[tostring(i)] = rollingStockName
        currentNames[rollingStockName] = true
        RollingStockRegistry.forName(rollingStockName)
    end

    for _, rollingStockName in pairs(TrainRegistry.allRollingStockNamesOf(train.name)) do
        if not currentNames[rollingStockName] then
            local ok = EEPRollingstockGetTrainName and EEPRollingstockGetTrainName(rollingStockName) or false
            if not ok then RollingStockRegistry.remove(rollingStockName) end
        end
    end

    TrainRegistry.setRollingStockNames(train.name, currentNamesByIndex)
end

local function removeTrain(trainName)
    local rollingStockNames = TrainRegistry.allRollingStockNamesOf(trainName)
    TrainRegistry.remove(trainName)
    for _, rsName in pairs(rollingStockNames) do
        local ok = EEPRollingstockGetTrainName and EEPRollingstockGetTrainName(rsName) or false
        if not ok then RollingStockRegistry.remove(rsName) end
    end
end

local function buildSnapshot(detected, dirtyTrains, movedTrains, trainTracks)
    local allKnownTrains = {}

    for trainName in pairs(detected) do
        local trainOnMap, speed = EEPGetTrainSpeed(trainName)
        if trainOnMap then
            local train, created = TrainRegistry.forName(trainName)
            local dirty = created or (dirtyTrains[trainName] and true or false)
            local moved = created or dirty or train:getSpeed() ~= 0 or speed ~= 0 or
                (movedTrains[trainName] and true or false)

            if created or dirty then syncRollingStockComposition(train) end

            local trackType = nil
            if trainTracks[trainName] and next(trainTracks[trainName]) ~= nil then
                local firstRollingStock = TrainRegistry.rollingStockNameInTrain(train.name, 0)
                if firstRollingStock then
                    local ok, _, _, _, trackTypeId = EEPRollingstockGetTrack(firstRollingStock)
                    if ok then trackType = trackTypeFromSystemId(trackTypeId) end
                end
            end

            allKnownTrains[trainName] = {
                name = trainName,
                speed = speed,
                created = created,
                dirty = dirty,
                moved = moved,
                tracks = trainTracks[trainName],
                trackType = trackType
            }
        else
            removeTrain(trainName)
        end
    end

    return allKnownTrains
end

function TrainDiscovery.initFromAnl3(tableOfAnl3)
    if not tableOfAnl3 then return end
    for _, train in ipairs(tableOfAnl3.trains) do
        if train.name then
            local registeredTrain = TrainRegistry.forName(train.name)
            syncRollingStockComposition(registeredTrain)

            local firstRollingStock = TrainRegistry.rollingStockNameInTrain(registeredTrain.name, 0)
            if firstRollingStock and EEPRollingstockGetTrack then
                local ok, _, _, _, trackTypeId = EEPRollingstockGetTrack(firstRollingStock)
                if ok then
                    registeredTrain:setTrackType(trackTypeFromSystemId(trackTypeId))
                end
            end
        end
    end
    for _, rs in ipairs(tableOfAnl3.rollingStocks) do
        if rs.name then
            local rollingStock = RollingStockRegistry.forName(rs.name)
            rollingStock:setXmlModel(rs.model)
        end
    end
end

function TrainDiscovery.runInitialDiscovery()
    if not HubOptionsRegistry.isAnyDiscoveryAndUpdateEnabled("trains",
                                                             "rollingStocks",
                                                             "auxiliaryTracks",
                                                             "controlTracks",
                                                             "roadTracks",
                                                             "railTracks",
                                                             "tramTracks") then
        return
    end

    registerHooks()
    initializeTracks()
    TrainDiscoveryCache.clear()
end

function TrainDiscovery.runDiscovery()
    if not HubOptionsRegistry.isAnyDiscoveryAndUpdateEnabled("trains",
                                                             "rollingStocks",
                                                             "auxiliaryTracks",
                                                             "controlTracks",
                                                             "roadTracks",
                                                             "railTracks",
                                                             "tramTracks") then
        return
    end

    registerHooks()

    local time = os.clock()
    local dirty = dirtyTrainNames
    local moved = movedTrainNames
    local detected = {}
    for trainName in pairs(TrainRegistry.getAllTrainNames()) do detected[trainName] = true end
    for trainName in pairs(dirty) do detected[trainName] = true end
    for trainName in pairs(moved) do detected[trainName] = true end

    local trainTracks = updateTracks()
    for trainName in pairs(trainTracks) do detected[trainName] = true end
    RuntimeMetrics.storeRunTime("TrainDiscovery.findTrainsOnTrack", os.clock() - time)

    time = os.clock()
    local allKnownTrains = buildSnapshot(detected, dirty, moved, trainTracks)
    RuntimeMetrics.storeRunTime("TrainDiscovery.buildSnapshot", os.clock() - time)
    TrainDiscoveryCache.replaceAll(allKnownTrains)

    dirtyTrainNames = {}
    movedTrainNames = {}
end

return TrainDiscovery
