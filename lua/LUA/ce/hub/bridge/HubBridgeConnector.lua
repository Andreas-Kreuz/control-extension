if AkDebugLoad then print("[#Start] Loading ce.hub.bridge.HubBridgeConnector ...") end
local HubBridgeConnector = {}
local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")
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
        StatePublisherRegistry.registerStatePublishers(require("ce.hub.data.modules.ModulesStatePublisher"))
    end
    if isSelected(HubCeTypes.EepVersion) then
        StatePublisherRegistry.registerStatePublishers(require("ce.hub.data.version.VersionStatePublisher"))
    end
    if isSelected(HubCeTypes.Runtime) then
        StatePublisherRegistry.registerStatePublishers(require("ce.hub.data.runtime.RuntimeStatePublisher"))
    end
    if isSelected(HubCeTypes.SaveSlot, HubCeTypes.FreeSlot) then
        StatePublisherRegistry.registerStatePublishers(require("ce.hub.data.slots.DataSlotsStatePublisher"))
    end
    if isSelected(HubCeTypes.Signal, HubCeTypes.WaitingOnSignal) then
        StatePublisherRegistry.registerStatePublishers(require("ce.hub.data.signals.SignalStatePublisher"))
    end
    if isSelected(HubCeTypes.Switch) then
        StatePublisherRegistry.registerStatePublishers(require("ce.hub.data.switches.SwitchStatePublisher"))
    end
    if isSelected(HubCeTypes.Structure) then
        StatePublisherRegistry.registerStatePublishers(require("ce.hub.data.structures.StructureStatePublisher"))
    end
    if isSelected(HubCeTypes.Time) then
        StatePublisherRegistry.registerStatePublishers(require("ce.hub.data.time.TimeStatePublisher"))
    end
    if isSelected(HubCeTypes.Weather) then
        StatePublisherRegistry.registerStatePublishers(require("ce.hub.data.weather.WeatherStatePublisher"))
    end
    if isSelected(
            HubCeTypes.Train,
            HubCeTypes.RollingStock,
            HubCeTypes.RollingStockTextures,
            HubCeTypes.RollingStockRotation,
            HubCeTypes.AuxiliaryTrack,
            HubCeTypes.ControlTrack,
            HubCeTypes.RoadTrack,
            HubCeTypes.RailTrack,
            HubCeTypes.TramTrack
        ) then
        local TrainsAndTracksStatePublisher = require("ce.hub.data.trains.TrainsAndTracksStatePublisher")
        TrainsAndTracksStatePublisher.setCollectedCeTypes(collectedCeTypes)
        StatePublisherRegistry.registerStatePublishers(TrainsAndTracksStatePublisher)
    end
end

return HubBridgeConnector
