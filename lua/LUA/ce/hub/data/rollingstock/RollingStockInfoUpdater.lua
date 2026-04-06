if AkDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockInfoUpdater ...") end
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

local RollingStockInfoUpdater = {}
RollingStockInfoUpdater.debug = AkStartWithDebug or false

local function shouldCollect(fieldOptions, fieldName)
    local field = fieldOptions and fieldOptions[fieldName] or nil
    return field == nil or field.collect ~= false
end

local function isSelected(selectedCeTypes, ceType)
    if not selectedCeTypes or next(selectedCeTypes) == nil then return true end
    return selectedCeTypes[ceType] == true
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
    if RollingStockInfoUpdater.debug then
        print("[#RollingStockInfoUpdater] TRAIN DETECTED: " .. trackType .. " -> " .. trackTypeId)
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

function RollingStockInfoUpdater.refresh(allKnownTrains, fieldOptions, selectedCeTypes)
    assert(type(allKnownTrains) == "table", "Need allKnownTrains as table")

    local activeRollingStock = EEPRollingstockGetActive and EEPRollingstockGetActive() or ""
    local rollingStockSelected = isSelected(selectedCeTypes, HubCeTypes.RollingStock)

    for trainName, info in pairs(allKnownTrains) do
        if RollingStockInfoUpdater.debug then
            print(string.format("[#RollingStockInfoUpdater] updating rolling stock of %s", trainName))
        end
        local train = TrainRegistry.forName(trainName)
        ensureTrainRollingStock(train, info)
        ensureTrackInfo(train, info)

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
                if shouldCollect(fieldOptions, "surfaceTexts") and rollingStockSelected then rs:updateTextureTexts() end
                if (shouldCollect(fieldOptions, "rotX")
                        or shouldCollect(fieldOptions, "rotY")
                        or shouldCollect(fieldOptions, "rotZ"))
                    and rollingStockSelected
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

return RollingStockInfoUpdater
