if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimeRegistry ...") end

local RuntimeRegistry = {}

local runtimeEntries = nil

function RuntimeRegistry.set(entries)
    runtimeEntries = entries
end

function RuntimeRegistry.get()
    return runtimeEntries
end

return RuntimeRegistry
