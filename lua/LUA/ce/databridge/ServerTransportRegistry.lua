if CeDebugLoad then print("[#Start] Loading ce.databridge.ServerTransportRegistry ...") end

local ServerTransportRegistry = {}

local selectedTransport = "pipe"

local function assertValidTransport(transport)
    assert(transport == "file" or transport == "pipe",
           "ControlExtension transport must be \"file\" or \"pipe\"")
end

function ServerTransportRegistry.setTransport(transport)
    assertValidTransport(transport)
    selectedTransport = transport
    return selectedTransport
end

function ServerTransportRegistry.getTransport()
    return selectedTransport
end

function ServerTransportRegistry.reset()
    selectedTransport = "pipe"
end

return ServerTransportRegistry
