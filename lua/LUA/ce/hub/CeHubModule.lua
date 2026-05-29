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
local EepScenarioDataController = require("ce.hub.eep.scenario.EepScenarioDataController")
local TimedExecution = require("ce.hub.util.TimedExecution")
local EepCallAnalyzer = require("ce.hub.eep.EepCallAnalyzer")
local ProtectedExecution = require("ce.hub.util.ProtectedExecution")

local savingInProgress = false
local savingGuardCycles = 0
local MAX_SAVING_GUARD_CYCLES = 300
local STRUCTURE_DISCOVERY_START_RUN = 3
local runCount = 0

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

-- This will tell us if the current data was already loaded from the screnario's anl3 file,
-- so we can skip to discover data by EEP... function calls.
local function hasAnl3Coverage(anl3Discovery, alias)
    return anl3Discovery and anl3Discovery.success == true and anl3Discovery.coverage
        and anl3Discovery.coverage[alias] == true
end

local function runInitialDataDiscovery(anl3Discovery)
    if not hasAnl3Coverage(anl3Discovery, "signals") then
        tk("Discovery-init/ce.hub.Signal", SignalDiscovery.runInitialDiscovery)
    end
    if not hasAnl3Coverage(anl3Discovery, "switches") then
        tk("Discovery-init/ce.hub.Switch", SwitchDiscovery.runInitialDiscovery)
    end
    tk("Discovery-init/ce.hub.Train", function ()
        TrainDiscovery.runInitialDiscovery({
            skipTrackInitialization = hasAnl3Coverage(anl3Discovery, "tracks"),
            keepCache = hasAnl3Coverage(anl3Discovery, "trains")
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

local function runDataUpdates(anl3Discovery)
    if not hasAnl3Coverage(anl3Discovery, "signals") then
        tu("Discovery/ce.hub.Signal", SignalDiscovery.runDiscovery)
    end
    if not hasAnl3Coverage(anl3Discovery, "switches") then
        tu("Discovery/ce.hub.Switch", SwitchDiscovery.runDiscovery)
    end
    if not hasAnl3Coverage(anl3Discovery, "structures") and runCount >= STRUCTURE_DISCOVERY_START_RUN then
        tu("Discovery/ce.hub.Structure", StructureDiscovery.runDiscovery)
    end
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
    EepScenarioDataController.update({ setAnl3Path = true, anl3Path = path })
end

function CeHubModule.init()
    if not CeHubModule.enabled or initialized then
        return
    end
    HubBridgeConnector.registerStatePublishers()
    HubBridgeConnector.registerFunctions()
    local anl3Discovery = EepScenarioDataController.init()
    runInitialDataDiscovery(anl3Discovery)
    runCount = 0
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
    runCount = runCount + 1
    local anl3Discovery = EepScenarioDataController.update()
    runDataUpdates(anl3Discovery)
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
        if debug then
            print("[CeHubModule] EEP speichert Anlage ...")
        end
    end)
end

function EEPOnSaveAnl(Anlagenname)
    ProtectedExecution.run("EEPOnSaveAnl", function ()
        savingInProgress = false
        savingGuardCycles = 0
        if debug then
            print("Anlage gespeichert unter: " .. tostring(Anlagenname))
        end
        EepScenarioDataController.update({ savedAnl3Path = Anlagenname })
    end)
end

return CeHubModule
