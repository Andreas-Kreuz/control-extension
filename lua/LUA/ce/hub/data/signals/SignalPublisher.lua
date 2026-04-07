if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local SignalDtoFactory = require("ce.hub.data.signals.SignalDtoFactory")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

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

function SignalPublisher.syncState(options)
    local opts = options or {}
    local fields = opts.fields or {}

    for _, signal in pairs(SignalRegistry.getAll()) do
        if signal.needsFullSend or signal:hasDirtyFields() then
            DataChangeBus.fireDataChanged(SignalDtoFactory.createSignalDto(signal))
            signal.needsFullSend = false
            signal:resetDirty()
        end
    end

    if SyncPolicy.shouldCollect(fields.waitingTrains) then
        DataChangeBus.fireListChange(SignalDtoFactory.createWaitingOnSignalDtoList(collectWaitingOnSignals()))
    end

    return {}
end

return SignalPublisher
