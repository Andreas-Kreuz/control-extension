if CeDebugLoad then print("[#Start] Loading ce.hub.data.time.TimeRegistry ...") end

local TimeRegistry = {}

local times = nil

function TimeRegistry.set(entries)
    times = entries
end

function TimeRegistry.get()
    return times
end

return TimeRegistry
