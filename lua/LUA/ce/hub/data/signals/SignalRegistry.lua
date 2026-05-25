if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalRegistry ...") end

---@class SignalRegistry
---@field has fun(signalId: number):boolean
---@field add fun(signal: Signal):nil
---@field replaceAll fun(signals: Signal[]):nil
---@field remove fun(signalId: number):nil
---@field get fun(signalId: number):Signal|nil
---@field getOrCreate fun(signalId: number):Signal
---@field getRevision fun():number
---@field getAll fun():table<number, Signal>
local SignalRegistry = {}

local Signal = require("ce.hub.data.signals.Signal")

---@type table<number, Signal>
local allSignals = {}
local revision = 0

local function markChanged()
    revision = revision + 1
end

function SignalRegistry.has(signalId)
    return allSignals[signalId] ~= nil
end

function SignalRegistry.add(signal)
    if allSignals[signal.id] == signal then return end
    allSignals[signal.id] = signal
    markChanged()
end

function SignalRegistry.replaceAll(signals)
    local nextSignals = {}
    for _, signal in ipairs(signals or {}) do
        nextSignals[signal.id] = signal
    end

    local changed = false
    for signalId, signal in pairs(nextSignals) do
        if allSignals[signalId] ~= signal then
            changed = true
            break
        end
    end
    if not changed then
        for signalId in pairs(allSignals) do
            if nextSignals[signalId] == nil then
                changed = true
                break
            end
        end
    end

    allSignals = nextSignals
    if changed then markChanged() end
end

function SignalRegistry.remove(signalId)
    if allSignals[signalId] == nil then return end
    allSignals[signalId] = nil
    markChanged()
end

function SignalRegistry.get(signalId)
    return allSignals[signalId]
end

function SignalRegistry.getOrCreate(signalId)
    local signal = SignalRegistry.get(signalId)
    if signal then return signal end

    signal = Signal:new(signalId)
    SignalRegistry.add(signal)
    return signal
end

function SignalRegistry.getRevision()
    return revision
end

function SignalRegistry.getAll()
    local copy = {}
    for signalId, signal in pairs(allSignals) do copy[signalId] = signal end
    return copy
end

return SignalRegistry
