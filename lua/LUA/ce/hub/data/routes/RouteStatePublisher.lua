if CeDebugLoad then print("[#Start] Loading ce.hub.data.routes.RouteStatePublisher ...") end

local RoutePublisher = require("ce.hub.data.routes.RoutePublisher")

local RouteStatePublisher = {}
RouteStatePublisher.enabled = true
local initialized = false
RouteStatePublisher.name = "ce.hub.data.routes.RouteStatePublisher"
RouteStatePublisher.ceTypes = require("ce.hub.data.HubCeTypes").Route

function RouteStatePublisher.initialize()
    if not RouteStatePublisher.enabled or initialized then return end
    initialized = true
end

function RouteStatePublisher.syncState()
    if not RouteStatePublisher.enabled then return end
    if not initialized then RouteStatePublisher.initialize() end
    RoutePublisher.syncState()
end

return RouteStatePublisher
