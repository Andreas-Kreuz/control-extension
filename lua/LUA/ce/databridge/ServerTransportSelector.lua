if CeDebugLoad then print("[#Start] Loading ce.databridge.ServerTransportSelector ...") end

local ServerEventFileTransport = require("ce.databridge.ServerEventFileTransport")
local ServerEventPipeTransport = require("ce.databridge.ServerEventPipeTransport")
local ServerTransportRegistry = require("ce.databridge.ServerTransportRegistry")

local ServerTransportSelector = {}

function ServerTransportSelector.getSelectedTransport()
    if ServerTransportRegistry.getTransport() == "file" then
        return ServerEventFileTransport
    end

    return ServerEventPipeTransport
end

return ServerTransportSelector
