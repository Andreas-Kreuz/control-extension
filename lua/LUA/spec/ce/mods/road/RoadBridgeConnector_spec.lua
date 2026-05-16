insulate("ce.mods.road.bridge.RoadBridgeConnector", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.mods.road.bridge.RoadBridgeConnector")
        clearModule("ce.databridge.ServerExchangeCoordinator")
        clearModule("ce.databridge.IncomingCommandExecutor")
        clearModule("ce.mods.road.IntersectionSettings")
        require("ce.hub.eep.EepSimulator")
    end)

    it("registers boolean IntersectionSettings commands", function ()
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local RoadBridgeConnector = require("ce.mods.road.bridge.RoadBridgeConnector")

        RoadBridgeConnector.registerFunctions()

        IncomingCommandExecutor.executeIncomingCommands("IntersectionSettings.setShowPhaseOnSignal|true")
        assert.is_true(IntersectionSettings.showPhaseOnSignal)

        IncomingCommandExecutor.executeIncomingCommands("IntersectionSettings.setShowPhaseOnSignal|false")
        assert.is_false(IntersectionSettings.showPhaseOnSignal)

        IncomingCommandExecutor.executeIncomingCommands("IntersectionSettings.setShowLaneNamesOnSignal|true")
        assert.is_true(IntersectionSettings.showLaneNamesOnSignal)

        IncomingCommandExecutor.executeIncomingCommands("IntersectionSettings.setShowLaneNamesOnSignal|false")
        assert.is_false(IntersectionSettings.showLaneNamesOnSignal)
    end)
end)
