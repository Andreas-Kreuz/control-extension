insulate("ce.mods.road.bridge.RoadBridgeConnector", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.eep.EepSimulatorRuntime")
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.util.StorageUtility")
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

    it("persists web setting changes across a Lua reload", function ()
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local RoadBridgeConnector = require("ce.mods.road.bridge.RoadBridgeConnector")

        RoadBridgeConnector.registerFunctions()
        IntersectionSettings.loadSettingsFromSlot(31)

        IncomingCommandExecutor.executeIncomingCommands("IntersectionSettings.setShowPhaseOnSignal|true")
        assert.is_true(IntersectionSettings.showPhaseOnSignal)

        clearModule("ce.hub.util.StorageUtility")
        clearModule("ce.mods.road.IntersectionSettings")
        IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        IntersectionSettings.loadSettingsFromSlot(31)

        assert.is_true(IntersectionSettings.showPhaseOnSignal)
    end)

    it("loads saved false values over previous true values", function ()
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

        EEPSaveData(32, "seqInfo=false,")
        IntersectionSettings.showPhaseOnSignal = true
        IntersectionSettings.loadSettingsFromSlot(32)

        assert.is_false(IntersectionSettings.showPhaseOnSignal)
    end)
end)
