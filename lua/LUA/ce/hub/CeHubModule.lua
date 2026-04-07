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

local function runInitialDataDiscovery()
    ModulesUpdater.runUpdate()
    VersionUpdater.runUpdate()
    RuntimeUpdater.runUpdate()
    FrameDataUpdater.runUpdate()
    DataSlotsUpdater.runUpdate()

    SignalDiscovery.runInitialDiscovery()
    SwitchDiscovery.runInitialDiscovery()
    StructureDiscovery.runInitialDiscovery()
    TrainDiscovery.runInitialDiscovery()

    SignalUpdater.runUpdate()
    SwitchUpdater.runUpdate()
    StructureUpdater.runInitialUpdate()
    TimeUpdater.runUpdate()
    WeatherUpdater.runUpdate()
    TrainUpdater.runUpdate()
    RollingStockUpdater.runUpdate()
end

local function runDataUpdates()
    ModulesUpdater.runUpdate()
    VersionUpdater.runUpdate()
    RuntimeUpdater.runUpdate()
    FrameDataUpdater.runUpdate()
    DataSlotsUpdater.runUpdate()

    SignalDiscovery.runDiscovery()
    SwitchDiscovery.runDiscovery()
    StructureDiscovery.runDiscovery()
    TrainDiscovery.runDiscovery()

    SignalUpdater.runUpdate()
    SwitchUpdater.runUpdate()
    StructureUpdater.runUpdate()
    TimeUpdater.runUpdate()
    WeatherUpdater.runUpdate()
    TrainUpdater.runUpdate()
    RollingStockUpdater.runUpdate()
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
