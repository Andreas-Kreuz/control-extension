if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockModelInfo ...") end

local TableUtils = require("ce.hub.util.TableUtils")

local RollingStockModelInfo = {}

function RollingStockModelInfo:new(o)
    o = o or {}
    o.axisNames = o.axisNames or {}
    o.axisNamesKnown = o.axisNamesKnown == true
    o.axisNamesByLanguage = o.axisNamesByLanguage or {}
    o.rawAxisNames = o.rawAxisNames or {}
    o.rawAxisNamesByLanguage = o.rawAxisNamesByLanguage or {}
    o.parsed3dmAxes = o.parsed3dmAxes or {}
    o.visibleAxisInfos = o.visibleAxisInfos or {}
    o.textureNames = o.textureNames or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

function RollingStockModelInfo:getAxisNames()
    return TableUtils.deepcopy(self.axisNames or {})
end

function RollingStockModelInfo:getAxisNamesKnown()
    return self.axisNamesKnown == true
end

function RollingStockModelInfo:getAxisNamesByLanguage()
    return TableUtils.deepcopy(self.axisNamesByLanguage or {})
end

function RollingStockModelInfo:getAxisName(axisNumber, language)
    local languageKey = language or "GER"
    local axisNamesByLanguage = self.axisNamesByLanguage or {}
    local languageAxisNames = axisNamesByLanguage[languageKey] or axisNamesByLanguage.GER or {}
    return languageAxisNames[tonumber(axisNumber)]
end

function RollingStockModelInfo:getTextureNames()
    return TableUtils.deepcopy(self.textureNames or {})
end

return RollingStockModelInfo
