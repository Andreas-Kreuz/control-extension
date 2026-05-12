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
    for _, waitingOnSignal in pairs(WaitingOnSignalRegistry.getAll()) do
        if waitingOnSignal.needsFullSend then
            DataChangeBus.fireDataChanged(SignalDtoFactory.createWaitingOnSignalDto(waitingOnSignal))
            waitingOnSignal.needsFullSend = false
            waitingOnSignal:resetDirty()
        elseif waitingOnSignal:hasDirtyFields() then
            local ceType, keyId, key, dto = SignalDtoFactory.createWaitingOnSignalPatchDto(waitingOnSignal,
                                                                                           waitingOnSignal.dirtyFields)
            if hasPayloadFields(dto) then DataChangeBus.fireDataChanged(ceType, keyId, key, dto) end
            waitingOnSignal:resetDirty()
        end
    end
end

function SignalPublisher.syncState()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")

    for _, signal in pairs(SignalRegistry.getAll()) do
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
