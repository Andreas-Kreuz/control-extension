-- Use this class in XxxBridgeConnector to register commands
if CeDebugLoad then print("[#Start] Loading ce.databridge.ServerExchangeCoordinator ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local ServerResyncCoordinator = require("ce.databridge.ServerResyncCoordinator")
local ServerEventBuffer = require("ce.databridge.ServerEventBuffer")
local ServerExchangeFileIo = require("ce.databridge.ServerExchangeFileIo")
local ServerTransportSelector = require("ce.databridge.ServerTransportSelector")
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
            "HINWEIS: Wenn du die Control Extension App nutzen möchtest, " ..
            "starte LUA/ce/control-extension-server.exe im EEP-Verzeichnis."
        )
    end

    initialized = true
end

function ServerExchangeCoordinator.isServerReady()
    local transport = ServerTransportSelector.getSelectedTransport()
    local ready = not ServerExchangeCoordinator.checkServerStatus or transport.isReady()
    ServerResyncCoordinator.observe(ready, transport)
    return ready
end

--- Main function of this module. Is called by MainLoopRunner.
function ServerExchangeCoordinator.runServerOutputCycle()
    local overallTime0 = os.clock()
    local encodedEvents = ServerEventBuffer.peekBufferedEvents()
    local overallTime1 = os.clock()
    local writeOk = ServerTransportSelector.getSelectedTransport().writeOutgoingEvents(encodedEvents)
    if writeOk then ServerEventBuffer.commitBufferedEvents() end
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
