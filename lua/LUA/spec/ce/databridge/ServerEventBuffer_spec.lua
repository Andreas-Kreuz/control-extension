insulate("ce.databridge.ServerEventBuffer", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.databridge.ServerEventBuffer")
    end)

    it("peeks without clearing and commits after successful writes", function ()
        local ServerEventBuffer = require("ce.databridge.ServerEventBuffer")

        ServerEventBuffer.fireEvent({ eventCounter = 1, type = "CompleteReset", payload = { info = "reset" } })
        assert.matches("\"eventCounter\":1", ServerEventBuffer.peekBufferedEvents())
        assert.matches("\"eventCounter\":1", ServerEventBuffer.peekBufferedEvents())

        ServerEventBuffer.commitBufferedEvents()
        assert.equals("", ServerEventBuffer.peekBufferedEvents())
    end)
end)
