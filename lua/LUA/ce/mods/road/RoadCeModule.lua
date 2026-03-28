if AkDebugLoad then print("[#Start] Loading ce.mods.road.RoadCeModule ...") end
---@class RoadCeModule
RoadCeModule = {}
RoadCeModule.id = "c5a3e6d3-0f9b-4c89-a908-ed8cf8809362"
RoadCeModule.enabled = true
local initialized = false
RoadCeModule.name = "ce.mods.road.RoadCeModule"
RoadCeModule.CeTypes = require("ce.mods.road.data.RoadCeTypes")
local CeTypeRegistry = require("ce.hub.data.CeTypeRegistry")
local Intersection = require("ce.mods.road.Intersection")
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

CeTypeRegistry.registerCeTypes(
    { ceType = RoadCeModule.CeTypes.Intersection, keyId = "id", owner = RoadCeModule.name },
    { ceType = RoadCeModule.CeTypes.IntersectionLane, keyId = "id", owner = RoadCeModule.name },
    { ceType = RoadCeModule.CeTypes.IntersectionSwitching, keyId = "id", owner = RoadCeModule.name },
    { ceType = RoadCeModule.CeTypes.IntersectionTrafficLight, keyId = "id", owner = RoadCeModule.name },
    { ceType = RoadCeModule.CeTypes.ModuleSetting, keyId = "name", owner = RoadCeModule.name },
    { ceType = RoadCeModule.CeTypes.SignalTypeDefinition, keyId = "id", owner = RoadCeModule.name }
)

function RoadCeModule.loadSettingsFromSlot(eepSaveId) return IntersectionSettings.loadSettingsFromSlot(eepSaveId) end

function RoadCeModule.init()
    if not RoadCeModule.enabled or initialized then return end

    local RoadBridgeConnector = require("ce.mods.road.bridge.RoadBridgeConnector")
    RoadBridgeConnector.registerStatePublishers()
    RoadBridgeConnector.registerFunctions()

    Intersection.initSequences()

    initialized = true
end

function RoadCeModule.run()
    if not RoadCeModule.enabled then return end
    Intersection.switchSequences()
end

return RoadCeModule
