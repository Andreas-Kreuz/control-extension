if CeDebugLoad then print("[#Start] Loading ce.mods.road.CeRoadModule ...") end
---@class CeRoadModule
CeRoadModule = {}
CeRoadModule.id = "c5a3e6d3-0f9b-4c89-a908-ed8cf8809362"
CeRoadModule.enabled = true
local initialized = false
CeRoadModule.name = "ce.mods.road.CeRoadModule"
CeRoadModule.CeTypes = require("ce.mods.road.data.RoadCeTypes")
local CeTypeRegistry = require("ce.hub.data.CeTypeRegistry")
local Intersection = require("ce.mods.road.Intersection")
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

CeTypeRegistry.registerCeTypes(
    { ceType = CeRoadModule.CeTypes.Intersection, keyId = "id", owner = CeRoadModule.name },
    { ceType = CeRoadModule.CeTypes.IntersectionLane, keyId = "id", owner = CeRoadModule.name },
    { ceType = CeRoadModule.CeTypes.IntersectionSwitching, keyId = "id", owner = CeRoadModule.name },
    { ceType = CeRoadModule.CeTypes.IntersectionTrafficLight, keyId = "id", owner = CeRoadModule.name },
    { ceType = CeRoadModule.CeTypes.ModuleSetting, keyId = "name", owner = CeRoadModule.name },
    { ceType = CeRoadModule.CeTypes.SignalTypeDefinition, keyId = "id", owner = CeRoadModule.name }
)

function CeRoadModule.loadSettingsFromSlot(eepSaveId) return IntersectionSettings.loadSettingsFromSlot(eepSaveId) end

function CeRoadModule.init()
    if not CeRoadModule.enabled or initialized then return end

    local RoadBridgeConnector = require("ce.mods.road.bridge.RoadBridgeConnector")
    RoadBridgeConnector.registerStatePublishers()
    RoadBridgeConnector.registerFunctions()

    Intersection.initSequences()

    initialized = true
end

function CeRoadModule.run()
    if not CeRoadModule.enabled then return end
    Intersection.switchSequences()
end

return CeRoadModule
