if CeDebugLoad then print("[#Start] Loading ce.mods.transit.CeTransitModule ...") end
---@class CeTransitModule
CeTransitModule = {}
CeTransitModule.id = "83ce6b42-1bda-45e0-8b4a-e8daeed047ab"
CeTransitModule.enabled = true
local initialized = false
CeTransitModule.name = "ce.mods.transit.CeTransitModule"
CeTransitModule.CeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitSettings = require("ce.mods.transit.TransitSettings")
local TransitTrainUpdater = require("ce.mods.transit.data.TransitTrainUpdater")
local TransitOptionDefaults = require("ce.mods.transit.options.TransitOptionDefaults")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")
local TableUtils = require("ce.hub.util.TableUtils")

function CeTransitModule.loadSettingsFromSlot(eepSaveId) return TransitSettings.loadSettingsFromSlot(eepSaveId) end

function CeTransitModule.setOptions(options)
    local mergedOptions = TableUtils.deepMerge(TransitOptionDefaults.create(),
                                               TransitOptionsRegistry.copyTable(options or {}))
    TransitOptionsRegistry.setOptions(mergedOptions)
    return CeTransitModule
end

function CeTransitModule.init()
    if not CeTransitModule.enabled or initialized then return end

    local TransitBridgeConnector = require("ce.mods.transit.bridge.TransitBridgeConnector")
    TransitBridgeConnector.registerStatePublishers()
    TransitBridgeConnector.registerFunctions()

    initialized = true
end

function CeTransitModule.run()
    if not CeTransitModule.enabled then return end
    TransitTrainUpdater.runUpdate()
end

return CeTransitModule
