if CeDebugLoad then print("[#Start] Loading ce.hub.HubBridgeConnector ...") end
local HubBridgeConnector = {}
local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")
local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
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
    local ModulesDataCollector = require("ce.hub.data.modules.ModulesDataCollector")
    ModulesDataCollector.setRegisteredCeModules(ModuleRegistry.getRegisteredCeModules())

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
    ServerExchangeCoordinator.registerAllowedCommand(
        "HubDynamicData.startUpdatesFor",
        DynamicUpdateRegistry.startUpdatesFor
    )
    ServerExchangeCoordinator.registerAllowedCommand(
        "HubDynamicData.stopUpdatesFor",
        DynamicUpdateRegistry.stopUpdatesFor
    )
end

return HubBridgeConnector
