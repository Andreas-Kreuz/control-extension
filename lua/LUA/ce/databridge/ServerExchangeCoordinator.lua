-- Use this class in XxxBridgeConnector to register commands
if CeDebugLoad then print("[#Start] Loading ce.databridge.ServerExchangeCoordinator ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local ServerEventBuffer = require("ce.databridge.ServerEventBuffer")
local ServerExchangeFileIo = require("ce.databridge.ServerExchangeFileIo")
local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
local os = require("os")

local ServerExchangeCoordinator = {}
ServerExchangeCoordinator.debug = CeStartWithDebug or false
local initialized = false

-- checkServerStatus:
-- true: Check status of EEP-Web Server before updating the json file
-- false: Update json file without checking if the EEP-Web Server is ready
ServerExchangeCoordinator.checkServerStatus = true

function ServerExchangeCoordinator.registerAllowedCommand(fName, f)
    IncomingCommandExecutor.registerAllowedCommand(fName, f)
end

function ServerExchangeCoordinator.initialize(serverShallBeUsed)
    if initialized then return end
    DataChangeBus.initialize()

    -- Print hint if server should be used but is not ready
    if serverShallBeUsed and not ServerExchangeFileIo.isServerRunning() then
        print(
            "HINWEIS: Starte LUA/ce/control-extension-server.exe im EEP-Verzeichnis, " ..
            "wenn du den Web Server der Control Extension für EEP verwenden willst."
        )
    end

    initialized = true
end

function ServerExchangeCoordinator.isServerReady()
    return not ServerExchangeCoordinator.checkServerStatus or ServerExchangeFileIo.isServerReady()
end

--- Main function of this module. Is called by MainLoopRunner.
function ServerExchangeCoordinator.runServerOutputCycle()
    local overallTime0 = os.clock()
    local encodedEvents = ServerEventBuffer.drainBufferedEvents()
    local overallTime1 = os.clock()
    ServerExchangeFileIo.writeOutgoingEvents(encodedEvents)
    local overallTime2 = os.clock()

    local encodeTime = overallTime1 - overallTime0
    local writeTime = overallTime2 - overallTime1
    local totalTime = overallTime2 - overallTime0

    if ServerExchangeCoordinator.debug then
        print(string.format(
            "INFO: [#ServerExchangeCoordinator] runServerOutputCycle() time is %3.0f ms" ..
            " --- encode: %.0f ms, write: %.0f ms",
            totalTime * 1000, encodeTime * 1000, writeTime * 1000))
    end

    return { encodeTime = encodeTime, writeTime = writeTime, totalTime = totalTime }
end

return ServerExchangeCoordinator
