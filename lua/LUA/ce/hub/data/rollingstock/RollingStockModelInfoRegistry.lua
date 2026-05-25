if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockModelInfoRegistry ...") end

local RollingStockModelInfo = require("ce.hub.data.rollingstock.RollingStockModelInfo")
local RollingStockResourceParser = require("ce.hub.eep.resources.RollingStockResourceParser")
local TableUtils = require("ce.hub.util.TableUtils")

local RollingStockModelInfoRegistry = {}
local cachedByXmlModel = {}
local parsedByXmlModel = {}
local queuedByXmlModel = {}
local pendingXmlModels = {}
local pendingIndex = 1
local changedFieldsByXmlModel = {}

local function keyForXmlModel(xmlModel)
    return xmlModel or ""
end

local function emptyInfoForXmlModel(xmlModel)
    return RollingStockModelInfo:new({
        xmlModel = xmlModel
    })
end

local function infoFromParsedInfo(xmlModel, parsedInfo)
    return RollingStockModelInfo:new({
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
end

local function changedBoolean(previous, readPrevious, current)
    if previous == nil then return nil end
    return readPrevious(previous) ~= current
end

local function changedDict(previous, previousValues, currentValues)
    if previous == nil then return nil end
    return not TableUtils.sameDictEntries(previousValues, currentValues)
end

local function parseInfoForXmlModel(xmlModel)
    local parsedInfo = RollingStockResourceParser.infoForXmlModel(xmlModel)
    local info = infoFromParsedInfo(xmlModel, parsedInfo)
    local key = keyForXmlModel(xmlModel)
    local previous = cachedByXmlModel[key]
    changedFieldsByXmlModel[key] = {
        axisNamesKnown = changedBoolean(previous, function (value) return value:getAxisNamesKnown() end,
                                        info:getAxisNamesKnown()),
        axisNames = changedDict(previous, previous and previous.axisNames, info.axisNames),
        textureNames = changedDict(previous, previous and previous.textureNames, info.textureNames)
    }
    cachedByXmlModel[key] = info
    parsedByXmlModel[key] = true
    queuedByXmlModel[key] = nil
    return info
end

local function compactPendingQueueIfDone()
    if pendingIndex <= #pendingXmlModels then return end
    pendingXmlModels = {}
    pendingIndex = 1
end

function RollingStockModelInfoRegistry.get(xmlModel)
    local key = keyForXmlModel(xmlModel)
    if cachedByXmlModel[key] and parsedByXmlModel[key] then return cachedByXmlModel[key] end

    return parseInfoForXmlModel(xmlModel)
end

function RollingStockModelInfoRegistry.peek(xmlModel)
    local key = keyForXmlModel(xmlModel)
    if cachedByXmlModel[key] then return cachedByXmlModel[key] end

    local info = emptyInfoForXmlModel(xmlModel)
    cachedByXmlModel[key] = info
    if key ~= "" then
        queuedByXmlModel[key] = true
        pendingXmlModels[#pendingXmlModels + 1] = xmlModel
    end
    return info
end

function RollingStockModelInfoRegistry.processPending(batchSize)
    local parsedXmlModels = {}
    local limit = tonumber(batchSize) or 0
    if limit <= 0 then return parsedXmlModels end

    while #parsedXmlModels < limit and pendingIndex <= #pendingXmlModels do
        local xmlModel = pendingXmlModels[pendingIndex]
        local key = keyForXmlModel(xmlModel)
        pendingIndex = pendingIndex + 1
        if queuedByXmlModel[key] and not parsedByXmlModel[key] then
            RollingStockModelInfoRegistry.get(xmlModel)
            parsedXmlModels[#parsedXmlModels + 1] = xmlModel
        end
    end

    compactPendingQueueIfDone()
    return parsedXmlModels
end

function RollingStockModelInfoRegistry.changedFieldsForXmlModel(xmlModel)
    return changedFieldsByXmlModel[keyForXmlModel(xmlModel)] or {}
end

function RollingStockModelInfoRegistry.reset()
    cachedByXmlModel = {}
    parsedByXmlModel = {}
    queuedByXmlModel = {}
    pendingXmlModels = {}
    pendingIndex = 1
    changedFieldsByXmlModel = {}
end

return RollingStockModelInfoRegistry
