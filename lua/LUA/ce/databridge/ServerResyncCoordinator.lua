if CeDebugLoad then print("[#Start] Loading ce.databridge.ServerResyncCoordinator ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")

local ServerResyncCoordinator = {}

local lastReady = false
local lastSessionId

local function requestFullSync()
    DataChangeBus.fireCompleteReset()
    StatePublisherRegistry.requestFullSync()
end

function ServerResyncCoordinator.observe(ready, transport)
    local sessionId = ready and transport.getSessionId and transport.getSessionId() or nil
    local sessionChanged = ready and sessionId ~= nil and sessionId ~= lastSessionId
    local becameReady = ready and not lastReady

    if becameReady or sessionChanged then requestFullSync() end

    lastReady = ready == true
    if ready then lastSessionId = sessionId end
end

function ServerResyncCoordinator.reset()
    lastReady = false
    lastSessionId = nil
end

return ServerResyncCoordinator
