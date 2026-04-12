if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainUpdater ...") end

local TrainDiscoveryCache = require("ce.hub.data.trains.TrainDiscoveryCache")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local EepFunctionWrapper = require("ce.hub.eep.EepFunctionWrapper")

local EEPGetTrainLength = EepFunctionWrapper.EEPGetTrainLength
local TrainUpdater = {}
TrainUpdater.debug = CeStartWithDebug or false

function TrainUpdater.runUpdate()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")
    local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
    local SyncPolicy = require("ce.hub.sync.SyncPolicy")
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("trains") then return end
    local fieldPolicies = HubOptionsRegistry.getFieldUpdatePolicies("trains")
    local activeTrain = EEPGetTrainActive and EEPGetTrainActive() or ""

    for trainName, train in pairs(TrainRegistry.getAll()) do
        local info = TrainDiscoveryCache.get(trainName) or {}
        local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Train, tostring(train.id or train.name or ""))
        if TrainUpdater.debug then print(string.format("[#TrainUpdater] updating train %s", trainName)) end

        if SyncPolicy.shouldUpdateField(fieldPolicies, "route", isSelected) then
            local routeOk, routeName = EEPGetTrainRoute(train.name)
            if routeOk then train:updateRoute(routeName or "") end
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "length", isSelected) then
            local _, length = EEPGetTrainLength(train.name)
            if length then train:setLength(length) end
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "speed", isSelected) then
            train:setSpeed(info.speed or 0)
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "movesForward", isSelected)
            and not SyncPolicy.shouldUpdateField(fieldPolicies, "speed", isSelected) then
            train:setMovesForward((info.speed or 0) >= 0)
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "targetSpeed", isSelected) then
            local _, targetSpeed = EEPGetTrainSpeed(train.name, true)
            train:setTargetSpeed(targetSpeed or info.speed or 0)
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "couplingFront", isSelected) and EEPGetTrainCouplingFront then
            local ok, trainCouplingFront = EEPGetTrainCouplingFront(train.name)
            if ok then train:setCouplingFront(trainCouplingFront) end
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "couplingRear", isSelected) and EEPGetTrainCouplingRear then
            local ok, trainCouplingRear = EEPGetTrainCouplingRear(train.name)
            if ok then train:setCouplingRear(trainCouplingRear) end
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "active", isSelected) then
            train:setActive(activeTrain == train.name)
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "inTrainyard", isSelected)
            or SyncPolicy.shouldUpdateField(fieldPolicies, "trainyardId", isSelected) then
            local inTrainyard, trainyardId = false, nil
            if EEPIsTrainInTrainyard then inTrainyard, trainyardId = EEPIsTrainInTrainyard(train.name) end
            train:setTrainyard(inTrainyard == true, trainyardId)
        end
        if info.tracks then train:setOnTrack(info.tracks) end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "trackType", isSelected) and info.trackType then
            train:setTrackType(info.trackType)
        end
    end
end

return TrainUpdater
