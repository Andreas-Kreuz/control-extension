insulate("ce.hub.data.signals.SignalDataCollector", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.signals.SignalDataCollector")

        local states = {
            [5] = {
                position = 2,
                tag = "Entry",
                stopDistance = 12.5,
                itemName = "Signal 5",
                itemNameWithModelPath = "Signals/Signal 5",
                functions = { 1, 2, 4 },
                waitingCount = 2,
                vehicles = { "Train A", "Train B" }
            }
        }

        stub(_G, "EEPGetSignal", function (id)
            local entry = states[id]
            if not entry then return 0 end
            return entry.position
        end)
        stub(_G, "EEPSignalGetTagText", function (id)
            local entry = states[id]
            if not entry then return false, nil end
            return true, entry.tag
        end)
        stub(_G, "EEPGetSignalTrainsCount", function (id)
            local entry = states[id]
            if not entry then return nil end
            return entry.waitingCount
        end)
        stub(_G, "EEPGetSignalTrainName", function (id, position)
            local entry = states[id]
            if not entry then return nil end
            return entry.vehicles[position]
        end)
        stub(_G, "EEPGetSignalStopDistance", function (id)
            local entry = states[id]
            if not entry then return false, nil end
            return true, entry.stopDistance
        end)
        stub(_G, "EEPGetSignalItemName", function (id, includeModelPath)
            local entry = states[id]
            if not entry then return false, nil end
            return true, includeModelPath and entry.itemNameWithModelPath or entry.itemName
        end)
        stub(_G, "EEPGetSignalFunctions", function (id)
            local entry = states[id]
            if not entry then return false, 0 end
            return true, #entry.functions
        end)
        stub(_G, "EEPGetSignalFunction", function (id, selectionIndex)
            local entry = states[id]
            if not entry then return false, nil end
            return true, entry.functions[selectionIndex]
        end)
    end)

    after_each(function ()
        _G.EEPGetSignal:revert()
        _G.EEPSignalGetTagText:revert()
        _G.EEPGetSignalTrainsCount:revert()
        _G.EEPGetSignalTrainName:revert()
        _G.EEPGetSignalStopDistance:revert()
        _G.EEPGetSignalItemName:revert()
        _G.EEPGetSignalFunctions:revert()
        _G.EEPGetSignalFunction:revert()
    end)

    it("collects initial signals by id", function ()
        local SignalDataCollector = require("ce.hub.data.signals.SignalDataCollector")

        local signals = SignalDataCollector.collectInitialSignals()

        assert.same(1, #signals)
        assert.same({ id = 5 }, signals[1])
    end)

    it("refreshes signal fields and derives waiting vehicles", function ()
        local SignalDataCollector = require("ce.hub.data.signals.SignalDataCollector")

        local signals = SignalDataCollector.collectInitialSignals()
        SignalDataCollector.refreshSignals(signals)
        local waitingOnSignals = SignalDataCollector.collectWaitingOnSignals(signals)

        assert.same({
                        id = 5,
                        position = 2,
                        tag = "Entry",
                        stopDistance = 12.5,
                        itemName = "Signal 5",
                        itemNameWithModelPath = "Signals/Signal 5",
                        signalFunctions = { "1", "2", "4" },
                        activeFunction = "2",
                        waitingVehiclesCount = 2
                    }, signals[1])
        assert.same({
                        {
                            id = "5-1",
                            signalId = 5,
                            waitingPosition = 1,
                            vehicleName = "Train A",
                            waitingCount = 2
                        },
                        {
                            id = "5-2",
                            signalId = 5,
                            waitingPosition = 2,
                            vehicleName = "Train B",
                            waitingCount = 2
                        }
                    }, waitingOnSignals)
    end)
end)
