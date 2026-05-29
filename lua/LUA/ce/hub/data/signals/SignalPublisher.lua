if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local SignalDtoFactory = require("ce.hub.data.signals.SignalDtoFactory")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local WaitingOnSignalRegistry = require("ce.hub.data.signals.WaitingOnSignalRegistry")

---@class SignalPublisher
---@field syncState fun(options: table|nil):nil
local SignalPublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

local function publishWaitingOnSignalRemovals()
    for waitingOnSignalId in pairs(WaitingOnSignalRegistry.getRemovedIds()) do
        DataChangeBus.fireDataRemoved(SignalDtoFactory.createWaitingOnSignalRemovalDto(waitingOnSignalId))
    end
    WaitingOnSignalRegistry.clearRemoved()
end

local function publishWaitingOnSignals()
    local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")

    local waitingOnSignals = WaitingOnSignalRegistry.getAll()
    local hasWaitingOnSignal = false
    local allWaitingOnSignalsNeedFullSend = true

    for _, waitingOnSignal in pairs(waitingOnSignals) do
        hasWaitingOnSignal = true
        if not waitingOnSignal.needsFullSend then allWaitingOnSignalsNeedFullSend = false end
    end

    local function isSelectedWaitingOnSignal(waitingOnSignal)
        return InterestSyncRegistry.isSelected(HubCeTypes.WaitingOnSignal, tostring(waitingOnSignal.id))
    end

    if hasWaitingOnSignal and allWaitingOnSignalsNeedFullSend then
        DataChangeBus.fireListChange(SignalDtoFactory.createWaitingOnSignalDtoList(waitingOnSignals,
                                                                                   isSelectedWaitingOnSignal))
        for _, waitingOnSignal in pairs(waitingOnSignals) do
            waitingOnSignal.needsFullSend = false
            if InterestSyncRegistry.isSelected(HubCeTypes.WaitingOnSignal, tostring(waitingOnSignal.id)) then
                InterestSyncRegistry.markSent(HubCeTypes.WaitingOnSignal, tostring(waitingOnSignal.id))
            end
            waitingOnSignal:resetDirty()
        end
        return
    end

    for _, waitingOnSignal in pairs(waitingOnSignals) do
        local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.WaitingOnSignal, tostring(waitingOnSignal.id))
        local needsInitialSend = InterestSyncRegistry.needsInitialSend(HubCeTypes.WaitingOnSignal,
                                                                       tostring(waitingOnSignal.id))
        if waitingOnSignal.needsFullSend or needsInitialSend then
            DataChangeBus.fireDataChanged(SignalDtoFactory.createWaitingOnSignalDto(waitingOnSignal, isSelected))
            waitingOnSignal.needsFullSend = false
            if isSelected then
                InterestSyncRegistry.markSent(HubCeTypes.WaitingOnSignal, tostring(waitingOnSignal.id))
            end
            waitingOnSignal:resetDirty()
        elseif waitingOnSignal:hasDirtyFields() then
            local ceType, keyId, key, dto = SignalDtoFactory.createWaitingOnSignalPatchDto(waitingOnSignal,
                                                                                           waitingOnSignal.dirtyFields,
                                                                                           isSelected)
            if hasPayloadFields(dto) then DataChangeBus.fireDataChanged(ceType, keyId, key, dto) end
            waitingOnSignal:resetDirty()
        end
    end
end

function SignalPublisher.syncState()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")

    local signals = SignalRegistry.getAll()
    local hasSignal = false
    local allSignalsNeedFullSend = true

    for _, signal in pairs(signals) do
        hasSignal = true
        if not signal.needsFullSend then allSignalsNeedFullSend = false end
    end

    if HubOptionsRegistry.isPublishEnabled("signals") and hasSignal and allSignalsNeedFullSend then
        DataChangeBus.fireListChange(SignalDtoFactory.createSignalDtoList(signals, function (signal)
            return InterestSyncRegistry.isSelected(HubCeTypes.Signal, tostring(signal.id))
        end))
        for _, signal in pairs(signals) do
            signal.needsFullSend = false
            if InterestSyncRegistry.isSelected(HubCeTypes.Signal, tostring(signal.id)) then
                InterestSyncRegistry.markSent(HubCeTypes.Signal, tostring(signal.id))
            end
            signal:resetDirty()
        end
    end

    for _, signal in pairs(signals) do
        local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Signal, tostring(signal.id))
        local needsInitialSend = InterestSyncRegistry.needsInitialSend(HubCeTypes.Signal, tostring(signal.id))
        if HubOptionsRegistry.isPublishEnabled("signals") and
            (signal.needsFullSend or signal:hasDirtyFields() or needsInitialSend) then
            if signal.needsFullSend or needsInitialSend then
                DataChangeBus.fireDataChanged(SignalDtoFactory.createSignalDto(signal, isSelected))
                if isSelected then InterestSyncRegistry.markSent(HubCeTypes.Signal, tostring(signal.id)) end
            else
                local ceType, keyId, key, dto = SignalDtoFactory.createSignalDto(signal, isSelected)
                if hasPayloadFields(dto) then
                    DataChangeBus.fireDataChanged(ceType, keyId, key, dto)
                end
            end
            signal.needsFullSend = false
            signal:resetDirty()
        end
    end

    if HubOptionsRegistry.isPublishEnabled("waitingOnSignals") then
        publishWaitingOnSignalRemovals()
        publishWaitingOnSignals()
    end
end

return SignalPublisher
