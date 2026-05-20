if CeDebugLoad then print("[#Start] Loading ce.databridge.ServerEventBuffer ...") end
local json = require("ce.third-party.json")

local ServerEventBuffer = {}
local recordedEvents = {}

--- All events must be fired with this function, so they are recorded in the list
--- of recordedEvents and can be written to a file later.
---@param event DataChangeEvent the event object string
function ServerEventBuffer.fireEvent(event)
    -- Pack the event into JSON
    local jsonText = json.encode(event)
    table.insert(recordedEvents, jsonText)
end

--- Return a list of all recordedEvents and clear the list
function ServerEventBuffer.drainBufferedEvents()
    local lineSeparatedEvents = table.concat(recordedEvents, "\n")
    recordedEvents = {}
    return lineSeparatedEvents
end

--- Return a list of all recordedEvents without clearing the list.
function ServerEventBuffer.peekBufferedEvents()
    return table.concat(recordedEvents, "\n")
end

--- Clear all recordedEvents after a successful transport write.
function ServerEventBuffer.commitBufferedEvents()
    recordedEvents = {}
end

return ServerEventBuffer
