if CeDebugLoad then print("[#Start] Loading ce.hub.HubBridgeConnector ...") end
local HubBridgeConnector = {}
local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")
local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local CeTypeRegistry = require("ce.hub.data.CeTypeRegistry")

local function hasActiveCeType(ceTypes, ...)
    for i = 1, select("#", ...) do
        local alias = select(i, ...)
        local ceTypeOptions = ceTypes[alias]
        local ceTypeDef = ceTypeOptions and CeTypeRegistry.getCeTypeDefinition(ceTypeOptions.ceType)
        local isDynamic = ceTypeDef and ceTypeDef.isDynamic or false
        if SyncPolicy.isActive(ceTypeOptions, isDynamic) then return true end
    end
    return false
end

local function shouldRegister(pub, ...)
    return pub.enabled ~= false and hasActiveCeType(pub.options.ceTypes or {}, ...)
end

function HubBridgeConnector.registerStatePublishers()
    local ModuleRegistry = require("ce.hub.ModuleRegistry")
    local ModulesDataCollector = require("ce.hub.data.modules.ModulesDataCollector")
    ModulesDataCollector.setRegisteredCeModules(ModuleRegistry.getRegisteredCeModules())

    do
        local pub = require("ce.hub.data.modules.ModulesStatePublisher")
        if shouldRegister(pub, "modules") then StatePublisherRegistry.registerStatePublishers(pub) end
    end
    do
        local pub = require("ce.hub.data.version.VersionStatePublisher")
        if shouldRegister(pub, "eepVersion") then StatePublisherRegistry.registerStatePublishers(pub) end
    end
    do
        local pub = require("ce.hub.data.runtime.RuntimeStatePublisher")
        if shouldRegister(pub, "runtimes") then StatePublisherRegistry.registerStatePublishers(pub) end
    end
    do
        local pub = require("ce.hub.data.framedata.FrameDataStatePublisher")
        if shouldRegister(pub, "frameData") then StatePublisherRegistry.registerStatePublishers(pub) end
    end
    do
        local pub = require("ce.hub.data.slots.DataSlotsStatePublisher")
        if shouldRegister(pub, "saveSlots", "freeSlots") then
            StatePublisherRegistry.registerStatePublishers(pub)
        end
    end
    do
        local pub = require("ce.hub.data.signals.SignalStatePublisher")
        if shouldRegister(pub, "signals", "waitingOnSignals") then
            StatePublisherRegistry.registerStatePublishers(pub)
        end
    end
    do
        local pub = require("ce.hub.data.switches.SwitchStatePublisher")
        if shouldRegister(pub, "switches") then StatePublisherRegistry.registerStatePublishers(pub) end
    end
    do
        local pub = require("ce.hub.data.structures.StructureStatePublisher")
        if shouldRegister(pub, "structures") then StatePublisherRegistry.registerStatePublishers(pub) end
    end
    do
        local pub = require("ce.hub.data.time.TimeStatePublisher")
        if shouldRegister(pub, "time") then StatePublisherRegistry.registerStatePublishers(pub) end
    end
    do
        local pub = require("ce.hub.data.weather.WeatherStatePublisher")
        if shouldRegister(pub, "weather") then StatePublisherRegistry.registerStatePublishers(pub) end
    end
    do
        local pub = require("ce.hub.data.tracks.TracksStatePublisher")
        if pub.enabled ~= false and (
                hasActiveCeType(pub.options.ceTypes or {},
                                "auxiliaryTracks",
                                "controlTracks",
                                "roadTracks",
                                "railTracks",
                                "tramTracks")
                or hasActiveCeType(require("ce.hub.data.trains.TrainStatePublisher").options.ceTypes or {},
                                   "trains")
                or hasActiveCeType(require("ce.hub.data.rollingstock.RollingStockStatePublisher").options.ceTypes or {},
                                   "rollingStocks")
            ) then
            StatePublisherRegistry.registerStatePublishers(pub)
        end
    end
    do
        local pub = require("ce.hub.data.trains.TrainStatePublisher")
        if shouldRegister(pub, "trains") then StatePublisherRegistry.registerStatePublishers(pub) end
    end
    do
        local pub = require("ce.hub.data.rollingstock.RollingStockStatePublisher")
        if shouldRegister(pub, "rollingStocks") then StatePublisherRegistry.registerStatePublishers(pub) end
    end
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
