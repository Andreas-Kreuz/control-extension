if CeDebugLoad then print("[#Start] Loading ce.hub.util.TimedExecution ...") end

local ProtectedExecution = require("ce.hub.util.ProtectedExecution")
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

local function executeProtectedAndStoreRunTimeInternal(group, func, ...)
    if not func then return true end

    local t0 = os.clock()
    local result = { ProtectedExecution.run(group, func, ...) }
    RuntimeMetrics.storeRunTime(group, os.clock() - t0)

    return table.unpack(result)
end

function TimedExecution.runProtectedTimed(group, func, ...)
    return executeProtectedAndStoreRunTimeInternal(group, func, ...)
end

function TimedExecution.runProtectedTimedAndKeep(group, func, ...)
    RuntimeMetrics.keepGroup(group)
    return executeProtectedAndStoreRunTimeInternal(group, func, ...)
end

--- Indirect call of EEP function (or any other function) including time measurement
function TimedExecution.executeAndStoreRunTime(func, group, ...)
    return executeAndStoreRunTimeInternal(group, func, ...)
end

return TimedExecution
