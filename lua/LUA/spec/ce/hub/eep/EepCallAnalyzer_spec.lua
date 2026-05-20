insulate("EepCallAnalyzer #eepAnalyzer", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local originalIoOpen = io.open
    local originalEEPOnSaveAnl
    local originalEEPOnSignal7
    local originalEEPTestMulti
    local originalEEPTestError
    local printStub
    local writtenFiles

    local function stubFileWrites()
        return stub(io, "open", function (name, mode)
            if name == "./ce/databridge/exchange-test/ce-version.txt" or
                name == "exchange-dir/ce-version.txt" or
                name == "exchange-dir/eep-call-analysis.json" then
                return {
                    write = function (_, content)
                        writtenFiles[name] = (writtenFiles[name] or "") .. tostring(content)
                    end,
                    flush = function () end,
                    close = function () end
                }
            end

            return originalIoOpen(name, mode)
        end)
    end

    before_each(function ()
        writtenFiles = {}
        originalEEPOnSaveAnl = _G.EEPOnSaveAnl
        originalEEPOnSignal7 = _G.EEPOnSignal_7
        originalEEPTestMulti = _G.EEPTestMulti
        originalEEPTestError = _G.EEPTestError
        clearModule("ce.hub.eep.EepCallAnalyzer")
        clearModule("ce.databridge.ExchangeDirRegistry")
        printStub = stub(_G, "print")
        require("ce.hub.eep.EepSimulator")
    end)

    after_each(function ()
        local Analyzer = package.loaded["ce.hub.eep.EepCallAnalyzer"]
        if Analyzer then Analyzer.reset() end
        rawset(_G, "EEPOnSaveAnl", originalEEPOnSaveAnl)
        rawset(_G, "EEPOnSignal_7", originalEEPOnSignal7)
        rawset(_G, "EEPTestMulti", originalEEPTestMulti)
        rawset(_G, "EEPTestError", originalEEPTestError)
        printStub:revert()
    end)

    it("counts EEP calls and callbacks and writes the completed result", function ()
        local ioOpenStub = stubFileWrites()
        finally(function () ioOpenStub:revert() end)

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
        ExchangeDirRegistry.setExchangeDirectory("exchange-dir")
        local EepCallAnalyzer = require("ce.hub.eep.EepCallAnalyzer")
        local json = require("ce.third-party.json")

        rawset(_G, "EEPOnSaveAnl", function () return true end)

        EepCallAnalyzer.configure({ enabled = true, runs = 2 })
        EepCallAnalyzer.beginRun()
        EEPGetSignal(1)
        rawset(_G, "EEPOnSignal_7", function () return true end)
        EepCallAnalyzer.scanGlobals()
        _G.EEPOnSaveAnl("anlage.anl3")
        _G.EEPOnSignal_7(2)
        EepCallAnalyzer.endRun()

        EepCallAnalyzer.beginRun()
        EEPSetSignal(1, 2)
        EepCallAnalyzer.endRun()

        local result = json.decode(writtenFiles["exchange-dir/eep-call-analysis.json"])

        assert.equals("completed", result.status)
        assert.equals(2, result.runsTarget)
        assert.equals(2, result.runsObserved)
        assert.equals(2, result.totals.calls)
        assert.equals(2, result.totals.callbacks)
        assert.equals(1, result.calls.EEPGetSignal)
        assert.equals(1, result.calls.EEPSetSignal)
        assert.equals(1, result.callbacks.EEPOnSaveAnl)
        assert.equals(1, result.callbacks.EEPOnSignal_7)
        assert.equals(1, result.stackTraces.calls.EEPGetSignal[next(result.stackTraces.calls.EEPGetSignal)])
        assert.equals(1, result.stackTraces.calls.EEPSetSignal[next(result.stackTraces.calls.EEPSetSignal)])
        assert.equals(1, result.stackTraces.callbacks.EEPOnSaveAnl[next(
            result.stackTraces.callbacks.EEPOnSaveAnl
        )])
        assert.stub(printStub).was_called_with(
            "[#EepCallAnalyzer] EEP call analysis enabled for 2 ControlExtension runs"
        )
        assert.stub(printStub).was_called_with(
            "[#EepCallAnalyzer] Wrote EEP call analysis to exchange-dir/eep-call-analysis.json"
        )
    end)

    it("counts discovery calls separately from total calls", function ()
        local EepCallAnalyzer = require("ce.hub.eep.EepCallAnalyzer")

        rawset(_G, "EEPOnSaveAnl", function () return true end)

        EepCallAnalyzer.configure({ enabled = true, runs = 2 })
        EepCallAnalyzer.beginRun()
        EepCallAnalyzer.runInDiscovery(function ()
            EEPGetSignal(1)
            _G.EEPOnSaveAnl("anlage.anl3")
        end)
        EEPGetSignal(2)

        local result = EepCallAnalyzer.getResult()

        assert.equals(2, result.totals.calls)
        assert.equals(1, result.totals.callbacks)
        assert.equals(1, result.totals.discoveryCalls)
        assert.equals(2, result.calls.EEPGetSignal)
        assert.equals(1, result.discoveryCalls.EEPGetSignal)
        assert.equals(1, result.callbacks.EEPOnSaveAnl)
        assert.equals(1, result.stackTraces.discoveryCalls.EEPGetSignal[next(
            result.stackTraces.discoveryCalls.EEPGetSignal
        )])
    end)

    it("preserves multiple return values and propagates original errors", function ()
        local EepCallAnalyzer = require("ce.hub.eep.EepCallAnalyzer")

        rawset(_G, "EEPTestMulti", function () return true, "value", 3 end)
        rawset(_G, "EEPTestError", function () error("boom") end)

        EepCallAnalyzer.configure({ enabled = true, runs = 2 })
        EepCallAnalyzer.beginRun()
        EepCallAnalyzer.scanGlobals()

        local ok, text, count = _G.EEPTestMulti()
        assert.is_true(ok)
        assert.equals("value", text)
        assert.equals(3, count)
        assert.has_error(function () _G.EEPTestError() end, "boom")

        local result = EepCallAnalyzer.getResult()
        assert.equals(1, result.calls.EEPTestMulti)
        assert.equals(1, result.calls.EEPTestError)
    end)

    it("restores wrappers after the configured run count", function ()
        local ioOpenStub = stubFileWrites()
        finally(function () ioOpenStub:revert() end)

        local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
        ExchangeDirRegistry.setExchangeDirectory("exchange-dir")
        local EepCallAnalyzer = require("ce.hub.eep.EepCallAnalyzer")
        local originalEEPGetSignal = _G.EEPGetSignal

        EepCallAnalyzer.configure({ enabled = true, runs = 1 })
        EepCallAnalyzer.beginRun()
        assert.is_not_equal(originalEEPGetSignal, _G.EEPGetSignal)
        EepCallAnalyzer.endRun()

        assert.equals(originalEEPGetSignal, _G.EEPGetSignal)
    end)

    it("fails loudly for invalid analyser options", function ()
        local EepCallAnalyzer = require("ce.hub.eep.EepCallAnalyzer")

        assert.has_error(function () EepCallAnalyzer.configure({ enabled = true, runs = 0 }) end)
        assert.has_error(function () EepCallAnalyzer.configure({ enabled = "yes" }) end)
        assert.has_error(function () EepCallAnalyzer.configure(true) end)
    end)
end)
