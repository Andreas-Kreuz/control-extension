insulate("ce.mods.transit.bridge.TransitBridgeConnector", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.mods.transit.bridge.TransitBridgeConnector")
        clearModule("ce.databridge.ServerExchangeCoordinator")
        clearModule("ce.databridge.IncomingCommandExecutor")
        clearModule("ce.mods.transit.TransitSettings")
        require("ce.hub.eep.EepSimulator")
    end)

    it("registers boolean TransitSettings commands", function ()
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local TransitSettings = require("ce.mods.transit.TransitSettings")
        local TransitBridgeConnector = require("ce.mods.transit.bridge.TransitBridgeConnector")

        TransitBridgeConnector.registerFunctions()

        IncomingCommandExecutor.executeIncomingCommands("TransitSettings.setShowDepartureTippText|true")
        assert.is_true(TransitSettings.showDepartureTippText)

        IncomingCommandExecutor.executeIncomingCommands("TransitSettings.setShowDepartureTippText|false")
        assert.is_false(TransitSettings.showDepartureTippText)
    end)
end)
