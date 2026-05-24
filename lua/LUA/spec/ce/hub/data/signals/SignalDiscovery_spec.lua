insulate("ce.hub.data.signals.SignalDiscovery", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.signals.Signal")
        clearModule("ce.hub.data.signals.SignalDiscovery")
        clearModule("ce.hub.data.signals.SignalRegistry")
        clearModule("ce.hub.options.HubOptionDefaults")
        clearModule("ce.hub.options.HubOptionsRegistry")
    end)

    it("seeds tag, tippText and tippTextVisible from anl3 without calling EEP", function ()
        local eepChangeCalls = 0
        local eepShowCalls = 0
        local changeStub = stub(_G, "EEPChangeInfoSignal", function () eepChangeCalls = eepChangeCalls + 1 end)
        local showStub = stub(_G, "EEPShowInfoSignal", function () eepShowCalls = eepShowCalls + 1 end)

        local SignalDiscovery = require("ce.hub.data.signals.SignalDiscovery")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")

        SignalDiscovery.initFromAnl3({
            coverage = { signals = true },
            signals = {
                { keyId = 31, tag = "s1tag,", tipTxt = "Signal 1", tipShow = true },
                { keyId = 32, tipShow = false }
            }
        })

        local s1 = SignalRegistry.get(31)
        assert.is_not_nil(s1)
        assert.equals("s1tag,", s1:getTag())
        assert.equals("Signal 1", s1:getTippText())
        assert.is_true(s1:getTippTextVisible())

        local s2 = SignalRegistry.get(32)
        assert.is_not_nil(s2)
        assert.equals("", s2:getTag())
        assert.is_nil(s2:getTippText() ~= "" or nil)
        assert.is_false(s2:getTippTextVisible())

        assert.equals(0, eepChangeCalls)
        assert.equals(0, eepShowCalls)
        changeStub:revert()
        showStub:revert()
    end)

    it("skips signals without keyId", function ()
        local SignalDiscovery = require("ce.hub.data.signals.SignalDiscovery")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")

        SignalDiscovery.initFromAnl3({
            coverage = { signals = true },
            signals = { { name = "S1" } }
        })

        assert.same({}, SignalRegistry.getAll())
    end)
end)
