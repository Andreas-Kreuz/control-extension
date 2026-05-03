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

        IncomingCommandExecutor.executeIncomingCommands("IntersectionSettings.setShowSequenceOnSignal|true")
        assert.is_true(IntersectionSettings.showSequenceOnSignal)

        IncomingCommandExecutor.executeIncomingCommands("IntersectionSettings.setShowSequenceOnSignal|false")
        assert.is_false(IntersectionSettings.showSequenceOnSignal)
    end)
end)
