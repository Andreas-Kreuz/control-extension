insulate("ce.hub.data.signals.SignalUpdater", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local eepGetSignalStub
    local eepSignalGetTagTextStub
    local eepGetSignalTrainsCountStub
    local eepGetSignalTrainNameStub
    local trainNameCalls

    local function clearSignalModules()
        clearModule("ce.hub.data.signals.Signal")
        clearModule("ce.hub.data.signals.SignalRegistry")
        clearModule("ce.hub.data.signals.WaitingOnSignal")
        clearModule("ce.hub.data.signals.WaitingOnSignalRegistry")
        clearModule("ce.hub.data.signals.SignalUpdater")
        clearModule("ce.hub.options.HubOptionsRegistry")
    end

    before_each(function ()
        clearSignalModules()
        trainNameCalls = 0
    end)

    after_each(function ()
        if eepGetSignalStub then eepGetSignalStub:revert() end
        if eepSignalGetTagTextStub then eepSignalGetTagTextStub:revert() end
        if eepGetSignalTrainsCountStub then eepGetSignalTrainsCountStub:revert() end
        if eepGetSignalTrainNameStub then eepGetSignalTrainNameStub:revert() end
        eepGetSignalStub = nil
        eepSignalGetTagTextStub = nil
        eepGetSignalTrainsCountStub = nil
        eepGetSignalTrainNameStub = nil
    end)

    local function addSignal(signalId)
        local Signal = require("ce.hub.data.signals.Signal")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
        SignalRegistry.add(Signal:new(signalId))
    end

    local function stubSignalState(states)
        eepGetSignalStub = stub(_G, "EEPGetSignal", function (id)
            return states[id] and states[id].position or 0
        end)
        eepSignalGetTagTextStub = stub(_G, "EEPSignalGetTagText", function () return false, nil end)
        eepGetSignalTrainsCountStub = stub(_G, "EEPGetSignalTrainsCount", function (id)
            return states[id] and states[id].waitingCount or 0
        end)
        eepGetSignalTrainNameStub = stub(_G, "EEPGetSignalTrainName", function (id, position)
            trainNameCalls = trainNameCalls + 1
            return states[id] and states[id].vehicles[position] or nil
        end)
    end

    it("updates waiting vehicle names in SignalUpdater", function ()
        stubSignalState({ [5] = { position = 1, waitingCount = 1, vehicles = { "Train A" } } })
        addSignal(5)

        local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")
        local WaitingOnSignalRegistry = require("ce.hub.data.signals.WaitingOnSignalRegistry")

        SignalUpdater.runUpdate()

        assert.equals("Train A", WaitingOnSignalRegistry.get("5-1").vehicleName)
        assert.equals(1, trainNameCalls)
    end)

    it("throttles unchanged waiting vehicle name reads", function ()
        stubSignalState({ [5] = { position = 1, waitingCount = 1, vehicles = { "Train A" } } })
        addSignal(5)

        local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")

        SignalUpdater.runUpdate()
        for _ = 1, 9 do SignalUpdater.runUpdate() end

        assert.equals(1, trainNameCalls)

        SignalUpdater.runUpdate()

        assert.equals(2, trainNameCalls)
    end)

    it("refreshes watched signals immediately when their waiting count changes", function ()
        local states = { [6] = { position = 1, waitingCount = 0, vehicles = {} } }
        stubSignalState(states)
        addSignal(6)

        local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")
        local WaitingOnSignalRegistry = require("ce.hub.data.signals.WaitingOnSignalRegistry")
        WaitingOnSignalRegistry.watchSignal(6)

        SignalUpdater.runUpdate()
        states[6].waitingCount = 1
        states[6].vehicles = { "Train B" }
        SignalUpdater.runUpdate()

        assert.equals("Train B", WaitingOnSignalRegistry.get("6-1").vehicleName)
        assert.equals(1, trainNameCalls)
    end)
end)
