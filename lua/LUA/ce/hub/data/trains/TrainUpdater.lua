if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainUpdater ...") end

local TrainDiscoveryCache = require("ce.hub.data.trains.TrainDiscoveryCache")
local ScenarioRegistry = require("ce.hub.data.scenario.ScenarioRegistry")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

local TrainUpdater = {}
TrainUpdater.debug = CeStartWithDebug or false
local routeUpdateRunCount = 0
local routeUpdateInterval = 10

local function shouldUpdateRoute(fieldPolicies, isSelected, SyncPolicy)
    local policy = SyncPolicy.getFieldPolicy(fieldPolicies, "route")
    if policy == "never" then return false end
    if isSelected then return true end
    return policy == "always" and routeUpdateRunCount % routeUpdateInterval == 0
end

function TrainUpdater.runUpdate()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")
    local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
    local SyncPolicy = require("ce.hub.sync.SyncPolicy")
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("trains") then return end
    local fieldPolicies = HubOptionsRegistry.getFieldUpdatePolicies("trains")
    local scenario = ScenarioRegistry.get()
    local activeTrain = scenario and scenario:peekActiveTrain() or nil

    for trainName, train in pairs(TrainRegistry.getAll()) do
        local info = TrainDiscoveryCache.get(trainName) or {}
        local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Train, tostring(train.id or train.name or ""))
        if TrainUpdater.debug then print(string.format("[#TrainUpdater] updating train %s", trainName)) end

        if shouldUpdateRoute(fieldPolicies, isSelected, SyncPolicy) then
            train:pullRoute()
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "length", isSelected) then
            train:pullLength()
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "speed", isSelected) then
            train:setSpeed(info.speed or 0)
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "movesForward", isSelected)
            and not SyncPolicy.shouldUpdateField(fieldPolicies, "speed", isSelected) then
            train:setMovesForward((info.speed or 0) >= 0)
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "targetSpeed", isSelected) then
            train:pullTargetSpeed(info.speed)
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "couplingFront", isSelected) then
            train:pullCouplingFront()
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "couplingRear", isSelected) then
            train:pullCouplingRear()
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "lights", isSelected) then
            train:pullLights()
        end
        if activeTrain ~= nil and SyncPolicy.shouldUpdateField(fieldPolicies, "active", isSelected) then
            train:setActive(activeTrain == train.name)
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "inTrainyard", isSelected)
            or SyncPolicy.shouldUpdateField(fieldPolicies, "trainyardId", isSelected) then
            train:pullTrainyard()
        end
        if info.tracks then train:setOnTrack(info.tracks) end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "trackType", isSelected) and info.trackType then
            train:setTrackType(info.trackType)
        end
    end

    routeUpdateRunCount = routeUpdateRunCount + 1
end

return TrainUpdater
