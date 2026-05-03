if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimeDataCollector ...") end

---@class RuntimeDataCollector
---@field setLastCycleRuntimeEntries fun(runtimeEntries: RuntimeMetricEntries|nil, publishable: boolean):nil
---@field collectRuntimeEntries fun():table<string, RuntimeMetricEntry>|nil
---@field reset fun():nil
local RuntimeDataCollector = {}

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
function RuntimeDataCollector.setLastCycleRuntimeEntries(runtimeEntries, publishable)
    if runtimeEntries then
        lastCycleRuntimeEntries = deepCopy(runtimeEntries)
    else
        lastCycleRuntimeEntries = nil
    end
    lastCycleRuntimeEntriesPublishable = publishable == true
end

---@return table<string, RuntimeMetricEntry>|nil
function RuntimeDataCollector.collectRuntimeEntries()
    if not lastCycleRuntimeEntriesPublishable or not lastCycleRuntimeEntries then return nil end

    lastCycleRuntimeEntriesPublishable = false
    return deepCopy(lastCycleRuntimeEntries)
end

function RuntimeDataCollector.reset()
    lastCycleRuntimeEntries = nil
    lastCycleRuntimeEntriesPublishable = false
end

return RuntimeDataCollector
