if CeDebugLoad then print("[#Start] Loading ce.hub.data.routes.RoutePublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local RouteDtoFactory = require("ce.hub.data.routes.RouteDtoFactory")
local RouteRegistry = require("ce.hub.data.routes.RouteRegistry")

local RoutePublisher = {}

function RoutePublisher.syncState()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    if not HubOptionsRegistry.isPublishEnabled("routes") then
        RouteRegistry.markClean()
        return
    end

    if not RouteRegistry.isDirty() then return end

    DataChangeBus.fireListChange(RouteDtoFactory.createRouteDtoList(RouteRegistry.getAll()))
    RouteRegistry.markClean()
end

return RoutePublisher
