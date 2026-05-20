if CeDebugLoad then print("[#Start] Loading ce.hub.data.routes.RouteDiscovery ...") end

local Route = require("ce.hub.data.routes.Route")
local RouteRegistry = require("ce.hub.data.routes.RouteRegistry")

local RouteDiscovery = {}

function RouteDiscovery.initFromAnl3(tableOfAnl3)
    local routes = {}
    if tableOfAnl3 then
        for _, entry in ipairs(tableOfAnl3.routes or {}) do
            if entry.id and entry.name then
                routes[#routes + 1] = Route:new(entry.id, entry.name)
            end
        end
    end
    RouteRegistry.replaceAll(routes)
end

return RouteDiscovery
