if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockUpdater ...") end

local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local TrainDiscoveryCache = require("ce.hub.data.trains.TrainDiscoveryCache")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local RollingStockUpdater = {}
RollingStockUpdater.debug = CeStartWithDebug or false

function RollingStockUpdater.runUpdate()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("rollingStocks") then return end
    local fieldPolicies = HubOptionsRegistry.getFieldUpdatePolicies("rollingStocks")
    local activeRollingStock = EEPRollingstockGetActive and EEPRollingstockGetActive() or ""

    for trainName, train in pairs(TrainRegistry.getAll()) do
        local info = TrainDiscoveryCache.get(trainName) or {}
        if RollingStockUpdater.debug then
            print(string.format("[#RollingStockUpdater] updating rolling stock of %s", trainName))
        end

        for positionInTrain = 0, train:getRollingStockCount() - 1, 1 do
            local rsName = TrainRegistry.rollingStockNameInTrain(train.name, positionInTrain)
            if rsName then
                local rs = RollingStockRegistry.forName(rsName)
                local selectionKey = tostring(rs.id or rsName)
                local isSelected = DynamicUpdateRegistry.isSelected(HubCeTypes.RollingStock, selectionKey)
                if SyncPolicy.shouldUpdateField(fieldPolicies, "trainName", isSelected) then
                    rs:setTrainName(train.name)
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "positionInTrain", isSelected) then
                    rs:setPositionInTrain(positionInTrain)
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "trackType", isSelected) and info.trackType then
                    rs:setTrackType(info.trackType)
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "couplingFront", isSelected) then
                    local ok, couplingFront = EEPRollingstockGetCouplingFront(rs.rollingStockName)
                    if ok then rs:setCouplingFront(couplingFront) end
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "couplingRear", isSelected) then
                    local ok, couplingRear = EEPRollingstockGetCouplingRear(rs.rollingStockName)
                    if ok then rs:setCouplingRear(couplingRear) end
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "length", isSelected) then
                    local _, length = EEPRollingstockGetLength(rs.rollingStockName)
                    if length then rs:setLength(length) end
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "propelled", isSelected) then
                    local _, propelled = EEPRollingstockGetMotor(rs.rollingStockName)
                    rs:setPropelled(propelled ~= false)
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "modelType", isSelected)
                    or SyncPolicy.shouldUpdateField(fieldPolicies, "modelTypeText", isSelected) then
                    local _, modelType = EEPRollingstockGetModelType(rs.rollingStockName)
                    if modelType then rs:setModelType(modelType) end
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "tag", isSelected)
                    or SyncPolicy.shouldUpdateField(fieldPolicies, "nr", isSelected) then
                    local _, tag = EEPRollingstockGetTagText(rs.rollingStockName)
                    rs:setTag(tag or "")
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "hookStatus", isSelected)
                    and EEPRollingstockGetHook then
                    local ok, hookStatus = EEPRollingstockGetHook(rs.rollingStockName)
                    if ok then rs:setHookStatus(hookStatus) end
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "hookGlueMode", isSelected)
                    and EEPRollingstockGetHookGlue then
                    local ok, hookGlueMode = EEPRollingstockGetHookGlue(rs.rollingStockName)
                    if ok then rs:setHookGlueMode(hookGlueMode) end
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "orientationForward", isSelected)
                    and EEPRollingstockGetOrientation then
                    local ok, orientationForward = EEPRollingstockGetOrientation(rs.rollingStockName)
                    if ok then rs:setOrientationForward(orientationForward == true) end
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "smoke", isSelected) and EEPRollingstockGetSmoke then
                    local ok, smoke = EEPRollingstockGetSmoke(rs.rollingStockName)
                    if ok then rs:setSmoke(smoke) end
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "active", isSelected) then
                    rs:setActive(activeRollingStock == rs.rollingStockName)
                end
                if SyncPolicy.shouldUpdateField(fieldPolicies, "surfaceTexts", isSelected) then
                    rs:updateTextureTexts()
                end
                if (SyncPolicy.shouldUpdateField(fieldPolicies, "rotX", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "rotY", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "rotZ", isSelected))
                    and EEPRollingstockGetRotation then
                    local ok, rotX, rotY, rotZ = EEPRollingstockGetRotation(rs.rollingStockName)
                    if ok then rs:setRotation(rotX, rotY, rotZ) end
                end
                if info.dirty or info.moved or info.created then
                    if SyncPolicy.shouldUpdateField(fieldPolicies, "trackId", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "trackDistance", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "trackDirection", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "trackSystem", isSelected) then
                        local _, trackId, trackDistance, trackDirection, trackSystem = EEPRollingstockGetTrack(
                            rs.rollingStockName)
                        rs:setTrack(trackId, trackDistance, trackDirection, trackSystem)
                    end
                    if SyncPolicy.shouldUpdateField(fieldPolicies, "posX", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "posY", isSelected)
                        or SyncPolicy.shouldUpdateField(fieldPolicies, "posZ", isSelected) then
                        local hasPos, posX, posY, posZ = EEPRollingstockGetPosition(rs.rollingStockName)
                        if hasPos then
                            rs:setPosition(tonumber(posX) or -1, tonumber(posY) or -1, tonumber(posZ) or -1)
                        end
                    end
                    if SyncPolicy.shouldUpdateField(fieldPolicies, "mileage", isSelected) then
                        local hasMileage, mileage = EEPRollingstockGetMileage(rs.rollingStockName)
                        if hasMileage then rs:setMileage(mileage) end
                    end
                end
            end
        end
    end
end

return RollingStockUpdater
