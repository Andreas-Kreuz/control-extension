if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.WaitingOnSignalRegistry ...") end

local WaitingOnSignal = require("ce.hub.data.signals.WaitingOnSignal")

local WaitingOnSignalRegistry = {}

local waitingOnSignals = {}
local removedIds = {}

function WaitingOnSignalRegistry.set(entries)
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

    for entryId in pairs(waitingOnSignals) do
        if not currentIds[entryId] then
            waitingOnSignals[entryId] = nil
            removedIds[entryId] = true
        end
    end
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
