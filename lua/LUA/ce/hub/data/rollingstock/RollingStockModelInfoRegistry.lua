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
        axisNamesKnown = parsedInfo.axisNamesKnown == true,
        axisNames = parsedInfo.axisNames or {},
        axisNamesByLanguage = parsedInfo.axisNamesByLanguage or {},
        rawAxisNames = parsedInfo.rawAxisNames or {},
        rawAxisNamesByLanguage = parsedInfo.rawAxisNamesByLanguage or {},
        parsed3dmAxes = parsedInfo.parsed3dmAxes or {},
        parsed3dmAxesKnown = parsedInfo.parsed3dmAxesKnown == true,
        visibleAxisInfos = parsedInfo.visibleAxisInfos or {},
        parserError = parsedInfo.parserError,
        textureNames = parsedInfo.textureNames or {}
    })
    cachedByXmlModel[key] = info
    return info
end

function RollingStockModelInfoRegistry.reset()
    cachedByXmlModel = {}
end

return RollingStockModelInfoRegistry
