if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalRegistry ...") end

local SignalRegistry = {}

---@type table<number, Signal>
local allSignals = {}

function SignalRegistry.has(signalId)
    return allSignals[signalId] ~= nil
end

function SignalRegistry.add(signal)
    allSignals[signal.id] = signal
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
