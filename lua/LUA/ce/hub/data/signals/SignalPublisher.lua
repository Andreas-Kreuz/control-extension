if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local SignalDtoFactory = require("ce.hub.data.signals.SignalDtoFactory")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local SignalPublisher = {}

local EEPGetSignalTrainName = _G.EEPGetSignalTrainName or function () return nil end

local function collectWaitingOnSignals()
    local waitingOnSignals = {}
    for _, signal in pairs(SignalRegistry.getAll()) do
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

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
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
        DataChangeBus.fireListChange(SignalDtoFactory.createWaitingOnSignalDtoList(collectWaitingOnSignals()))
    end

    return {}
end

return SignalPublisher
