if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalUpdater ...") end

local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local WaitingOnSignalRegistry = require("ce.hub.data.signals.WaitingOnSignalRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

---@class SignalUpdater
---@field runUpdate fun(options: table|nil):nil
local SignalUpdater = {}

local EEPGetSignal = _G.EEPGetSignal or function () return 0 end
local EEPSignalGetTagText = _G.EEPSignalGetTagText or function () return false, nil end
local EEPGetSignalTrainsCount = _G.EEPGetSignalTrainsCount or function () return 0 end
local EEPGetSignalTrainName = _G.EEPGetSignalTrainName or function () return nil end
local EEPGetSignalStopDistance = _G.EEPGetSignalStopDistance or function () return false, nil end
local EEPGetSignalItemName = _G.EEPGetSignalItemName or function () return false, nil end
local EEPGetSignalFunctions = _G.EEPGetSignalFunctions or function () return false, 0 end
local EEPGetSignalFunction = _G.EEPGetSignalFunction or function () return false, nil end
local waitingVehicleNameUpdateInterval = 10
local updateCount = 0
local previousWaitingCounts = {}

local function readFunctions(id, position)
    local functionsOk, functionCount = EEPGetSignalFunctions(id)
    if not functionsOk or not functionCount or functionCount == 0 then return nil, nil end

    local fns = {}
    local activeFunction = nil
    for selIndex = 1, functionCount do
        local ok, fn = EEPGetSignalFunction(id, selIndex)
        if ok then
            local fnValue = tostring(fn)
            fns[#fns + 1] = fnValue
            if position == fn then activeFunction = fnValue end
        end
    end

    return #fns > 0 and fns or nil, activeFunction
end

local function collectWaitingOnSignals(signals)
    local waitingOnSignals = {}
    for _, signal in pairs(signals) do
        local count = signal:getWaitingVehiclesCount()
        if count and count > 0 then
            for pos = 1, count do
                local vehicleName = EEPGetSignalTrainName(signal.id, pos)
                waitingOnSignals[#waitingOnSignals + 1] = {
                    id = signal.id .. "-" .. pos,
                    signalId = signal.id,
                    waitingPosition = pos,
                    vehicleName = vehicleName or "",
                    waitingCount = count
                }
            end
        end
    end
    return waitingOnSignals
end

local function signalsForIds(signalIds)
    local signals = {}
    for signalId in pairs(signalIds or {}) do
        local signal = SignalRegistry.get(signalId)
        if signal then signals[signalId] = signal end
    end
    return signals
end

local function shouldUpdateWaitingVehicleNames(HubOptionsRegistry)
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("waitingOnSignals") then return false end
    local fields = HubOptionsRegistry.getFieldUpdatePolicies("waitingOnSignals")
    return SyncPolicy.shouldUpdateField(fields, "vehicleName", false)
end

function SignalUpdater.runUpdate()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")
    if not HubOptionsRegistry.isAnyDiscoveryAndUpdateEnabled("signals", "waitingOnSignals") then return end
    local fields = HubOptionsRegistry.getFieldUpdatePolicies("signals")
    local signals = SignalRegistry.getAll()
    local changedWatchedSignalIds = {}
    local watchedSignalIds = WaitingOnSignalRegistry.getWatchedSignalIds()

    for _, signal in pairs(signals) do
        local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Signal, tostring(signal.id))
        local position = EEPGetSignal(signal.id)
        local previousWaitingCount = previousWaitingCounts[signal.id] or 0
        local waitingCount = EEPGetSignalTrainsCount(signal.id) or 0
        signal:setPosition(position)
        signal:setWaitingVehiclesCount(waitingCount)
        previousWaitingCounts[signal.id] = waitingCount
        if watchedSignalIds[signal.id] and previousWaitingCount ~= waitingCount then
            changedWatchedSignalIds[signal.id] = true
        end

        if SyncPolicy.shouldUpdateField(fields, "tag", isSelected) then
            local _, tag = EEPSignalGetTagText(signal.id)
            signal:setTag(tag or "")
        end
        if SyncPolicy.shouldUpdateField(fields, "stopDistance", isSelected) then
            local ok, stopDistance = EEPGetSignalStopDistance(signal.id)
            signal:setStopDistance(ok and stopDistance or nil)
        end
        if SyncPolicy.shouldUpdateField(fields, "itemName", isSelected) then
            local ok, itemName = EEPGetSignalItemName(signal.id, false)
            local okPath, itemNameWithModelPath = EEPGetSignalItemName(signal.id, true)
            signal:setItemName(ok and itemName or nil, okPath and itemNameWithModelPath or nil)
        end
        if SyncPolicy.shouldUpdateField(fields, "functions", isSelected) then
            local signalFunctions, activeFunction = readFunctions(signal.id, position)
            signal:setFunctions(signalFunctions, activeFunction)
        end
    end

    if shouldUpdateWaitingVehicleNames(HubOptionsRegistry) then
        if updateCount % waitingVehicleNameUpdateInterval == 0 then
            WaitingOnSignalRegistry.set(collectWaitingOnSignals(signals))
        elseif next(changedWatchedSignalIds) then
            local changedSignals = signalsForIds(changedWatchedSignalIds)
            WaitingOnSignalRegistry.setForSignals(collectWaitingOnSignals(changedSignals), changedWatchedSignalIds)
        end
    end

    updateCount = updateCount + 1
end

return SignalUpdater
