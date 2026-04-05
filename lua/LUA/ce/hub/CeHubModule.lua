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
    { ceType = CeHubModule.CeTypes.TrainStatic, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.TrainDynamic, keyId = "id", owner = CeHubModule.name, isDynamic = true },
    { ceType = CeHubModule.CeTypes.RollingStockStatic, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.RollingStockDynamic, keyId = "id", owner = CeHubModule.name, isDynamic = true },
    { ceType = CeHubModule.CeTypes.RollingStockTextures, keyId = "id", owner = CeHubModule.name },
    { ceType = CeHubModule.CeTypes.RollingStockRotation, keyId = "id", owner = CeHubModule.name },
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

local publisherAliases = {
    modules  = "ce.hub.data.modules.ModulesStatePublisher",
    version  = "ce.hub.data.version.VersionStatePublisher",
    runtime  = "ce.hub.data.runtime.RuntimeStatePublisher",
    frameData = "ce.hub.data.framedata.FrameDataStatePublisher",
    slots    = "ce.hub.data.slots.DataSlotsStatePublisher",
    signal   = "ce.hub.data.signals.SignalStatePublisher",
    switch   = "ce.hub.data.switches.SwitchStatePublisher",
    structure = "ce.hub.data.structures.StructureStatePublisher",
    time     = "ce.hub.data.time.TimeStatePublisher",
    weather  = "ce.hub.data.weather.WeatherStatePublisher",
    trains   = "ce.hub.data.trains.TrainsAndTracksStatePublisher"
}

function CeHubModule.setOptions(options)
    options = options or {}

    if options.waitForServer ~= nil then
        local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
        ServerExchangeCoordinator.checkServerStatus = options.waitForServer
    end
    if options.collectedCeTypes then
        HubBridgeConnector.setCollectedCeTypes(options.collectedCeTypes)
    end
    if options.serverCeTypes then
        require("ce.hub.publish.ServerEventDispatcher").setAllowedHubCeTypes(options.serverCeTypes)
    end
    if options.publisherOptions then
        for alias, pubOptions in pairs(options.publisherOptions) do
            local modulePath = publisherAliases[alias]
            if modulePath then
                local pub = require(modulePath)
                for k, v in pairs(pubOptions) do
                    pub.options[k] = v
                end
            end
        end
    end

    return CeHubModule
end

return CeHubModule
