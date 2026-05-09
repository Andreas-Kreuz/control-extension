if CeDebugLoad then print("[#Start] Loading ce.hub.util.ProtectedExecution ...") end

local ProtectedExecution = {}

local function traceback(errorValue)
    return debug.traceback(tostring(errorValue), 2)
end

function ProtectedExecution.run(label, fn, ...)
    local args = { ... }
    local result = {
        xpcall(function ()
            return fn(table.unpack(args))
        end, traceback)
    }

    local ok = table.remove(result, 1)
    if not ok then
        print(string.format("[#%s] ERROR: %s", label, tostring(result[1])))
        return false, result[1]
    end

    return true, table.unpack(result)
end

return ProtectedExecution
