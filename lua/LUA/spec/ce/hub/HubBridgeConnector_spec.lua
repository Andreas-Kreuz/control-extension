insulate("ce.hub.HubBridgeConnector", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.HubBridgeConnector")
        clearModule("ce.hub.data.DynamicUpdateRegistry")
        clearModule("ce.databridge.ServerExchangeCoordinator")
        clearModule("ce.databridge.IncomingCommandExecutor")
        require("ce.hub.eep.EepSimulator")
    end)

    it("registers commands for dynamic update selection", function ()
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local HubBridgeConnector = require("ce.hub.HubBridgeConnector")
        local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")

        HubBridgeConnector.registerFunctions()

        IncomingCommandExecutor.executeIncomingCommands(
            "HubDynamicData.startUpdatesFor|" .. HubCeTypes.Train .. "|T1"
        )
        assert.is_true(DynamicUpdateRegistry.isSelected(HubCeTypes.Train, "T1"))

        IncomingCommandExecutor.executeIncomingCommands(
            "HubDynamicData.stopUpdatesFor|" .. HubCeTypes.Train .. "|T1"
        )
        assert.is_false(DynamicUpdateRegistry.isSelected(HubCeTypes.Train, "T1"))
    end)
end)
