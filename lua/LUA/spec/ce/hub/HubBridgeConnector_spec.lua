insulate("ce.hub.HubBridgeConnector", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.HubBridgeConnector")
        clearModule("ce.hub.data.InterestSyncRegistry")
        clearModule("ce.databridge.ServerExchangeCoordinator")
        clearModule("ce.databridge.IncomingCommandExecutor")
        require("ce.hub.eep.EepSimulator")
    end)

    it("registers commands for dynamic update selection", function ()
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local HubBridgeConnector = require("ce.hub.HubBridgeConnector")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")

        HubBridgeConnector.registerFunctions()

        IncomingCommandExecutor.executeIncomingCommands(
            "HubInterestSync.startSyncFor|" .. HubCeTypes.Train .. "|T1"
        )
        assert.is_true(InterestSyncRegistry.isSelected(HubCeTypes.Train, "T1"))

        IncomingCommandExecutor.executeIncomingCommands(
            "HubInterestSync.stopSyncFor|" .. HubCeTypes.Train .. "|T1"
        )
        assert.is_false(InterestSyncRegistry.isSelected(HubCeTypes.Train, "T1"))
    end)
end)
