if CeDebugLoad then print("[#Start] Loading ce.mods.road.CeRoadModule ...") end
---@class CeRoadModule
CeRoadModule = {}
CeRoadModule.id = "c5a3e6d3-0f9b-4c89-a908-ed8cf8809362"
CeRoadModule.enabled = true
local initialized = false
CeRoadModule.name = "ce.mods.road.CeRoadModule"
CeRoadModule.CeTypes = require("ce.mods.road.data.RoadCeTypes")
local Intersection = require("ce.mods.road.Intersection")
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

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
