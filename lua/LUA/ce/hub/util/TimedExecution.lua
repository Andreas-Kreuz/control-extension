if CeDebugLoad then print("[#Start] Loading ce.hub.util.TimedExecution ...") end

local RuntimeMetrics = require("ce.hub.data.runtime.RuntimeMetrics")

---@class TimedExecution
local TimedExecution = {}

local function executeAndStoreRunTimeInternal(group, func, ...)
    if not func then return end

    local t0 = os.clock()
    local result = { func(...) }
    RuntimeMetrics.storeRunTime(group, os.clock() - t0)

    return table.unpack(result)
end

function TimedExecution.runTimed(group, func, ...)
    return executeAndStoreRunTimeInternal(group, func, ...)
end

function TimedExecution.runTimedAndKeep(group, func, ...)
    RuntimeMetrics.keepGroup(group)
    return executeAndStoreRunTimeInternal(group, func, ...)
end

--- Indirect call of EEP function (or any other function) including time measurement
function TimedExecution.executeAndStoreRunTime(func, group, ...)
    return executeAndStoreRunTimeInternal(group, func, ...)
end

return TimedExecution
