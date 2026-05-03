if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimeRegistry ...") end

local RuntimeEntry = require("ce.hub.data.runtime.RuntimeEntry")

---@class RuntimeRegistry
---@field set fun(entries: table<string, RuntimeMetricEntry>|nil):nil
---@field get fun():table<string, RuntimeEntry>|nil
---@field getRemovedIds fun():table<string, boolean>
---@field clearRemoved fun():nil
local RuntimeRegistry = {}

local runtimeEntries = {}
local removedIds = {}

function RuntimeRegistry.set(entries)
    if not entries then return end

    local currentIds = {}

    for runtimeId, rawEntry in pairs(entries) do
        currentIds[runtimeId] = true
        rawEntry.id = rawEntry.id or runtimeId
        if runtimeEntries[runtimeId] then
            runtimeEntries[runtimeId]:update(rawEntry)
        else
            runtimeEntries[runtimeId] = RuntimeEntry:new(rawEntry)
        end
    end

    for runtimeId in pairs(runtimeEntries) do
        if not currentIds[runtimeId] then
            runtimeEntries[runtimeId] = nil
            removedIds[runtimeId] = true
        end
    end
end

function RuntimeRegistry.get()
    return runtimeEntries
end

function RuntimeRegistry.getRemovedIds()
    local copy = {}
    for runtimeId in pairs(removedIds) do copy[runtimeId] = true end
    return copy
end

function RuntimeRegistry.clearRemoved()
    removedIds = {}
end

return RuntimeRegistry
