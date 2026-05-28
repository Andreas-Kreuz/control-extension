if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimeUpdater ...") end

local RuntimeRegistry = require("ce.hub.data.runtime.RuntimeRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local RuntimeUpdater = {}

---@alias RuntimeMetricEntries table<string, RuntimeMetricEntry>

---@type table<string, RuntimeMetricEntry>|nil
local lastCycleRuntimeEntries = nil
local lastCycleRuntimeEntriesPublishable = false

---@generic T
---@param value T
---@return T
local function deepCopy(value)
    if type(value) ~= "table" then return value end

    local copy = {}
    for key, entry in pairs(value) do copy[key] = deepCopy(entry) end
    return copy
end

---@param runtimeEntries table<string, RuntimeMetricEntry>|nil
---@param publishable boolean
function RuntimeUpdater.setLastCycleRuntimeEntries(runtimeEntries, publishable)
    if runtimeEntries then
        lastCycleRuntimeEntries = deepCopy(runtimeEntries)
    else
        lastCycleRuntimeEntries = nil
    end
    lastCycleRuntimeEntriesPublishable = publishable == true
end

---@return table<string, RuntimeMetricEntry>|nil
local function consumeRuntimeEntries()
    if not lastCycleRuntimeEntriesPublishable or not lastCycleRuntimeEntries then return nil end

    lastCycleRuntimeEntriesPublishable = false
    return deepCopy(lastCycleRuntimeEntries)
end

function RuntimeUpdater.reset()
    lastCycleRuntimeEntries = nil
    lastCycleRuntimeEntriesPublishable = false
end

function RuntimeUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("runtimes") then return end
    RuntimeRegistry.set(consumeRuntimeEntries())
end

return RuntimeUpdater