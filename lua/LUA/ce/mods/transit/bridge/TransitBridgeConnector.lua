if CeDebugLoad then print("[#Start] Loading ce.mods.transit.bridge.TransitBridgeConnector ...") end
local StatePublisherRegistry = require("ce.hub.StatePublisherRegistry")
local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
local TransitSettings = require("ce.mods.transit.TransitSettings")

---@class TransitBridgeConnector
local TransitBridgeConnector = {}

local function toBooleanSetting(param)
    if param == true or param == "true" then return true end
    if param == false or param == "false" then return false end
    error("Expected boolean setting value")
end

function TransitBridgeConnector.registerStatePublishers()
    local publicTransportStatePublisher = require("ce.mods.transit.data.TransitStatePublisher")
    StatePublisherRegistry.registerStatePublishers(publicTransportStatePublisher)
end

function TransitBridgeConnector.registerFunctions()
    ServerExchangeCoordinator.registerAllowedCommand(
        "TransitSettings.setShowDepartureTippText",
        function (param)
            assert(TransitSettings.saveSlot,
                   "TransitSettings.setShowDepartureTippText from Web App needs " ..
                   "Transit.loadSettingsFromSlot(eepSaveId) or TransitSettings.loadSettingsFromSlot(eepSaveId) first.")
            TransitSettings.setShowDepartureTippText(toBooleanSetting(param))
        end
    )
end

return TransitBridgeConnector
