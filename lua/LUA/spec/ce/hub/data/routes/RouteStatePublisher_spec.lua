insulate("ce.hub.data.routes.RouteStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.options.HubOptionsRegistry")
        clearModule("ce.hub.data.routes.Route")
        clearModule("ce.hub.data.routes.RouteRegistry")
        clearModule("ce.hub.data.routes.RouteDiscovery")
        clearModule("ce.hub.data.routes.RouteDtoFactory")
        clearModule("ce.hub.data.routes.RoutePublisher")
        clearModule("ce.hub.data.routes.RouteStatePublisher")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.hub.publish.DataChangeBus")
        clearModule("ce.hub.publish.ServerEventDispatcher")
    end)

    it("publishes discovered routes as a ce.hub.Route list", function ()
        local RouteDiscovery = require("ce.hub.data.routes.RouteDiscovery")
        local RouteStatePublisher = require("ce.hub.data.routes.RouteStatePublisher")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")

        RouteDiscovery.initFromAnl3({
            routes = {
                { id = 1, name = "Route A" },
                { id = 2, name = "Route B" }
            }
        })
        RouteStatePublisher.syncState()

        assert.same({
                        ceType = "ce.hub.Route",
                        id = 1,
                        name = "Route A"
                    }, InternalDataStore.get("ce.hub.Route", "1"))
        assert.same({
                        ceType = "ce.hub.Route",
                        id = 2,
                        name = "Route B"
                    }, InternalDataStore.get("ce.hub.Route", "2"))
    end)

    it("publishes an empty route ceType when nothing was discovered", function ()
        local RouteStatePublisher = require("ce.hub.data.routes.RouteStatePublisher")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")

        RouteStatePublisher.syncState()

        assert.same({}, InternalDataStore.getCeType("ce.hub.Route"))
    end)
end)
