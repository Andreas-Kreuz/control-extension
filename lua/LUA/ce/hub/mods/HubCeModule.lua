if AkDebugLoad then print("[#Start] Loading ce.hub.mods.HubCeModule ...") end

---@class HubCeModule: CeModule
HubCeModule = {}
HubCeModule.id = "b9f34a2e-1c5d-4f8a-9e7b-3d0a6c8f2e41"
HubCeModule.enabled = true
local initialized = false
HubCeModule.name = "ce.hub.mods.HubCeModule"
HubCeModule.CeTypes = require("ce.hub.data.HubCeTypes")
local CeTypeRegistry = require("ce.hub.data.CeTypeRegistry")
local Scheduler = require("ce.hub.scheduler.Scheduler")
local HubBridgeConnector = require("ce.hub.bridge.HubBridgeConnector")

CeTypeRegistry.registerCeTypes(
    { ceType = HubCeModule.CeTypes.Module, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.Runtime, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.EepVersion, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.Weather, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.SaveSlot, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.FreeSlot, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.Signal, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.WaitingOnSignal, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.Switch, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.Structure, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.Time, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.Train, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.RollingStock, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.RollingStockTextures, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.RollingStockRotation, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.AuxiliaryTrack, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.ControlTrack, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.RoadTrack, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.RailTrack, keyId = "id", owner = HubCeModule.name },
    { ceType = HubCeModule.CeTypes.TramTrack, keyId = "id", owner = HubCeModule.name }
)

function HubCeModule.init()
    if not HubCeModule.enabled or initialized then return end
    HubBridgeConnector.registerStatePublishers()
    initialized = true
end

function HubCeModule.run()
    if not HubCeModule.enabled then return end
    Scheduler:runTasks()
end

function HubCeModule.setOptions(options)
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

    return HubCeModule
end

return HubCeModule
