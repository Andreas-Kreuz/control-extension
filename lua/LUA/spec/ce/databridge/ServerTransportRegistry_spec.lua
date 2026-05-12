insulate("ce.databridge.ServerTransportRegistry", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.databridge.ServerTransportRegistry")
    end)

    it("defaults to pipe and validates transport names", function ()
        local ServerTransportRegistry = require("ce.databridge.ServerTransportRegistry")

        assert.equals("pipe", ServerTransportRegistry.getTransport())
        assert.equals("file", ServerTransportRegistry.setTransport("file"))
        assert.equals("file", ServerTransportRegistry.getTransport())
        assert.has_error(function () ServerTransportRegistry.setTransport("socket") end)
    end)
end)
