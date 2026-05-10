if CeDebugLoad then print("[#Start] Loading ce.hub.data.routes.Route ...") end

---@class Route
---@field id number
---@field name string
local Route = {}

---@param id number
---@param name string
---@return Route
function Route:new(id, name)
    local o = {
        id = id,
        name = name
    }
    self.__index = self
    setmetatable(o, self)
    return o
end

function Route:getName() return self.name end

return Route
