insulate("ce.databridge.ServerExchangeCoordinator", function ()
    require("ce.hub.eep.EepSimulator")

    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.databridge.ServerTransportSelector")
        clearModule("ce.databridge.ServerExchangeCoordinator")
    end)

    it("commits buffered events only after a successful transport write", function ()
        local ServerEventBuffer = require("ce.databridge.ServerEventBuffer")
        local ServerTransportSelector = require("ce.databridge.ServerTransportSelector")
        local transport = {
            isReady = function () return true end,
            getSessionId = function () return "session" end,
            writeOutgoingEvents = function () return false end
        }
        local selectorStub = stub(ServerTransportSelector, "getSelectedTransport", function () return transport end)
        finally(function () selectorStub:revert() end)

        local ServerExchangeCoordinator = require("ce.databridge.ServerExchangeCoordinator")
        ServerEventBuffer.fireEvent({ eventCounter = 1, type = "CompleteReset", payload = { info = "reset" } })

        ServerExchangeCoordinator.runServerOutputCycle()
        assert.matches("\"eventCounter\":1", ServerEventBuffer.peekBufferedEvents())

        transport.writeOutgoingEvents = function () return true end
        ServerExchangeCoordinator.runServerOutputCycle()
        assert.equals("", ServerEventBuffer.peekBufferedEvents())
    end)
end)
