if CeDebugLoad then print("[#Start] Loading ce.hub.CeHubModule ...") end

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
local RuntimeRegistry = require("ce.hub.util.RuntimeRegistry")

local anl3Path = nil

local function tk(group, func)
    RuntimeRegistry.runTimedAndKeep(group, func)
end

local function tu(group, func)
    RuntimeRegistry.runTimed(group, func)
end

local function runInitialDataDiscovery()
    tk("Discovery-init/ce.hub.Signal", SignalDiscovery.runInitialDiscovery)
    tk("Discovery-init/ce.hub.Switch", SwitchDiscovery.runInitialDiscovery)
    tk("Discovery-init/ce.hub.Structure", StructureDiscovery.runInitialDiscovery)
    tk("Discovery-init/ce.hub.Train", TrainDiscovery.runInitialDiscovery)

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
    tu("Discovery/ce.hub.Signal", SignalDiscovery.runDiscovery)
    tu("Discovery/ce.hub.Switch", SwitchDiscovery.runDiscovery)
    tu("Discovery/ce.hub.Structure", StructureDiscovery.runDiscovery)
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

local function runAnl3Discovery()
    if not anl3Path then return end
    local tableOfAnl3, err = Anl3ToTable.loadAnlage(anl3Path)
    if not tableOfAnl3 then
        print("[CeHubModule] Anl3 load failed: " .. tostring(err))
        return
    end
    local scenarioName = EEPGetAnlName and EEPGetAnlName() or nil
    if scenarioName then
        local rawLuaPath = Anl3DiscoveryHelper.getLuaPath(tableOfAnl3) or ""
        local luaPathName = rawLuaPath:match("\\([^\\]+)%.lua$")
        if luaPathName ~= scenarioName then
            print(string.format(
                "[CeHubModule] Anl3 mismatch: EEPGetAnlName=%s but LUAPath=%s -- skipping anl3 discoveries",
                tostring(scenarioName), tostring(rawLuaPath)))
            return
        end
    end
    Anl3DiscoveryHelper.fillDiscoveries(tableOfAnl3)
end

function CeHubModule.init()
    if not CeHubModule.enabled or initialized then return end
    HubBridgeConnector.registerStatePublishers()
    HubBridgeConnector.registerFunctions()
    runAnl3Discovery()
    runInitialDataDiscovery()
    initialized = true
end

function CeHubModule.run()
    if not CeHubModule.enabled then return end
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

return CeHubModule
