if CeDebugLoad then print("[#Start] Loading ce.databridge.ServerEventFileTransport ...") end

local ServerExchangeFileIo = require("ce.databridge.ServerExchangeFileIo")

local ServerEventFileTransport = {}
ServerEventFileTransport.name = "file"

function ServerEventFileTransport.isReady()
    return ServerExchangeFileIo.isServerReady()
end

function ServerEventFileTransport.getSessionId()
    return "file"
end

function ServerEventFileTransport.writeOutgoingEvents(jsonData)
    return ServerExchangeFileIo.writeOutgoingEvents(jsonData) == true
end

return ServerEventFileTransport
