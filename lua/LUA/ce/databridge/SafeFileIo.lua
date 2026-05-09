if CeDebugLoad then print("[#Start] Loading ce.databridge.SafeFileIo ...") end

local ProtectedExecution = require("ce.hub.util.ProtectedExecution")

local SafeFileIo = {}

function SafeFileIo.run(label, fileName, fn, ...)
    local result = { ProtectedExecution.run(label, fn, ...) }
    local ok = table.remove(result, 1)
    if not ok then
        print(string.format("[#%s] FILE ERROR: %s", label, tostring(fileName)))
        return false, table.unpack(result)
    end

    return true, table.unpack(result)
end

return SafeFileIo
