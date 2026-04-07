if CeDebugLoad then print("[#Start] Loading ce.hub.CeHubModule ...") end

---@class CeHubModule: CeModule
CeHubModule = {}
CeHubModule.id = "b9f34a2e-1c5d-4f8a-9e7b-3d0a6c8f2e41"
CeHubModule.enabled = true
local initialized = false
CeHubModule.name = "ce.hub.CeHubModule"
CeHubModule.CeTypes = require("ce.hub.data.HubCeTypes")
local CeTypeRegistry = require("ce.hub.data.CeTypeRegistry")
local Scheduler = require("ce.hub.scheduler.Scheduler")
local HubBridgeConnector = require("ce.hub.HubBridgeConnector")
local ServerEventDispatcher = require("ce.hub.publish.ServerEventDispatcher")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")
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

CeTypeRegistry.registerCeTypes(
    { ceType = CeHubModule.CeTypes.Module, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.Runtime, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.EepVersion, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.Weather, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.SaveSlot, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.FreeSlot, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.Signal, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.WaitingOnSignal, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.Switch, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.Structure, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.Time, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.Train, keyId = "id", owner = CeHubModule.name, isDynamic = true },
    { ceType = CeHubModule.CeTypes.RollingStock, keyId = "id", owner = CeHubModule.name, isDynamic = true },
    { ceType = CeHubModule.CeTypes.AuxiliaryTrack, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.ControlTrack, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.RoadTrack, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.RailTrack, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.TramTrack, keyId = "id", owner = CeHubModule.name }
)

local publisherModulePaths = {
    modules = "ce.hub.data.modules.ModulesStatePublisher",
    version = "ce.hub.data.version.VersionStatePublisher",
    runtimes = "ce.hub.data.runtime.RuntimeStatePublisher",
    frameData = "ce.hub.data.framedata.FrameDataStatePublisher",
    slots = "ce.hub.data.slots.DataSlotsStatePublisher",
    signals = "ce.hub.data.signals.SignalStatePublisher",
    switches = "ce.hub.data.switches.SwitchStatePublisher",
    structures = "ce.hub.data.structures.StructureStatePublisher",
    time = "ce.hub.data.time.TimeStatePublisher",
    weather = "ce.hub.data.weather.WeatherStatePublisher",
    tracks = "ce.hub.data.tracks.TracksStatePublisher",
    trains = "ce.hub.data.trains.TrainStatePublisher",
    rollingStocks = "ce.hub.data.rollingstock.RollingStockStatePublisher"
}

local function publisherModule(alias)
    local modulePath = publisherModulePaths[alias]
    assert(modulePath, "Unknown publisher alias: " .. tostring(alias))
    return require(modulePath)
end

local function runInitialDataDiscovery()
    local signalOptions = publisherModule("signals").options
    local structureOptions = publisherModule("structures").options

    ModulesUpdater.runUpdate()
    VersionUpdater.runUpdate()
    RuntimeUpdater.runUpdate()
    FrameDataUpdater.runUpdate()
    DataSlotsUpdater.runUpdate()

    SignalDiscovery.runInitialDiscovery()
    SwitchDiscovery.runInitialDiscovery()
    StructureDiscovery.runInitialDiscovery()
    TrainDiscovery.runInitialDiscovery()

    SignalUpdater.runUpdate(signalOptions)
    SwitchUpdater.runUpdate()
    StructureUpdater.runInitialUpdate(structureOptions)
    TimeUpdater.runUpdate()
    WeatherUpdater.runUpdate()
end

local function runDataUpdates()
    local signalOptions = publisherModule("signals").options
    local structureOptions = publisherModule("structures").options
    local trainFieldOptions = publisherModule("trains").options.fields
    local rollingStockOptions = publisherModule("rollingStocks").options

    ModulesUpdater.runUpdate()
    VersionUpdater.runUpdate()
    RuntimeUpdater.runUpdate()
    FrameDataUpdater.runUpdate()
    DataSlotsUpdater.runUpdate()

    SignalDiscovery.runDiscovery()
    SwitchDiscovery.runDiscovery()
    StructureDiscovery.runDiscovery()
    TrainDiscovery.runDiscovery()

    SignalUpdater.runUpdate(signalOptions)
    SwitchUpdater.runUpdate()
    StructureUpdater.runUpdate(structureOptions)
    TimeUpdater.runUpdate()
    WeatherUpdater.runUpdate()
    TrainUpdater.runUpdate(trainFieldOptions)
    RollingStockUpdater.runUpdate(rollingStockOptions)
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

local function applyPublisherSync(publisherSync)
    if type(publisherSync) ~= "table" then return end

    for alias, syncOptions in pairs(publisherSync) do
        local modulePath = publisherModulePaths[alias]
        if modulePath then
            local pub = require(modulePath)
            if syncOptions.enabled ~= nil then
                pub.enabled = syncOptions.enabled == true
            end
        end
    end
end

local function applyCeTypeSync(ceTypeSync)
    if type(ceTypeSync) ~= "table" then return end

    local ceTypeModes = {}
    for _, modulePath in pairs(publisherModulePaths) do
        local pub = require(modulePath)
        if pub.options and pub.options.ceTypes then
            for alias, ceTypeOptions in pairs(pub.options.ceTypes) do
                local ceTypeDef = CeTypeRegistry.getCeTypeDefinition(ceTypeOptions.ceType)
                local syncOptions = ceTypeSync[alias]
                if syncOptions and syncOptions.mode ~= nil then
                    ceTypeOptions.mode = SyncPolicy.normalizeMode(syncOptions.mode, ceTypeDef and ceTypeDef.isDynamic)
                else
                    ceTypeOptions.mode = SyncPolicy.normalizeMode(ceTypeOptions.mode, ceTypeDef and ceTypeDef.isDynamic)
                end
                ceTypeModes[ceTypeOptions.ceType] = ceTypeOptions.mode
            end
        end
    end
    ServerEventDispatcher.setCeTypeModes(ceTypeModes)
end

local function applyFieldSync(fieldSync)
    if type(fieldSync) ~= "table" then return end

    for publisherAlias, fieldOptionsByName in pairs(fieldSync) do
        local modulePath = publisherModulePaths[publisherAlias]
        if modulePath then
            local pub = require(modulePath)
            local fields = pub.options and pub.options.fields or nil
            if fields then
                for fieldAlias, fieldOptions in pairs(fieldOptionsByName) do
                    if fields[fieldAlias] and fieldOptions.collect ~= nil then
                        fields[fieldAlias].collect = fieldOptions.collect == true
                    end
                end
            end
        end
    end
end

function CeHubModule.setOptions(options)
    options = options or {}

    if options.waitForServer ~= nil then
        local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
        ServerExchangeCoordinator.checkServerStatus = options.waitForServer
    end

    local sync = options.sync or {}
    applyPublisherSync(sync.publishers)
    applyFieldSync(sync.fields)
    applyCeTypeSync(sync.ceTypes)

    if options.publisherOptions or options.collectedCeTypes or options.serverCeTypes then
        error("CeHubModule.setOptions no longer supports legacy sync options. Use options.sync instead.")
    end

    return CeHubModule
end

return CeHubModule
