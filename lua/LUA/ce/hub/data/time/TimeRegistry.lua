if CeDebugLoad then print("[#Start] Loading ce.hub.data.time.TimeRegistry ...") end

local TimeData = require("ce.hub.data.time.TimeData")

local TimeRegistry = {}

local timeData = nil

function TimeRegistry.set(entries, updatedFields)
    local rawTimeData = entries and entries[1] or nil
    if not rawTimeData then
        timeData = nil
        return
    end

    if timeData then
        timeData:update(rawTimeData, updatedFields)
    else
        timeData = TimeData:new(rawTimeData)
    end
end

function TimeRegistry.get()
    return timeData
end

return TimeRegistry
