if AkDebugLoad then print("[#Start] Loading ce.hub.bridge.HubBridgeConnector ...") end
local HubBridgeConnector = {}
local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")
local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
local ServerEventDispatcher = require("ce.hub.publish.ServerEventDispatcher")
local DynamicUpdateRegistry = require("ce.hub.data.dynamic.DynamicUpdateRegistry")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local collectedCeTypes = {}

local function toLookup(list)
    local lookup = {}
    for _, ceType in pairs(list or {}) do lookup[ceType] = true end
    return lookup
end

local function isSelected(...)
    if next(collectedCeTypes) == nil then return true end
    for i = 1, select("#", ...) do
        if collectedCeTypes[select(i, ...)] then return true end
    end
    return false
end

function HubBridgeConnector.setCollectedCeTypes(list)
    collectedCeTypes = toLookup(list)
end

function HubBridgeConnector.registerStatePublishers()
    local ModuleRegistry = require("ce.hub.ModuleRegistry")
    local ModulesDataCollector = require("ce.hub.data.modules.ModulesDataCollector")
    ModulesDataCollector.setRegisteredCeModules(ModuleRegistry.getRegisteredCeModules())

    if isSelected(HubCeTypes.Module) then
        local pub = require("ce.hub.data.modules.ModulesStatePublisher")
        StatePublisherRegistry.registerStatePublishers(pub)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.Module,
            function() return pub.options.sendModule ~= false end)
    end
    if isSelected(HubCeTypes.EepVersion) then
        local pub = require("ce.hub.data.version.VersionStatePublisher")
        StatePublisherRegistry.registerStatePublishers(pub)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.EepVersion,
            function() return pub.options.sendEepVersion ~= false end)
    end
    if isSelected(HubCeTypes.Runtime) then
        local pub = require("ce.hub.data.runtime.RuntimeStatePublisher")
        StatePublisherRegistry.registerStatePublishers(pub)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.Runtime,
            function() return pub.options.sendRuntime ~= false end)
    end
    if isSelected(HubCeTypes.FrameData) then
        local pub = require("ce.hub.data.framedata.FrameDataStatePublisher")
        StatePublisherRegistry.registerStatePublishers(pub)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.FrameData,
            function() return pub.options.sendFrameData ~= false end)
    end
    if isSelected(HubCeTypes.SaveSlot, HubCeTypes.FreeSlot) then
        local pub = require("ce.hub.data.slots.DataSlotsStatePublisher")
        StatePublisherRegistry.registerStatePublishers(pub)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.SaveSlot,
            function() return pub.options.sendSaveSlot ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.FreeSlot,
            function() return pub.options.sendFreeSlot ~= false end)
    end
    if isSelected(HubCeTypes.Signal, HubCeTypes.WaitingOnSignal) then
        local pub = require("ce.hub.data.signals.SignalStatePublisher")
        StatePublisherRegistry.registerStatePublishers(pub)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.Signal,
            function() return pub.options.sendSignal ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.WaitingOnSignal,
            function() return pub.options.sendWaitingOnSignal ~= false end)
    end
    if isSelected(HubCeTypes.Switch) then
        local pub = require("ce.hub.data.switches.SwitchStatePublisher")
        StatePublisherRegistry.registerStatePublishers(pub)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.Switch,
            function() return pub.options.sendSwitch ~= false end)
    end
    if isSelected(HubCeTypes.Structure) then
        local pub = require("ce.hub.data.structures.StructureStatePublisher")
        StatePublisherRegistry.registerStatePublishers(pub)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.StructureStatic,
            function() return pub.options.sendStructureStatic ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.StructureDynamic,
            function() return pub.options.sendStructureDynamic ~= false end)
    end
    if isSelected(HubCeTypes.Time) then
        local pub = require("ce.hub.data.time.TimeStatePublisher")
        StatePublisherRegistry.registerStatePublishers(pub)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.Time,
            function() return pub.options.sendTime ~= false end)
    end
    if isSelected(HubCeTypes.Weather) then
        local pub = require("ce.hub.data.weather.WeatherStatePublisher")
        StatePublisherRegistry.registerStatePublishers(pub)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.Weather,
            function() return pub.options.sendWeather ~= false end)
    end
    if isSelected(
            HubCeTypes.TrainStatic,
            HubCeTypes.TrainDynamic,
            HubCeTypes.RollingStockStatic,
            HubCeTypes.RollingStockDynamic,
            HubCeTypes.RollingStockTextures,
            HubCeTypes.RollingStockRotation,
            HubCeTypes.AuxiliaryTrack,
            HubCeTypes.ControlTrack,
            HubCeTypes.RoadTrack,
            HubCeTypes.RailTrack,
            HubCeTypes.TramTrack
        ) then
        local pub = require("ce.hub.data.trains.TrainsAndTracksStatePublisher")
        pub.setCollectedCeTypes(collectedCeTypes)
        StatePublisherRegistry.registerStatePublishers(pub)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.TrainStatic,
            function() return pub.options.sendTrainStatic ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.TrainDynamic,
            function() return pub.options.sendTrainDynamic ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.RollingStockStatic,
            function() return pub.options.sendRollingStockStatic ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.RollingStockDynamic,
            function() return pub.options.sendRollingStockDynamic ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.RollingStockTextures,
            function() return pub.options.sendRollingStockTextures ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.RollingStockRotation,
            function() return pub.options.sendRollingStockRotation ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.AuxiliaryTrack,
            function() return pub.options.sendAuxiliaryTrack ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.ControlTrack,
            function() return pub.options.sendControlTrack ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.RoadTrack,
            function() return pub.options.sendRoadTrack ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.RailTrack,
            function() return pub.options.sendRailTrack ~= false end)
        ServerEventDispatcher.registerSendCheck(HubCeTypes.TramTrack,
            function() return pub.options.sendTramTrack ~= false end)
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
