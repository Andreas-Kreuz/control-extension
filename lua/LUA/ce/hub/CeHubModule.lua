if AkDebugLoad then print("[#Start] Loading ce.hub.CeHubModule ...") end

---@class CeHubModule: CeModule
CeHubModule = {}
CeHubModule.id = "b9f34a2e-1c5d-4f8a-9e7b-3d0a6c8f2e41"
CeHubModule.enabled = true
local initialized = false
CeHubModule.name = "ce.hub.CeHubModule"
CeHubModule.CeTypes = require("ce.hub.data.HubCeTypes")
local CeTypeRegistry = require("ce.hub.data.CeTypeRegistry")
local Scheduler = require("ce.hub.scheduler.Scheduler")
local HubBridgeConnector = require("ce.hub.bridge.HubBridgeConnector")
local ServerEventDispatcher = require("ce.hub.publish.ServerEventDispatcher")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

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

function CeHubModule.init()
    if not CeHubModule.enabled or initialized then return end
    HubBridgeConnector.registerStatePublishers()
    HubBridgeConnector.registerFunctions()
    initialized = true
end

function CeHubModule.run()
    if not CeHubModule.enabled then return end
    Scheduler:runTasks()
end

local publisherModulePaths = {
    modules = "ce.hub.data.modules.ModulesStatePublisher",
    version = "ce.hub.data.version.VersionStatePublisher",
    runtime = "ce.hub.data.runtime.RuntimeStatePublisher",
    frameData = "ce.hub.data.framedata.FrameDataStatePublisher",
    slots = "ce.hub.data.slots.DataSlotsStatePublisher",
    signal = "ce.hub.data.signals.SignalStatePublisher",
    switch = "ce.hub.data.switches.SwitchStatePublisher",
    structure = "ce.hub.data.structures.StructureStatePublisher",
    time = "ce.hub.data.time.TimeStatePublisher",
    weather = "ce.hub.data.weather.WeatherStatePublisher",
    tracks = "ce.hub.data.trains.TracksStatePublisher",
    train = "ce.hub.data.trains.TrainStatePublisher",
    rollingStock = "ce.hub.data.trains.RollingStockStatePublisher"
}

local publisherAliasGroups = {
    trains = { "tracks", "train", "rollingStock" }
}

local function modulePathsForAlias(alias)
    if publisherModulePaths[alias] then
        return { publisherModulePaths[alias] }
    end

    local grouped = publisherAliasGroups[alias]
    if not grouped then return {} end

    local modulePaths = {}
    for _, groupAlias in ipairs(grouped) do
        modulePaths[#modulePaths + 1] = publisherModulePaths[groupAlias]
    end
    return modulePaths
end

local function applyPublisherSync(publisherSync)
    if type(publisherSync) ~= "table" then return end

    for alias, syncOptions in pairs(publisherSync) do
        for _, modulePath in ipairs(modulePathsForAlias(alias)) do
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
