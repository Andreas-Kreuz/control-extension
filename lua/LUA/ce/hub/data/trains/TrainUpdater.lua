if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainUpdater ...") end

local TagKeys = require("ce.hub.data.rollingstock.TagKeys")
local TrainDiscoveryCache = require("ce.hub.data.trains.TrainDiscoveryCache")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local EepFunctionWrapper = require("ce.hub.eep.EepFunctionWrapper")

local EEPGetTrainLength = EepFunctionWrapper.EEPGetTrainLength
local TrainUpdater = {}
TrainUpdater.debug = CeStartWithDebug or false

local function shouldCollect(fieldOptions, fieldName)
    local field = fieldOptions and fieldOptions[fieldName] or nil
    return field == nil or field.collect ~= false
end

function TrainUpdater.runUpdate(fieldOptions)
    local activeTrain = EEPGetTrainActive and EEPGetTrainActive() or ""

    for trainName, train in pairs(TrainRegistry.getAll()) do
        local info = TrainDiscoveryCache.get(trainName) or {}
        if TrainUpdater.debug then print(string.format("[#TrainUpdater] updating train %s", trainName)) end

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
            train:setSpeed(info.speed or 0)
        end
        if shouldCollect(fieldOptions, "movesForward") and not shouldCollect(fieldOptions, "speed") then
            train:setMovesForward((info.speed or 0) >= 0)
        end
        if shouldCollect(fieldOptions, "targetSpeed") then
            local _, targetSpeed = EEPGetTrainSpeed(train.name, true)
            train:setTargetSpeed(targetSpeed or info.speed or 0)
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

return TrainUpdater
