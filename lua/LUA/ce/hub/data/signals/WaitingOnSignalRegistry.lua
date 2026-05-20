if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.WaitingOnSignalRegistry ...") end

local WaitingOnSignal = require("ce.hub.data.signals.WaitingOnSignal")

local WaitingOnSignalRegistry = {}

local waitingOnSignals = {}
local removedIds = {}
local watchedSignalIds = {}

local function normalizeSignalId(signalId)
    local numericSignalId = tonumber(signalId)
    assert(numericSignalId, "Need 'signalId' as number")
    return numericSignalId
end

local function applyEntries(entries, removeForSignalIds)
    local currentIds = {}

    for i = 1, #(entries or {}) do
        local rawEntry = entries[i]
        local entryId = rawEntry.id
        currentIds[entryId] = true

        if waitingOnSignals[entryId] then
            waitingOnSignals[entryId]:update(rawEntry)
        else
            waitingOnSignals[entryId] = WaitingOnSignal:new(rawEntry)
        end
    end

    for entryId, waitingOnSignal in pairs(waitingOnSignals) do
        if not currentIds[entryId] and (not removeForSignalIds or removeForSignalIds[waitingOnSignal.signalId]) then
            waitingOnSignals[entryId] = nil
            removedIds[entryId] = true
        end
    end
end

function WaitingOnSignalRegistry.set(entries)
    applyEntries(entries)
end

function WaitingOnSignalRegistry.setForSignals(entries, signalIds)
    local removeForSignalIds = {}
    for signalId in pairs(signalIds or {}) do removeForSignalIds[normalizeSignalId(signalId)] = true end
    applyEntries(entries, removeForSignalIds)
end

function WaitingOnSignalRegistry.watchSignal(signalId)
    watchedSignalIds[normalizeSignalId(signalId)] = true
end

function WaitingOnSignalRegistry.getWatchedSignalIds()
    local copy = {}
    for signalId in pairs(watchedSignalIds) do copy[signalId] = true end
    return copy
end

function WaitingOnSignalRegistry.get(id)
    assert(type(id) == "string", "Need 'id' as string")
    return waitingOnSignals[id]
end

function WaitingOnSignalRegistry.getAll()
    return waitingOnSignals
end

function WaitingOnSignalRegistry.getRemovedIds()
    local copy = {}
    for entryId in pairs(removedIds) do copy[entryId] = true end
    return copy
end

function WaitingOnSignalRegistry.clearRemoved()
    removedIds = {}
end

return WaitingOnSignalRegistry
