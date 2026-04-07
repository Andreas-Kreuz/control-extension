if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockUpdater ...") end

local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local TrainDiscoveryCache = require("ce.hub.data.trains.TrainDiscoveryCache")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local RollingStockUpdater = {}
RollingStockUpdater.debug = CeStartWithDebug or false

local function shouldCollect(fieldOptions, fieldName)
    local field = fieldOptions and fieldOptions[fieldName] or nil
    return field == nil or field.collect ~= false
end

function RollingStockUpdater.runUpdate(options)
    local opts = options or {}
    local fieldOptions = opts.fields or {}
    local ceTypeOptions = opts.ceTypes and opts.ceTypes.rollingStock or nil
    local rollingStockActive = SyncPolicy.isActive(ceTypeOptions, true)
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
                if shouldCollect(fieldOptions, "trainName") then rs:setTrainName(train.name) end
                if shouldCollect(fieldOptions, "positionInTrain") then rs:setPositionInTrain(positionInTrain) end
                if shouldCollect(fieldOptions, "trackType") and info.trackType then rs:setTrackType(info.trackType) end
                if shouldCollect(fieldOptions, "couplingFront") then
                    local ok, couplingFront = EEPRollingstockGetCouplingFront(rs.rollingStockName)
                    if ok then rs:setCouplingFront(couplingFront) end
                end
                if shouldCollect(fieldOptions, "couplingRear") then
                    local ok, couplingRear = EEPRollingstockGetCouplingRear(rs.rollingStockName)
                    if ok then rs:setCouplingRear(couplingRear) end
                end
                if shouldCollect(fieldOptions, "length") then
                    local _, length = EEPRollingstockGetLength(rs.rollingStockName)
                    if length then rs:setLength(length) end
                end
                if shouldCollect(fieldOptions, "propelled") then
                    local _, propelled = EEPRollingstockGetMotor(rs.rollingStockName)
                    rs:setPropelled(propelled ~= false)
                end
                if shouldCollect(fieldOptions, "modelType") or shouldCollect(fieldOptions, "modelTypeText") then
                    local _, modelType = EEPRollingstockGetModelType(rs.rollingStockName)
                    if modelType then rs:setModelType(modelType) end
                end
                if shouldCollect(fieldOptions, "tag") or shouldCollect(fieldOptions, "nr") then
                    local _, tag = EEPRollingstockGetTagText(rs.rollingStockName)
                    rs:setTag(tag or "")
                end
                if shouldCollect(fieldOptions, "hookStatus") and EEPRollingstockGetHook then
                    local ok, hookStatus = EEPRollingstockGetHook(rs.rollingStockName)
                    if ok then rs:setHookStatus(hookStatus) end
                end
                if shouldCollect(fieldOptions, "hookGlueMode") and EEPRollingstockGetHookGlue then
                    local ok, hookGlueMode = EEPRollingstockGetHookGlue(rs.rollingStockName)
                    if ok then rs:setHookGlueMode(hookGlueMode) end
                end
                if shouldCollect(fieldOptions, "orientationForward") and EEPRollingstockGetOrientation then
                    local ok, orientationForward = EEPRollingstockGetOrientation(rs.rollingStockName)
                    if ok then rs:setOrientationForward(orientationForward == true) end
                end
                if shouldCollect(fieldOptions, "smoke") and EEPRollingstockGetSmoke then
                    local ok, smoke = EEPRollingstockGetSmoke(rs.rollingStockName)
                    if ok then rs:setSmoke(smoke) end
                end
                if shouldCollect(fieldOptions, "active") then
                    rs:setActive(activeRollingStock == rs.rollingStockName)
                end
                if shouldCollect(fieldOptions, "surfaceTexts") and rollingStockActive then rs:updateTextureTexts() end
                if (shouldCollect(fieldOptions, "rotX")
                        or shouldCollect(fieldOptions, "rotY")
                        or shouldCollect(fieldOptions, "rotZ"))
                    and rollingStockActive
                    and _G.EEPRollingstockGetRotation then
                    local ok, rotX, rotY, rotZ = _G.EEPRollingstockGetRotation(rs.rollingStockName)
                    if ok then rs:setRotation(rotX, rotY, rotZ) end
                end
                if info.dirty or info.moved or info.created then
                    if shouldCollect(fieldOptions, "trackId")
                        or shouldCollect(fieldOptions, "trackDistance")
                        or shouldCollect(fieldOptions, "trackDirection")
                        or shouldCollect(fieldOptions, "trackSystem") then
                        local _, trackId, trackDistance, trackDirection, trackSystem = EEPRollingstockGetTrack(
                            rs.rollingStockName)
                        rs:setTrack(trackId, trackDistance, trackDirection, trackSystem)
                    end
                    if shouldCollect(fieldOptions, "posX")
                        or shouldCollect(fieldOptions, "posY")
                        or shouldCollect(fieldOptions, "posZ") then
                        local hasPos, posX, posY, posZ = EEPRollingstockGetPosition(rs.rollingStockName)
                        if hasPos then
                            rs:setPosition(tonumber(posX) or -1, tonumber(posY) or -1, tonumber(posZ) or -1)
                        end
                    end
                    if shouldCollect(fieldOptions, "mileage") then
                        local hasMileage, mileage = _G.EEPRollingstockGetMileage(rs.rollingStockName)
                        if hasMileage then rs:setMileage(mileage) end
                    end
                end
            end
        end
    end
end

return RollingStockUpdater
