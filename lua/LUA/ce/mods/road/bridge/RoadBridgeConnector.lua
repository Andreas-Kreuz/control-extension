if CeDebugLoad then print("[#Start] Loading ce.mods.road.bridge.RoadBridgeConnector ...") end
local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")
local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
local Intersection = require("ce.mods.road.Intersection")
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

---@class RoadBridgeConnector
local RoadBridgeConnector = {}

local function toBooleanSetting(param)
    if param == true or param == "true" then return true end
    if param == false or param == "false" then return false end
    error("Expected boolean setting value")
end

function RoadBridgeConnector.registerStatePublishers()
    local trafficLightModelStatePublisher = require("ce.mods.road.data.TrafficLightModelStatePublisher")
    local roadStatePublisher = require("ce.mods.road.data.RoadStatePublisher")
    StatePublisherRegistry.registerStatePublishers(trafficLightModelStatePublisher, roadStatePublisher)
end

function RoadBridgeConnector.registerFunctions()
    ServerExchangeCoordinator.registerAllowedCommand("IntersectionSettings.setShowRequestsOnSignal", function (param)
        IntersectionSettings.setShowRequestsOnSignal(toBooleanSetting(param))
    end)
    ServerExchangeCoordinator.registerAllowedCommand("IntersectionSettings.setShowPhaseOnSignal", function (param)
        IntersectionSettings.setShowPhaseOnSignal(toBooleanSetting(param))
    end)
    ServerExchangeCoordinator.registerAllowedCommand("IntersectionSettings.setShowModelInfoOnSignal", function (param)
        IntersectionSettings.setShowModelInfoOnSignal(toBooleanSetting(param))
    end)
    ServerExchangeCoordinator.registerAllowedCommand("IntersectionSettings.setShowLaneNamesOnSignal", function (param)
        IntersectionSettings.setShowLaneNamesOnSignal(toBooleanSetting(param))
    end)
    local showNameAndPhaseFunction = "IntersectionSettings.setShowNameAndPhaseOnSignal"
    ServerExchangeCoordinator.registerAllowedCommand(showNameAndPhaseFunction, function (param)
        IntersectionSettings.setShowNameAndPhaseOnSignal(toBooleanSetting(param))
    end)
    ServerExchangeCoordinator.registerAllowedCommand("IntersectionSettings.setShowSignalIdOnSignal", function (param)
        IntersectionSettings.setShowSignalIdOnSignal(toBooleanSetting(param))
    end)
    ServerExchangeCoordinator.registerAllowedCommand("IntersectionSettings.setShowLanesOnStructure", function (param)
        IntersectionSettings.setShowLanesOnStructure(toBooleanSetting(param))
    end)
    ServerExchangeCoordinator.registerAllowedCommand("AkKreuzungSchalteAutomatisch", Intersection.switchAutomatically)
    ServerExchangeCoordinator.registerAllowedCommand("AkKreuzungSchalteManuell", Intersection.switchManuallyTo)
end

return RoadBridgeConnector
