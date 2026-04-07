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
local TimeUpdater = require("ce.hub.data.time.TimeUpdater")
local WeatherUpdater = require("ce.hub.data.weather.WeatherUpdater")
local SignalDiscovery = require("ce.hub.data.signals.SignalDiscovery")
local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")
local SwitchDiscovery = require("ce.hub.data.switches.SwitchDiscovery")
local SwitchUpdater = require("ce.hub.data.switches.SwitchUpdater")
local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
local TrainUpdater = require("ce.hub.data.trains.TrainUpdater")
local RollingStockUpdater = require("ce.hub.data.rollingstock.RollingStockUpdater")
local RuntimeRegistry = require("ce.hub.util.RuntimeRegistry")

local function ti(group, func)
    RuntimeRegistry.runTimedAndKeep(group, func)
end

local function tu(group, func)
    RuntimeRegistry.runTimed(group, func)
end

local function runInitialDataDiscovery()
    ti("Discovery/ce.hub.Signal", SignalDiscovery.runInitialDiscovery)
    ti("Discovery/ce.hub.Switch", SwitchDiscovery.runInitialDiscovery)
    ti("Discovery/ce.hub.Structure", StructureDiscovery.runInitialDiscovery)
    ti("Discovery/ce.hub.Train", TrainDiscovery.runInitialDiscovery)

    ti("Update/ce.hub.DataSlot", DataSlotsUpdater.runUpdate)
    ti("Update/ce.hub.Frame", FrameDataUpdater.runUpdate)
    ti("Update/ce.hub.Module", ModulesUpdater.runUpdate)
    ti("Update/ce.hub.RollingStock", RollingStockUpdater.runUpdate)
    ti("Update/ce.hub.Runtime", RuntimeUpdater.runUpdate)
    ti("Update/ce.hub.Signal", SignalUpdater.runUpdate)
    ti("Update/ce.hub.Structure", StructureUpdater.runInitialUpdate)
    ti("Update/ce.hub.Switch", SwitchUpdater.runUpdate)
    ti("Update/ce.hub.Time", TimeUpdater.runUpdate)
    ti("Update/ce.hub.Train", TrainUpdater.runUpdate)
    ti("Update/ce.hub.Version", VersionUpdater.runUpdate)
    ti("Update/ce.hub.Weather", WeatherUpdater.runUpdate)
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
    tu("Update/ce.hub.Structure", StructureUpdater.runUpdate)
    tu("Update/ce.hub.Switch", SwitchUpdater.runUpdate)
    tu("Update/ce.hub.Time", TimeUpdater.runUpdate)
    tu("Update/ce.hub.Train", TrainUpdater.runUpdate)
    tu("Update/ce.hub.Version", VersionUpdater.runUpdate)
    tu("Update/ce.hub.Weather", WeatherUpdater.runUpdate)
end

function CeHubModule.init()
    if not CeHubModule.enabled or initialized then return end
    HubBridgeConnector.registerStatePublishers()
    HubBridgeConnector.registerFunctions()
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
