if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainInfoUpdater ...") end
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local TagKeys = require("ce.hub.data.rollingstock.TagKeys")
local EepFunctionWrapper = require("ce.hub.eep.EepFunctionWrapper")

local EEPGetTrainLength = EepFunctionWrapper.EEPGetTrainLength
local TrainInfoUpdater = {}
TrainInfoUpdater.debug = AkStartWithDebug or false

local function shouldCollect(fieldOptions, fieldName)
    local field = fieldOptions and fieldOptions[fieldName] or nil
    return field == nil or field.collect ~= false
end

local function fillTrackInfoFromTrain(train, info)
    local firstRollingStock = TrainRegistry.rollingStockNameInTrain(train.name, 0)
    local ok, trackId, _, _, trackTypeId = EEPRollingstockGetTrack(firstRollingStock)
    assert(ok, "Rollingstock not found: " .. firstRollingStock)

    local trackType = "control"
    if trackTypeId == 1 then trackType = "rail" end
    if trackTypeId == 2 then trackType = "road" end
    if trackTypeId == 3 then trackType = "tram" end
    if trackTypeId == 4 then trackType = "auxiliary" end

    info.tracks = { [tostring(trackId)] = trackId }
    info.trackType = trackType
    if TrainInfoUpdater.debug then
        print("[#TrainInfoUpdater] TRAIN DETECTED: " .. trackType .. " -> " .. trackTypeId)
    end
end

local function ensureTrackInfo(train, info)
    if (not info.tracks or not info.trackType) and not train:getTrackType() then
        fillTrackInfoFromTrain(train, info)
    elseif not info.trackType and train:getTrackType() then
        info.trackType = train:getTrackType()
    end
end

local function ensureTrainRollingStock(train, info)
    if info.dirty and not info.rollingStockInitialized then
        TrainRegistry.initRollingStock(train)
        info.rollingStockInitialized = true
    end
end

function TrainInfoUpdater.refresh(allKnownTrains, fieldOptions)
    assert(type(allKnownTrains) == "table", "Need allKnownTrains as table")

    local activeTrain = EEPGetTrainActive and EEPGetTrainActive() or ""

    for trainName, info in pairs(allKnownTrains) do
        if TrainInfoUpdater.debug then print(string.format("[#TrainInfoUpdater] updating train %s", trainName)) end
        local train = TrainRegistry.forName(trainName)
        ensureTrainRollingStock(train, info)
        ensureTrackInfo(train, info)

        if shouldCollect(fieldOptions, "route") then
            local routeOk, routeName = EEPGetTrainRoute(train.name)
            if routeOk then train:updateRoute(routeName or "") end
        end
        if shouldCollect(fieldOptions, "length") then
            local _, length = EEPGetTrainLength(train.name)
            if length then train:setLength(length) end
        end
        if shouldCollect(fieldOptions, "line")
            or shouldCollect(fieldOptions, "destination")
            or shouldCollect(fieldOptions, "direction") then
            local values = train:load()
            if shouldCollect(fieldOptions, "line") then train:updateLine(values[TagKeys.Train.line] or "") end
            if shouldCollect(fieldOptions, "destination") then
                train:updateDestination(values[TagKeys.Train.destination] or "")
            end
            if shouldCollect(fieldOptions, "direction") then
                train:updateDirection(values[TagKeys.Train.direction] or "")
            end
        end
        if shouldCollect(fieldOptions, "speed") then
            train:setSpeed(info.speed)
        end
        if shouldCollect(fieldOptions, "movesForward") and not shouldCollect(fieldOptions, "speed") then
            train:setMovesForward(info.speed >= 0)
        end
        if shouldCollect(fieldOptions, "targetSpeed") then
            local _, targetSpeed = EEPGetTrainSpeed(train.name, true)
            train:setTargetSpeed(targetSpeed or info.speed)
        end
        if shouldCollect(fieldOptions, "couplingFront") and EEPGetTrainCouplingFront then
            local ok, trainCouplingFront = EEPGetTrainCouplingFront(train.name)
            if ok then train:setCouplingFront(trainCouplingFront) end
        end
        if shouldCollect(fieldOptions, "couplingRear") and EEPGetTrainCouplingRear then
            local ok, trainCouplingRear = EEPGetTrainCouplingRear(train.name)
            if ok then train:setCouplingRear(trainCouplingRear) end
        end
        if shouldCollect(fieldOptions, "active") then
            train:setActive(activeTrain == train.name)
        end
        if shouldCollect(fieldOptions, "inTrainyard") or shouldCollect(fieldOptions, "trainyardId") then
            local inTrainyard, trainyardId = false, nil
            if EEPIsTrainInTrainyard then inTrainyard, trainyardId = EEPIsTrainInTrainyard(train.name) end
            train:setTrainyard(inTrainyard == true, trainyardId)
        end
        if info.tracks then train:setOnTrack(info.tracks) end
        if shouldCollect(fieldOptions, "trackType") and info.trackType then
            train:setTrackType(info.trackType)
        end
    end
end

return TrainInfoUpdater
