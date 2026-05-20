if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalRegistry ...") end

---@class SignalRegistry
---@field has fun(signalId: number):boolean
---@field add fun(signal: Signal):nil
---@field replaceAll fun(signals: Signal[]):nil
---@field get fun(signalId: number):Signal|nil
---@field getAll fun():table<number, Signal>
local SignalRegistry = {}

---@type table<number, Signal>
local allSignals = {}

function SignalRegistry.has(signalId)
    return allSignals[signalId] ~= nil
end

function SignalRegistry.add(signal)
    allSignals[signal.id] = signal
end

function SignalRegistry.replaceAll(signals)
    allSignals = {}
    for _, signal in ipairs(signals or {}) do
        allSignals[signal.id] = signal
    end
end

function SignalRegistry.get(signalId)
    return allSignals[signalId]
end

function SignalRegistry.getAll()
    local copy = {}
    for signalId, signal in pairs(allSignals) do copy[signalId] = signal end
    return copy
end

return SignalRegistry
