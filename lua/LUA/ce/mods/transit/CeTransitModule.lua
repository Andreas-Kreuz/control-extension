if CeDebugLoad then print("[#Start] Loading ce.mods.transit.CeTransitModule ...") end
---@class CeTransitModule
CeTransitModule = {}
CeTransitModule.id = "83ce6b42-1bda-45e0-8b4a-e8daeed047ab"
CeTransitModule.enabled = true
local initialized = false
CeTransitModule.name = "ce.mods.transit.CeTransitModule"
CeTransitModule.CeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitSettings = require("ce.mods.transit.TransitSettings")
local DepotSignalRegistry = require("ce.mods.transit.DepotSignalRegistry")
local DepotSignalReleaseUpdater = require("ce.mods.transit.DepotSignalReleaseUpdater")
local Line = require("ce.mods.transit.Line")
local RoadStation = require("ce.mods.transit.RoadStation")
local TransitTrainUpdater = require("ce.mods.transit.data.TransitTrainUpdater")
local TransitOptionDefaults = require("ce.mods.transit.options.TransitOptionDefaults")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")
local TableUtils = require("ce.hub.util.TableUtils")

local function withoutSelf(first, ...)
    if first == CeTransitModule then return ... end
    return first, ...
end

function CeTransitModule.loadSettingsFromSlot(first, ...)
    local eepSaveId = withoutSelf(first, ...)
    TransitSettings.loadSettingsFromSlot(eepSaveId)
    return CeTransitModule
end

function CeTransitModule.registerDepotSignals(first, ...)
    DepotSignalRegistry.register(withoutSelf(first, ...))
    return CeTransitModule
end

function CeTransitModule.newRoadStation(first, ...)
    local name, eepSaveId = withoutSelf(first, ...)
    return RoadStation:new(name, eepSaveId or -1)
end

function CeTransitModule.newLine(first, ...)
    return Line:new(withoutSelf(first, ...))
end

function CeTransitModule.getDisplayModel()
    return require("ce.mods.transit.models.RoadStationDisplayModel")
end

function CeTransitModule.setOptions(options)
    local mergedOptions = TableUtils.deepMerge(TransitOptionDefaults.create(),
                                               TransitOptionsRegistry.copyTable(options or {}))
    TransitOptionsRegistry.setOptions(mergedOptions)
    return CeTransitModule
end

function CeTransitModule.init()
    if not CeTransitModule.enabled or initialized then return end
    DepotSignalRegistry.forceHubOptions()

    local TransitBridgeConnector = require("ce.mods.transit.bridge.TransitBridgeConnector")
    TransitBridgeConnector.registerStatePublishers()
    TransitBridgeConnector.registerFunctions()

    initialized = true
end

function CeTransitModule.run()
    if not CeTransitModule.enabled then return end
    TransitTrainUpdater.runUpdate()
    DepotSignalReleaseUpdater.runUpdate()
end

return CeTransitModule
