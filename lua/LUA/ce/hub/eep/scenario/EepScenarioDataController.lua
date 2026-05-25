if CeDebugLoad then print("[#Start] Loading ce.hub.eep.scenario.EepScenarioDataController ...") end

local EepScenarioAnl3Parser = require("ce.hub.eep.scenario.EepScenarioAnl3Parser")
local EepScenarioAnl3Discovery = require("ce.hub.eep.scenario.EepScenarioAnl3Discovery")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local RollingStockModelInfoRegistry = require("ce.hub.data.rollingstock.RollingStockModelInfoRegistry")
local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")

local EepScenarioDataController = {}

local anl3Path = nil
local activeAnl3Discovery = { success = false, coverage = {} }
local pendingAnl3Path = nil
local anl3ReloadPending = false
local anl3ReloadDelayCycles = 0
local updateCallCount = 0
local DEFAULT_ROLLING_STOCK_MODEL_INFO_BATCH_SIZE = 20

local function buildAnl3Result(path)
    return {
        success = false,
        path = path,
        scenarioName = nil,
        luaPath = nil,
        coverage = {}
    }
end

local function scenarioNameFromLuaPath(luaPath)
    if not luaPath then return nil end
    local normalized = tostring(luaPath):gsub("/", "\\")
    local slashPosition = nil
    for index = #normalized, 1, -1 do
        if normalized:sub(index, index) == "\\" then
            slashPosition = index
            break
        end
    end
    local fileName = slashPosition and normalized:sub(slashPosition + 1) or normalized
    return fileName:match("(.+)%.lua$")
end

local function fileNameFromPath(path)
    if not path then return nil end
    local normalized = tostring(path):gsub("/", "\\")
    return normalized:match("([^\\]+)$") or normalized
end

local function pathsEqual(pathA, pathB)
    if not pathA or not pathB then return false end
    local normalizedA = tostring(pathA):gsub("/", "\\"):lower()
    local normalizedB = tostring(pathB):gsub("/", "\\"):lower()
    return normalizedA == normalizedB
end

local function runAnl3Discovery(path)
    local startTime = os.clock()
    print(string.format("[CeHubModule] Anlage laden: %s", path))
    local result = buildAnl3Result(path)
    if not path then return result end
    -- EEPShowInfoTextTop(0.8, 1, 0.8, 1, 10, 1, string.format("Lade Anlage ..."))

    local tableOfAnl3, err = EepScenarioAnl3Parser.loadAnlage(path)
    if tableOfAnl3 then
        print(string.format("[CeHubModule] Anlage laden erfolgreich: %s", path))
    else
        print(string.format("[CeHubModule] Laden der Anlage fehlgeschlagen: %s", tostring(err)))
        result.error = err
        return result
    end
    local scenarioName = EEPGetAnlName and EEPGetAnlName() or nil
    local rawLuaPath = EepScenarioAnl3Discovery.getLuaPath(tableOfAnl3) or ""
    result.scenarioName = scenarioName
    result.luaPath = rawLuaPath
    if scenarioName then
        local luaPathName = scenarioNameFromLuaPath(rawLuaPath)
        if luaPathName ~= scenarioName then
            print(
                string.format(
                    "[CeHubModule] Anl3 mismatch: EEPGetAnlName=%s but LUAPath=%s -- skipping anl3 discoveries",
                    tostring(scenarioName),
                    tostring(rawLuaPath)
                )
            )
            result.error = "mismatch"
            return result
        end
    end
    local coverage = EepScenarioAnl3Discovery.fillDiscoveries(tableOfAnl3)
    result.success = true
    result.coverage = coverage or {}
    local fileName = fileNameFromPath(path) or "?"
    local message = string.format(
        "CE-Hub: Anlage %s geladen in %.2f Sekunden",
        fileName,
        os.clock() - startTime
    )
    EEPShowInfoTextTop(0.8, 1, 0.8, 1, 10, 1, message)
    print(message)
    return result
end

local function reloadAnl3IfNeeded()
    if not anl3ReloadPending then return end
    if anl3ReloadDelayCycles > 0 then
        anl3ReloadDelayCycles = anl3ReloadDelayCycles - 1
        return
    end

    activeAnl3Discovery = runAnl3Discovery(pendingAnl3Path or anl3Path)
    pendingAnl3Path = nil
    anl3ReloadPending = false
end

local function rollingStockResourceBatchSize()
    local options = HubOptionsRegistry.getAllOptions()
    local eepResources = options.eepResources or {}
    local batchSize = tonumber(eepResources.rollingStockModelInfoBatchSize)
    if not batchSize then return DEFAULT_ROLLING_STOCK_MODEL_INFO_BATCH_SIZE end
    return math.max(0, math.floor(batchSize))
end

local function runRollingStockResourceUpdate()
    local parsedXmlModels = RollingStockModelInfoRegistry.processPending(rollingStockResourceBatchSize())
    if #parsedXmlModels > 0 then
        RollingStockRegistry.refreshModelInfoForXmlModels(parsedXmlModels)
    end
end

local function scheduleReload(savedAnl3Path)
    pendingAnl3Path = savedAnl3Path
    anl3ReloadPending = true
    anl3ReloadDelayCycles = 3

    if anl3Path and savedAnl3Path and not pathsEqual(anl3Path, savedAnl3Path) then
        print(
            string.format(
                "[CeHubModule] Saved anl3 path differs from ControlExtension option. Please update " ..
                "ControlExtension.setOptions({ anl3path = \"%s\" }).",
                tostring(savedAnl3Path)
            )
        )
    end
end

function EepScenarioDataController.init()
    updateCallCount = 0
    activeAnl3Discovery = runAnl3Discovery(anl3Path)
    return activeAnl3Discovery
end

function EepScenarioDataController.update(options)
    options = options or {}
    if options.setAnl3Path or options.anl3Path ~= nil then
        anl3Path = options.anl3Path
        return activeAnl3Discovery
    end
    if options.savedAnl3Path ~= nil then
        scheduleReload(options.savedAnl3Path)
        return activeAnl3Discovery
    end

    updateCallCount = updateCallCount + 1
    reloadAnl3IfNeeded()
    if updateCallCount >= 2 then runRollingStockResourceUpdate() end
    return activeAnl3Discovery
end

return EepScenarioDataController
