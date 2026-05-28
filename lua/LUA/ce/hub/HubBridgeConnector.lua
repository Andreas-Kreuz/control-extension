if CeDebugLoad then print("[#Start] Loading ce.hub.HubBridgeConnector ...") end
local HubBridgeConnector = {}
local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")
local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local function registerStatePublisher(pub, aliases)
    if pub.enabled == false then return false end

    for _, alias in ipairs(aliases or {}) do
        if HubOptionsRegistry.isPublishEnabled(alias) then
            StatePublisherRegistry.registerStatePublishers(pub)
            return true
        end
    end
    return false
end

function HubBridgeConnector.registerStatePublishers()
    local ModuleRegistry = require("ce.hub.ModuleRegistry")
    local ModulesUpdater = require("ce.hub.data.modules.ModulesUpdater")
    ModulesUpdater.setRegisteredCeModules(ModuleRegistry.getRegisteredCeModules())

    registerStatePublisher(require("ce.hub.data.modules.ModulesStatePublisher"), { "modules" })
    registerStatePublisher(require("ce.hub.data.version.VersionStatePublisher"), { "eepVersion" })
    registerStatePublisher(require("ce.hub.data.runtime.RuntimeStatePublisher"), { "runtimes" })
    registerStatePublisher(require("ce.hub.data.framedata.FrameDataStatePublisher"), { "frameData" })
    registerStatePublisher(require("ce.hub.data.slots.DataSlotsStatePublisher"), { "saveSlots", "freeSlots" })
    registerStatePublisher(require("ce.hub.data.signals.SignalStatePublisher"), { "signals", "waitingOnSignals" })
    registerStatePublisher(require("ce.hub.data.switches.SwitchStatePublisher"), { "switches" })
    registerStatePublisher(require("ce.hub.data.structures.StructureStatePublisher"), { "structures" })
    registerStatePublisher(require("ce.hub.data.scenario.ScenarioStatePublisher"), { "scenario" })
    registerStatePublisher(require("ce.hub.data.time.TimeStatePublisher"), { "time" })
    registerStatePublisher(require("ce.hub.data.routes.RouteStatePublisher"), { "routes" })
    registerStatePublisher(require("ce.hub.data.weather.WeatherStatePublisher"), { "weather" })
    registerStatePublisher(require("ce.hub.data.tracks.TracksStatePublisher"), {
        "auxiliaryTracks",
        "controlTracks",
        "roadTracks",
        "railTracks",
        "tramTracks",
        "trains",
        "rollingStocks"
    })
    registerStatePublisher(require("ce.hub.data.trains.TrainStatePublisher"), { "trains" })
    registerStatePublisher(require("ce.hub.data.rollingstock.RollingStockStatePublisher"), { "rollingStocks" })
    registerStatePublisher(require("ce.hub.data.contacts.ContactStatePublisher"), { "contacts" })
end

function HubBridgeConnector.registerFunctions()
    local RollingStock = require("ce.hub.data.rollingstock.RollingStock")
    local Scenario = require("ce.hub.data.scenario.Scenario")
    local Structure = require("ce.hub.data.structures.Structure")
    local Train = require("ce.hub.data.trains.Train")
    ServerExchangeCoordinator.registerAllowedCommand(
        "HubInterestSync.startSyncFor",
        InterestSyncRegistry.startSyncFor
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "HubInterestSync.stopSyncFor",
        InterestSyncRegistry.stopSyncFor
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Structure.setPositionByName",
        Structure.setPositionByName
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Structure.setRotationByName",
        Structure.setRotationByName
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Structure.setLightByName",
        Structure.setLightByName
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Structure.setTagByName",
        Structure.setTagByName
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Scenario.setCamera",
        Scenario.setCamera
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Scenario.setPerspectiveCamera",
        Scenario.setPerspectiveCamera
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Scenario.setCameraPosition",
        Scenario.setCameraPosition
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Scenario.setCameraRotation",
        Scenario.setCameraRotation
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Train.setActiveByName",
        Train.setActiveByName
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Train.setSpeedByName",
        Train.setSpeedByName
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Train.setCouplingFrontByName",
        Train.setCouplingFrontByName
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Train.setCouplingRearByName",
        Train.setCouplingRearByName
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "Train.setLightByName",
        Train.setLightByName
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "RollingStock.setActiveByName",
        RollingStock.setActiveByName
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "RollingStock.setUserCameraByName",
        RollingStock.setUserCameraByName
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "RollingStock.setAxisByName",
        RollingStock.setAxisByName
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "RollingStock.setAxisByNumberByName",
        RollingStock.setAxisByNumberByName
    )
end

return HubBridgeConnector
