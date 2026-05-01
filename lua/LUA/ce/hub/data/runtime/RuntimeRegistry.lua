if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimeRegistry ...") end

---@class RuntimeRegistry
---@field set fun(entries: table<string, RuntimeEntry>|nil):nil
---@field get fun():table<string, RuntimeEntry>|nil
local RuntimeRegistry = {}

local runtimeEntries = nil

function RuntimeRegistry.set(entries)
    runtimeEntries = entries
end

function RuntimeRegistry.get()
    return runtimeEntries
end

return RuntimeRegistry
