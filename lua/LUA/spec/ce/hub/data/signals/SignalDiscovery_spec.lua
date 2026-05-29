---@diagnostic disable: need-check-nil
insulate("ce.hub.data.signals.SignalDiscovery", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.signals.Signal")
        clearModule("ce.hub.data.signals.SignalDiscovery")
        clearModule("ce.hub.data.signals.SignalRegistry")
        clearModule("ce.hub.options.HubOptionDefaults")
        clearModule("ce.hub.options.HubOptionsRegistry")
    end)

    it("seeds tag, tippText, tippTextVisible, stopDistance and itemName from anl3 without calling EEP", function ()
        local eepChangeCalls = 0
        local eepShowCalls = 0
        local eepItemNameCalls = 0
        local eepStopDistanceCalls = 0
        local changeStub = stub(_G, "EEPChangeInfoSignal", function () eepChangeCalls = eepChangeCalls + 1 end)
        local showStub = stub(_G, "EEPShowInfoSignal", function () eepShowCalls = eepShowCalls + 1 end)
        local itemNameStub = stub(_G, "EEPGetSignalItemName", function ()
            eepItemNameCalls = eepItemNameCalls + 1
            return false, nil
        end)
        local stopDistanceStub = stub(_G, "EEPGetSignalStopDistance", function ()
            eepStopDistanceCalls = eepStopDistanceCalls + 1
            return false, nil
        end)

        local SignalDiscovery = require("ce.hub.data.signals.SignalDiscovery")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")

        SignalDiscovery.initFromAnl3({
            coverage = { signals = true },
            signals = {
                {
                    keyId = 31,
                    tag = "s1tag,",
                    tipTxt = "Signal 1",
                    tipShow = true,
                    stopDistance = 1.0,
                    itemName = "Ampel2_1_neutr_oM_DH1",
                    itemNameWithModelPath = "Signale\\Signale\\Ampel2_1_neutr_oM_DH1.3dm"
                },
                { keyId = 32, tipShow = false }
            }
        })

        local s1 = SignalRegistry.get(31)
        assert.is_not_nil(s1)
        assert.equals("s1tag,", s1:getTag())
        assert.equals("Signal 1", s1:getTippText())
        assert.is_true(s1:getTippTextVisible())
        assert.equals(1.0, s1:getStopDistance())
        assert.equals("Ampel2_1_neutr_oM_DH1", s1:getItemName())
        assert.equals("Signale\\Signale\\Ampel2_1_neutr_oM_DH1.3dm", s1:getItemNameWithModelPath())

        local s2 = SignalRegistry.get(32)
        assert.is_not_nil(s2)
        assert.equals("", s2:getTag())
        assert.is_nil(s2:getTippText() ~= "" or nil)
        assert.is_false(s2:getTippTextVisible())

        assert.equals(0, eepChangeCalls)
        assert.equals(0, eepShowCalls)
        assert.equals(0, eepItemNameCalls)
        assert.equals(0, eepStopDistanceCalls)
        changeStub:revert()
        showStub:revert()
        itemNameStub:revert()
        stopDistanceStub:revert()
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

    it("loads signal item names during non-anl3 discovery", function ()
        local itemNameCalls = {}
        local getSignalStub = stub(_G, "EEPGetSignal", function (id)
            return id == 9 and 1 or 0
        end)
        local itemNameStub = stub(_G, "EEPGetSignalItemName", function (id, includeModelPath)
            itemNameCalls[#itemNameCalls + 1] = { id = id, includeModelPath = includeModelPath == true }
            if includeModelPath then return true, "Signale\\Signale\\Ampel2_1_neutr_oM_DH1.3dm" end
            return true, "Ampel2_1_neutr_oM_DH1"
        end)

        local SignalDiscovery = require("ce.hub.data.signals.SignalDiscovery")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")

        SignalDiscovery.runInitialDiscovery()

        local signal = SignalRegistry.get(9)
        assert.is_not_nil(signal)
        assert.equals("Ampel2_1_neutr_oM_DH1", signal:getItemName())
        assert.equals("Signale\\Signale\\Ampel2_1_neutr_oM_DH1.3dm", signal:getItemNameWithModelPath())
        assert.same({
                        { id = 9, includeModelPath = false },
                        { id = 9, includeModelPath = true }
                    }, itemNameCalls)

        getSignalStub:revert()
        itemNameStub:revert()
    end)
end)
