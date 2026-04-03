if AkDebugLoad then print("[#Start] Loading ce.mods.transit.CeTransitModule ...") end
---@class CeTransitModule
CeTransitModule = {}
CeTransitModule.id = "83ce6b42-1bda-45e0-8b4a-e8daeed047ab"
CeTransitModule.enabled = true
local initialized = false
CeTransitModule.name = "ce.mods.transit.CeTransitModule"
CeTransitModule.CeTypes = require("ce.mods.transit.data.TransitCeTypes")
local CeTypeRegistry = require("ce.hub.data.CeTypeRegistry")
local TransitSettings = require("ce.mods.transit.TransitSettings")

CeTypeRegistry.registerCeTypes(
    { ceType = CeTransitModule.CeTypes.Station, keyId = "id", owner = CeTransitModule.name },
    { ceType = CeTransitModule.CeTypes.Line, keyId = "id", owner = CeTransitModule.name },
    { ceType = CeTransitModule.CeTypes.ModuleSetting, keyId = "name", owner = CeTransitModule.name },
    { ceType = CeTransitModule.CeTypes.LineName, keyId = "id", owner = CeTransitModule.name }
)

function CeTransitModule.loadSettingsFromSlot(eepSaveId) return TransitSettings.loadSettingsFromSlot(eepSaveId) end

function CeTransitModule.init()
    if not CeTransitModule.enabled or initialized then return end

    local TransitBridgeConnector = require("ce.mods.transit.bridge.TransitBridgeConnector")
    TransitBridgeConnector.registerStatePublishers()
    TransitBridgeConnector.registerFunctions()

    initialized = true
end

function CeTransitModule.run()
    if not CeTransitModule.enabled then return end
end

return CeTransitModule
