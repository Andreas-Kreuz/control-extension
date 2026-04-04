if AkDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalStatePublisher ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local Signal = require("ce.hub.data.signals.Signal")
local SignalDtoFactory = require("ce.hub.data.signals.SignalDtoFactory")
local SignalStatePublisher = {}
local enabled = true
local initialized = false
SignalStatePublisher.name = "ce.hub.data.signals.SignalStatePublisher"

local MAX_SIGNALS = 1000
local EEPGetSignal = _G.EEPGetSignal or function() return 0 end
local EEPGetSignalTrainName = _G.EEPGetSignalTrainName or function() return nil end

---@type table<number, Signal>
local allSignals = {}

function SignalStatePublisher.initialize()
    if not enabled or initialized then return end

    for i = 1, MAX_SIGNALS do
        if EEPGetSignal(i) > 0 then
            allSignals[i] = Signal:new(i)
        end
    end

    initialized = true
end

local function collectWaitingOnSignals()
    local waitingOnSignals = {}
    for _, signal in pairs(allSignals) do
        local count = signal.waitingVehiclesCount
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

function SignalStatePublisher.syncState()
    if not enabled then return end

    if not initialized then SignalStatePublisher.initialize() end

    for _, signal in pairs(allSignals) do
        signal:refresh()
        if signal.valuesUpdated then
            signal.valuesUpdated = false
            DataChangeBus.fireDataChanged(SignalDtoFactory.createSignalDto(signal))
        end
    end

    local waitingOnSignals = collectWaitingOnSignals()
    DataChangeBus.fireListChange(SignalDtoFactory.createWaitingOnSignalDtoList(waitingOnSignals))

    return {}
end

return SignalStatePublisher
