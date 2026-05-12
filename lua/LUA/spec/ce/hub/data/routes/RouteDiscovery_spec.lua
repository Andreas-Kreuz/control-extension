insulate("ce.hub.data.routes.RouteDiscovery", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local TEMP_FILE = "spec/ce/hub/data/routes/_route_anl3_test_tmp.xml"

    local function writeTempXml(content)
        local f = assert(io.open(TEMP_FILE, "w"))
        f:write(content)
        f:close()
        return TEMP_FILE
    end

    local function discoverRoutes(optionsXml)
        _G.EEPLoadData = _G.EEPLoadData or function () return false, nil end

        clearModule("ce.hub.data.routes.Route")
        clearModule("ce.hub.data.routes.RouteRegistry")
        clearModule("ce.hub.data.routes.RouteDiscovery")
        clearModule("ce.hub.eep.Anl3DiscoveryHelper")
        clearModule("ce.hub.eep.Anl3ToTable")

        local Anl3ToTable = require("ce.hub.eep.Anl3ToTable")
        local Anl3DiscoveryHelper = require("ce.hub.eep.Anl3DiscoveryHelper")
        local RouteRegistry = require("ce.hub.data.routes.RouteRegistry")

        local routeXml = table.concat({
            '<?xml version="1.0" encoding="UTF-8"?>',
            "<sutrackp>",
            optionsXml or "",
            "</sutrackp>"
        }, "")
        local root = assert(Anl3ToTable.loadAnlage(writeTempXml(routeXml)))
        Anl3DiscoveryHelper.fillDiscoveries(root)
        return RouteRegistry.getAll()
    end

    after_each(function ()
        os.remove(TEMP_FILE)
    end)

    it("discovers multiple routes from anl3 options", function ()
        local routes = discoverRoutes(table.concat({
            '<Options RouteItems="2" RouteId_0="1" RouteName_0="Linie 285 Hochbaum"',
            ' RouteId_1="2" RouteName_1="Linie 285 Schnalzlaut"/>'
        }))

        assert.equals("Linie 285 Hochbaum", routes[1]:getName())
        assert.equals("Linie 285 Schnalzlaut", routes[2]:getName())
    end)

    it("keeps routes empty when options are missing", function ()
        local routes = discoverRoutes(nil)

        assert.same({}, routes)
    end)

    it("keeps routes empty when RouteItems is zero", function ()
        local routes = discoverRoutes('<Options RouteItems="0"/>')

        assert.same({}, routes)
    end)
end)
