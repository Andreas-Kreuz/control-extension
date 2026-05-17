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

        TransitSettings.loadSettingsFromSlot(42)
        TransitBridgeConnector.registerFunctions()

        IncomingCommandExecutor.executeIncomingCommands("TransitSettings.setShowDepartureTippText|true")
        assert.is_true(TransitSettings.showDepartureTippText)

        IncomingCommandExecutor.executeIncomingCommands("TransitSettings.setShowDepartureTippText|false")
        assert.is_false(TransitSettings.showDepartureTippText)
    end)

    it("does not accept Web App setting changes before a transit settings slot is configured", function ()
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local TransitSettings = require("ce.mods.transit.TransitSettings")
        local TransitBridgeConnector = require("ce.mods.transit.bridge.TransitBridgeConnector")
        local printedError = nil

        local printStub = stub(_G, "print", function (message) printedError = message end)
        finally(function () printStub:revert() end)

        TransitBridgeConnector.registerFunctions()
        IncomingCommandExecutor.executeIncomingCommands("TransitSettings.setShowDepartureTippText|true")

        assert.is_false(TransitSettings.showDepartureTippText)
        assert.matches("TransitSettings.setShowDepartureTippText from Web App needs", printedError)
    end)

    it("persists tooltip setting changes from Web App commands when a settings slot is configured", function ()
        local IncomingCommandExecutor = require("ce.databridge.IncomingCommandExecutor")
        local StorageUtility = require("ce.hub.util.StorageUtility")
        local TransitSettings = require("ce.mods.transit.TransitSettings")
        local TransitBridgeConnector = require("ce.mods.transit.bridge.TransitBridgeConnector")

        TransitSettings.loadSettingsFromSlot(43)
        TransitBridgeConnector.registerFunctions()

        IncomingCommandExecutor.executeIncomingCommands("TransitSettings.setShowDepartureTippText|true")

        local data = StorageUtility.loadTable(43, "Transit settings")
        assert.equals("true", data["depInfo"])
    end)
end)
