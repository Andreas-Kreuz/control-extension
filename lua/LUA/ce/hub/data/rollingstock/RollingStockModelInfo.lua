if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockModelInfo ...") end

local TableUtils = require("ce.hub.util.TableUtils")

local RollingStockModelInfo = {}

function RollingStockModelInfo:new(o)
    o = o or {}
    o.axisNames = o.axisNames or {}
    o.textureNames = o.textureNames or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

function RollingStockModelInfo:getAxisNames()
    return TableUtils.deepcopy(self.axisNames or {})
end

function RollingStockModelInfo:getTextureNames()
    return TableUtils.deepcopy(self.textureNames or {})
end

return RollingStockModelInfo
