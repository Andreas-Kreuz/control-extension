if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockModelInfoRegistry ...") end

local RollingStockModelInfo = require("ce.hub.data.rollingstock.RollingStockModelInfo")
local RollingStockResourceParser = require("ce.hub.eep.RollingStockResourceParser")

local RollingStockModelInfoRegistry = {}
local cachedByXmlModel = {}

function RollingStockModelInfoRegistry.infoForXmlModel(xmlModel)
    local key = xmlModel or ""
    if cachedByXmlModel[key] then return cachedByXmlModel[key] end

    local parsedInfo = RollingStockResourceParser.infoForXmlModel(xmlModel)
    local info = RollingStockModelInfo:new({
        xmlModel = xmlModel,
        axisNames = parsedInfo.axisNames or {},
        axisNamesByLanguage = parsedInfo.axisNamesByLanguage or {},
        textureNames = parsedInfo.textureNames or {}
    })
    cachedByXmlModel[key] = info
    return info
end

function RollingStockModelInfoRegistry.reset()
    cachedByXmlModel = {}
end

return RollingStockModelInfoRegistry
