if CeDebugLoad then
    print("[#Start] Loading ce.hub.CeHubModule ...")
end
require("ce.hub.eep.EepCompatibilityApi")

---@class CeHubModule: CeModule
CeHubModule = {}
CeHubModule.id = "b9f34a2e-1c5d-4f8a-9e7b-3d0a6c8f2e41"
CeHubModule.enabled = true
local initialized = false
CeHubModule.name = "ce.hub.CeHubModule"
CeHubModule.CeTypes = require("ce.hub.data.HubCeTypes")
local Scheduler = require("ce.hub.scheduler.Scheduler")
local HubBridgeConnector = require("ce.hub.HubBridgeConnector")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local HubOptionDefaults = require("ce.hub.options.HubOptionDefaults")
local TableUtils = require("ce.hub.util.TableUtils")
local ModulesUpdater = require("ce.hub.data.modules.ModulesUpdater")
local VersionUpdater = require("ce.hub.data.version.VersionUpdater")
local RuntimeUpdater = require("ce.hub.data.runtime.RuntimeUpdater")
local FrameDataUpdater = require("ce.hub.data.framedata.FrameDataUpdater")
local DataSlotsUpdater = require("ce.hub.data.slots.DataSlotsUpdater")
local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")
local StructureUpdater = require("ce.hub.data.structures.StructureUpdater")
local ScenarioUpdater = require("ce.hub.data.scenario.ScenarioUpdater")
local TimeUpdater = require("ce.hub.data.time.TimeUpdater")
local WeatherUpdater = require("ce.hub.data.weather.WeatherUpdater")
local SignalDiscovery = require("ce.hub.data.signals.SignalDiscovery")
local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")
local SwitchDiscovery = require("ce.hub.data.switches.SwitchDiscovery")
local SwitchUpdater = require("ce.hub.data.switches.SwitchUpdater")
local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
local TrainUpdater = require("ce.hub.data.trains.TrainUpdater")
local RollingStockUpdater = require("ce.hub.data.rollingstock.RollingStockUpdater")
local Anl3ToTable = require("ce.hub.eep.Anl3ToTable")
local Anl3DiscoveryHelper = require("ce.hub.eep.Anl3DiscoveryHelper")
local TimedExecution = require("ce.hub.util.TimedExecution")
local EepCallAnalyzer = require("ce.hub.eep.EepCallAnalyzer")
local ProtectedExecution = require("ce.hub.util.ProtectedExecution")

local anl3Path = nil
local activeAnl3Discovery = { success = false, coverage = {} }
local pendingAnl3Path = nil
local anl3ReloadPending = false
local anl3ReloadDelayCycles = 0
local savingInProgress = false
local savingGuardCycles = 0
local MAX_SAVING_GUARD_CYCLES = 300

local function tk(group, func)
    if string.find(group, "^Discovery") then
        EepCallAnalyzer.runInDiscovery(function () TimedExecution.runProtectedTimedAndKeep(group, func) end)
    else
        TimedExecution.runProtectedTimedAndKeep(group, func)
    end
end

local function tu(group, func)
    if string.find(group, "^Discovery") then
        EepCallAnalyzer.runInDiscovery(function () TimedExecution.runProtectedTimed(group, func) end)
    else
        TimedExecution.runProtectedTimed(group, func)
    end
end

local function hasAnl3Coverage(alias)
    return activeAnl3Discovery.success == true and activeAnl3Discovery.coverage
        and activeAnl3Discovery.coverage[alias] == true
end

local function runInitialDataDiscovery()
    if not hasAnl3Coverage("signals") then tk("Discovery-init/ce.hub.Signal", SignalDiscovery.runInitialDiscovery) end
    if not hasAnl3Coverage("switches") then tk("Discovery-init/ce.hub.Switch", SwitchDiscovery.runInitialDiscovery) end
    if not hasAnl3Coverage("structures") then
        tk("Discovery-init/ce.hub.Structure", StructureDiscovery.runInitialDiscovery)
    end
    tk("Discovery-init/ce.hub.Train", function ()
        TrainDiscovery.runInitialDiscovery({
            skipTrackInitialization = hasAnl3Coverage("tracks"),
            keepCache = hasAnl3Coverage("trains")
        })
    end)

    tk("Update-init/ce.hub.DataSlot", DataSlotsUpdater.runUpdate)
    tk("Update-init/ce.hub.Frame", FrameDataUpdater.runUpdate)
    tk("Update-init/ce.hub.Module", ModulesUpdater.runUpdate)
    tk("Update-init/ce.hub.RollingStock", RollingStockUpdater.runUpdate)
    tk("Update-init/ce.hub.Runtime", RuntimeUpdater.runUpdate)
    tk("Update-init/ce.hub.Signal", SignalUpdater.runUpdate)
    tk("Update-init/ce.hub.Scenario", ScenarioUpdater.runUpdate)
    tk("Update-init/ce.hub.Structure", StructureUpdater.runInitialUpdate)
    tk("Update-init/ce.hub.Switch", SwitchUpdater.runUpdate)
    tk("Update-init/ce.hub.Time", TimeUpdater.runUpdate)
    tk("Update-init/ce.hub.Train", TrainUpdater.runUpdate)
    tk("Update-init/ce.hub.Version", VersionUpdater.runUpdate)
    tk("Update-init/ce.hub.Weather", WeatherUpdater.runUpdate)
end

local function runDataUpdates()
    if not hasAnl3Coverage("signals") then tu("Discovery/ce.hub.Signal", SignalDiscovery.runDiscovery) end
    if not hasAnl3Coverage("switches") then tu("Discovery/ce.hub.Switch", SwitchDiscovery.runDiscovery) end
    if not hasAnl3Coverage("structures") then tu("Discovery/ce.hub.Structure", StructureDiscovery.runDiscovery) end
    tu("Discovery/ce.hub.Train", TrainDiscovery.runDiscovery)

    tu("Update/ce.hub.DataSlots", DataSlotsUpdater.runUpdate)
    tu("Update/ce.hub.FrameData", FrameDataUpdater.runUpdate)
    tu("Update/ce.hub.Module", ModulesUpdater.runUpdate)
    tu("Update/ce.hub.RollingStock", RollingStockUpdater.runUpdate)
    tu("Update/ce.hub.Runtime", RuntimeUpdater.runUpdate)
    tu("Update/ce.hub.Signal", SignalUpdater.runUpdate)
    tu("Update/ce.hub.Scenario", ScenarioUpdater.runUpdate)
    tu("Update/ce.hub.Structure", StructureUpdater.runUpdate)
    tu("Update/ce.hub.Switch", SwitchUpdater.runUpdate)
    tu("Update/ce.hub.Time", TimeUpdater.runUpdate)
    tu("Update/ce.hub.Train", TrainUpdater.runUpdate)
    tu("Update/ce.hub.Version", VersionUpdater.runUpdate)
    tu("Update/ce.hub.Weather", WeatherUpdater.runUpdate)
end

function CeHubModule.setAnl3Path(path)
    anl3Path = path
end

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
    EEPShowInfoTextTop(0.8, 1, 0.8, 1, 10, 1, string.format("Lade Anlage ..."))

    local tableOfAnl3, err = Anl3ToTable.loadAnlage(path)
    if tableOfAnl3 then
        print(string.format("[CeHubModule] Anlage laden erfolgreich: %s", path))
    else
        print(string.format("[CeHubModule] Laden der Anlage fehlgeschlagen: %s", tostring(err)))
        result.error = err
        return result
    end
    local scenarioName = EEPGetAnlName and EEPGetAnlName() or nil
    local rawLuaPath = Anl3DiscoveryHelper.getLuaPath(tableOfAnl3) or ""
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
    local coverage = Anl3DiscoveryHelper.fillDiscoveries(tableOfAnl3)
    result.success = true
    result.coverage = coverage or {}
    EEPShowInfoTextTop(0.8, 1, 0.8, 1, 10, 1, string.format(
        "Anlage geladen in %.2f Sekunden.",
        os.clock() - startTime
    ))
    print(string.format(
        "[CeHubModule] Anlage geladen in %.2f Sekunden.",
        os.clock() - startTime
    ))
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

function CeHubModule.init()
    if not CeHubModule.enabled or initialized then
        return
    end
    HubBridgeConnector.registerStatePublishers()
    HubBridgeConnector.registerFunctions()
    activeAnl3Discovery = runAnl3Discovery(anl3Path)
    runInitialDataDiscovery()
    initialized = true
end

function CeHubModule.run()
    if not initialized then
        print("[CeHubModule] Warning: run called before module was initialized!")
    end
    if not CeHubModule.enabled then
        return
    end
    if savingInProgress then
        savingGuardCycles = savingGuardCycles + 1
        if savingGuardCycles >= MAX_SAVING_GUARD_CYCLES then
            print("[CeHubModule] Warning: save guard timed out, resuming updates")
            savingInProgress = false
            savingGuardCycles = 0
        else
            return
        end
    end
    reloadAnl3IfNeeded()
    runDataUpdates()
    Scheduler:runTasks()
end

function CeHubModule.setOptions(options)
    options = HubOptionsRegistry.copyTable(options or {})

    if options.sync or options.publisherOptions or options.collectedCeTypes or options.serverCeTypes then
        error("CeHubModule.setOptions no longer supports legacy sync options. Use options.ceTypes instead.")
    end

    if options.waitForServer ~= nil then
        local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
        ServerExchangeCoordinator.checkServerStatus = options.waitForServer
    end

    local mergedOptions = TableUtils.deepMerge(HubOptionDefaults.create(), options)
    HubOptionsRegistry.setOptions(mergedOptions)

    return CeHubModule
end

function EEPOnBeforeSaveAnl()
    ProtectedExecution.run("EEPOnBeforeSaveAnl", function ()
        savingInProgress = true
        savingGuardCycles = 0
        print("[CeHubModule] EEP speichert Anlage ...")
    end)
end

function EEPOnSaveAnl(Anlagenname)
    ProtectedExecution.run("EEPOnSaveAnl", function ()
        savingInProgress = false
        savingGuardCycles = 0
        print("Anlage gespeichert unter: " .. tostring(Anlagenname))

        pendingAnl3Path = Anlagenname
        anl3ReloadPending = true
        anl3ReloadDelayCycles = 3

        if anl3Path and Anlagenname and not pathsEqual(anl3Path, Anlagenname) then
            print(
                string.format(
                    "[CeHubModule] Saved anl3 path differs from ControlExtension option. Please update " ..
                    "ControlExtension.setOptions({ anl3path = \"%s\" }).",
                    tostring(Anlagenname)
                )
            )
        end
    end)
end

return CeHubModule
