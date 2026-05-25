if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalUpdater ...") end

local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local WaitingOnSignalRegistry = require("ce.hub.data.signals.WaitingOnSignalRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

---@class SignalUpdater
---@field runUpdate fun(options: table|nil):nil
local SignalUpdater = {}

local waitingVehicleNameUpdateInterval = 10
local updateCount = 0
local previousWaitingCounts = {}

local function collectWaitingOnSignals(signals)
    local waitingOnSignals = {}
    for _, signal in pairs(signals) do
        local count = signal:peekWaitingVehiclesCount()
        if count and count > 0 then
            for pos = 1, count do
                local vehicleName = signal:pullWaitingVehicleName(pos)
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
    local updateWaitingVehicleNames = shouldUpdateWaitingVehicleNames(HubOptionsRegistry)

    for _, signal in pairs(signals) do
        local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Signal, tostring(signal.id))
        local previousWaitingCount = previousWaitingCounts[signal.id] or 0
        if SyncPolicy.shouldUpdateField(fields, "position", isSelected) then
            signal:pullPosition()
        end
        if SyncPolicy.shouldUpdateField(fields, "waitingVehiclesCount", isSelected) then
            local waitingCount = signal:pullWaitingVehiclesCount() or 0
            previousWaitingCounts[signal.id] = waitingCount
            if updateWaitingVehicleNames and watchedSignalIds[signal.id] and previousWaitingCount ~= waitingCount then
                changedWatchedSignalIds[signal.id] = true
            end
        end

        if SyncPolicy.shouldUpdateField(fields, "tag", isSelected) then
            signal:pullTag()
        end
        if SyncPolicy.shouldUpdateField(fields, "stopDistance", isSelected) then
            signal:pullStopDistance()
        end
        if SyncPolicy.shouldUpdateField(fields, "itemName", isSelected) then
            signal:pullItemName()
        end
        if SyncPolicy.shouldUpdateField(fields, "functions", isSelected) then
            signal:pullFunctions()
        end
    end

    if updateWaitingVehicleNames then
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
