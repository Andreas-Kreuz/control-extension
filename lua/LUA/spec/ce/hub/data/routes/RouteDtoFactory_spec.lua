insulate("ce.hub.data.routes.RouteDtoFactory", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.routes.Route")
        clearModule("ce.hub.data.routes.RouteDtoFactory")
    end)

    it("creates route DTOs with ceType, id and name", function ()
        local Route = require("ce.hub.data.routes.Route")
        local RouteDtoFactory = require("ce.hub.data.routes.RouteDtoFactory")

        local route = Route:new(2, "Linie 285 Schnalzlaut")
        local ceType, keyId, key, dto = RouteDtoFactory.createFullDto(route)

        assert.equals("ce.hub.Route", ceType)
        assert.equals("id", keyId)
        assert.equals(2, key)
        assert.same({
                        ceType = "ce.hub.Route",
                        id = 2,
                        name = "Linie 285 Schnalzlaut"
                    }, dto)
    end)

    it("creates sorted route DTO lists", function ()
        local Route = require("ce.hub.data.routes.Route")
        local RouteDtoFactory = require("ce.hub.data.routes.RouteDtoFactory")

        local ceType, keyId, dtos = RouteDtoFactory.createRouteDtoList({
            [2] = Route:new(2, "Route B"),
            [1] = Route:new(1, "Route A")
        })

        assert.equals("ce.hub.Route", ceType)
        assert.equals("id", keyId)
        assert.same({
                        { ceType = "ce.hub.Route", id = 1, name = "Route A" },
                        { ceType = "ce.hub.Route", id = 2, name = "Route B" }
                    }, dtos)
    end)
end)
