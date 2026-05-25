if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockUpdater ...") end

local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local TrainDiscoveryCache = require("ce.hub.data.trains.TrainDiscoveryCache")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local DataClass = require("ce.hub.data.DataClass")
local ScenarioRegistry = require("ce.hub.data.scenario.ScenarioRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local RollingStockUpdater = {}
RollingStockUpdater.debug = CeStartWithDebug or false

function RollingStockUpdater.runUpdate()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("rollingStocks") then return end
    local fieldPolicies = HubOptionsRegistry.getFieldUpdatePolicies("rollingStocks")
    local scenario = ScenarioRegistry.get()
    local activeRollingStock = scenario and scenario:peekActiveRollingStock() or nil

    for trainName, train in pairs(TrainRegistry.getAll()) do
        local info = TrainDiscoveryCache.get(trainName) or {}
        local rollingStockCount = train:getRollingStockCount()
        local lastPositionInTrain = rollingStockCount - 1
        if RollingStockUpdater.debug then
            print(string.format("[#RollingStockUpdater] updating rolling stock of %s", trainName))
        end

        for positionInTrain = 0, lastPositionInTrain, 1 do
            local rsName = TrainRegistry.rollingStockNameInTrain(train.name, positionInTrain)
            if rsName then
                local rs = RollingStockRegistry.getOrCreate(rsName)
                local selectionKey = tostring(rs.id or rsName)
                local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.RollingStock, selectionKey)
                if SyncPolicy.shouldUpdateField(fieldPolicies, "trainName", isSelected) then
                    rs:setTrainName(train.name)
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "positionInTrain", isSelected) then
                    rs:setPositionInTrain(positionInTrain)
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "trackType", isSelected) and info.trackType then
                    rs:setTrackType(info.trackType)
                end
                if positionInTrain == 0
                    and SyncPolicy.shouldUpdateField(fieldPolicies, "couplingFront", isSelected) then
                    rs:pullCouplingFront()
                end
                if positionInTrain == lastPositionInTrain
                    and SyncPolicy.shouldUpdateField(fieldPolicies, "couplingRear", isSelected) then
                    rs:pullCouplingRear()
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "length", isSelected) then
                    rs:pullLength()
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "propelled", isSelected) then
                    rs:pullPropelled()
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "modelType", isSelected)
                    or SyncPolicy.shouldUpdateField(fieldPolicies, "modelTypeText", isSelected) then
                    rs:pullModelType()
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "tag", isSelected)
                    or SyncPolicy.shouldUpdateField(fieldPolicies, "nr", isSelected) then
                    rs:pullTag()
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "hookStatus", isSelected) then
                    rs:pullHookStatus()
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "hookGlueMode", isSelected) then
                    rs:pullHookGlueMode()
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "orientationForward", isSelected) then
                    rs:pullOrientationForward()
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "smoke", isSelected) then
                    rs:pullSmoke()
                end
                if activeRollingStock ~= nil and SyncPolicy.shouldUpdateField(fieldPolicies, "active", isSelected) then
                    rs:setActive(activeRollingStock == rs.rollingStockName)
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "surfaceTexts", isSelected)
                    and not DataClass.isLoaded(rs, "textureTexts") then
                    rs:getTextureTexts()
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "axisValues", isSelected) then
                    rs:pullAxisValues()
                end
                if (SyncPolicy.shouldUpdateField(fieldPolicies, "rotX", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "rotY", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "rotZ", isSelected)) then
                    rs:pullRotation()
                end
                if info.dirty or info.moved or info.created then
                    if SyncPolicy.shouldUpdateField(fieldPolicies, "trackId", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "trackDistance", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "trackDirection", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "trackSystem", isSelected) then
                        rs:pullTrack()
                    end
                    if SyncPolicy.shouldUpdateField(fieldPolicies, "posX", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "posY", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "posZ", isSelected) then
                        rs:pullPosition()
                    end
                    if SyncPolicy.shouldUpdateField(fieldPolicies, "mileage", isSelected) then
                        rs:pullMileage()
                    end
                end
            end
        end
    end
end

return RollingStockUpdater
