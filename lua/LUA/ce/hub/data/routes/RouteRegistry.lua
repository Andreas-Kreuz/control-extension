if CeDebugLoad then print("[#Start] Loading ce.hub.data.routes.RouteRegistry ...") end

local RouteRegistry = {}

---@type table<number, Route>
local allRoutes = {}
local dirty = true

local function routesEqual(left, right)
    local count = 0
    for id, route in pairs(left or {}) do
        count = count + 1
        if not right[id] or right[id].name ~= route.name then return false end
    end
    for _ in pairs(right or {}) do
        count = count - 1
    end
    return count == 0
end

function RouteRegistry.replaceAll(routes)
    local nextRoutes = {}
    for _, route in ipairs(routes or {}) do
        nextRoutes[route.id] = route
    end

    if not routesEqual(allRoutes, nextRoutes) then
        allRoutes = nextRoutes
        dirty = true
    end
end

function RouteRegistry.getAll()
    local copy = {}
    for id, route in pairs(allRoutes) do copy[id] = route end
    return copy
end

function RouteRegistry.isDirty()
    return dirty
end

function RouteRegistry.markClean()
    dirty = false
end

return RouteRegistry
