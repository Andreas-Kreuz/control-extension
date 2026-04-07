if CeDebugLoad then print("[#Start] Loading ce.hub.publish.ServerEventDispatcher ...") end

local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local ServerEventBuffer = require("ce.databridge.ServerEventBuffer")

local ServerEventDispatcher = {}

function ServerEventDispatcher.fireEvent(event)
    if event.type == "CompleteReset" then
        ServerEventBuffer.fireEvent(event)
        return
    end

    local payload = event.payload or {}
    local ceType = payload.ceType
    if not ceType then
        ServerEventBuffer.fireEvent(event)
        return
    end

    if not HubOptionsRegistry.isCeTypePublishEnabled(ceType) then return end

    ServerEventBuffer.fireEvent(event)
end

return ServerEventDispatcher
