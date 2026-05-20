insulate("ce.hub.data.signals.SignalStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local eepGetSignalStub
    local eepSignalGetTagTextStub
    local eepGetSignalTrainsCountStub
    local eepGetSignalTrainNameStub

    before_each(function ()
        clearModule("ce.hub.data.signals.SignalStatePublisher")
        clearModule("ce.hub.data.signals.SignalPublisher")
        clearModule("ce.hub.data.signals.SignalDiscovery")
        clearModule("ce.hub.data.signals.SignalDtoFactory")
        clearModule("ce.hub.data.signals.Signal")
        clearModule("ce.hub.data.signals.SignalRegistry")
        clearModule("ce.hub.data.signals.SignalUpdater")
        clearModule("ce.hub.data.signals.WaitingOnSignal")
        clearModule("ce.hub.data.signals.WaitingOnSignalRegistry")
        clearModule("ce.hub.data.InterestSyncRegistry")
        clearModule("ce.hub.data.HubCeTypes")
        clearModule("ce.hub.options.HubOptionsRegistry")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.hub.publish.DataChangeBus")

        local states = {
            [9] = {
                position = 2,
                tag = "North",
                waitingCount = 1,
                vehicles = { "Train X" }
            }
        }

        eepGetSignalStub = stub(_G, "EEPGetSignal", function (id)
            local entry = states[id]
            if not entry then return 0 end
            return entry.position
        end)
        eepSignalGetTagTextStub = stub(_G, "EEPSignalGetTagText", function (id)
            local entry = states[id]
            if not entry then return false, nil end
            return true, entry.tag
        end)
        eepGetSignalTrainsCountStub = stub(_G, "EEPGetSignalTrainsCount", function (id)
            local entry = states[id]
            if not entry then return nil end
            return entry.waitingCount
        end)
        eepGetSignalTrainNameStub = stub(_G, "EEPGetSignalTrainName", function (id, position)
            local entry = states[id]
            if not entry then return nil end
            return entry.vehicles[position]
        end)
    end)

    after_each(function ()
        eepGetSignalStub:revert()
        eepSignalGetTagTextStub:revert()
        eepGetSignalTrainsCountStub:revert()
        eepGetSignalTrainNameStub:revert()
    end)

    it("fires both ceTypes with placeholder values for unselected oninterest fields", function ()
        local SignalDiscovery = require("ce.hub.data.signals.SignalDiscovery")
        local SignalStatePublisher = require("ce.hub.data.signals.SignalStatePublisher")
        local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        SignalDiscovery.runInitialDiscovery()
        SignalUpdater.runUpdate()
        SignalStatePublisher.syncState()

        assert.same({
                        ["9"] = {
                            ceType = "ce.hub.Signal",
                            id = 9,
                            position = 2,
                            tag = "North",
                            waitingVehiclesCount = 0
                        }
                    }, DataStore.getCeType("ce.hub.Signal"))
        assert.same({
                        ["9-1"] = {
                            ceType = "ce.hub.WaitingOnSignal",
                            id = "9-1",
                            signalId = 9,
                            waitingPosition = 0,
                            vehicleName = "",
                            waitingCount = 0
                        }
                    }, DataStore.getCeType("ce.hub.WaitingOnSignal"))
    end)

    it("fires real oninterest values for selected signal and waiting entries", function ()
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
        local SignalDiscovery = require("ce.hub.data.signals.SignalDiscovery")
        local SignalStatePublisher = require("ce.hub.data.signals.SignalStatePublisher")
        local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        SignalDiscovery.runInitialDiscovery()
        SignalUpdater.runUpdate()
        InterestSyncRegistry.startSyncFor(HubCeTypes.Signal, "9")
        InterestSyncRegistry.startSyncFor(HubCeTypes.WaitingOnSignal, "9-1")
        SignalStatePublisher.syncState()

        assert.equals(1, DataStore.get("ce.hub.Signal", "9").waitingVehiclesCount)
        assert.same({
                        ceType = "ce.hub.WaitingOnSignal",
                        id = "9-1",
                        signalId = 9,
                        waitingPosition = 1,
                        vehicleName = "Train X",
                        waitingCount = 1
                    }, DataStore.get("ce.hub.WaitingOnSignal", "9-1"))
    end)

    it("does not publish unselected waiting patches when only oninterest fields changed", function ()
        local SignalDiscovery = require("ce.hub.data.signals.SignalDiscovery")
        local SignalStatePublisher = require("ce.hub.data.signals.SignalStatePublisher")
        local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")
        local WaitingOnSignalRegistry = require("ce.hub.data.signals.WaitingOnSignalRegistry")
        local DataChangeBus = require("ce.hub.publish.DataChangeBus")

        SignalDiscovery.runInitialDiscovery()
        SignalUpdater.runUpdate()
        SignalStatePublisher.syncState()

        local events = {}
        DataChangeBus.addListener({
            fireEvent = function (event) events[#events + 1] = event end
        })

        WaitingOnSignalRegistry.get("9-1"):update({
            signalId = 9,
            waitingPosition = 1,
            vehicleName = "Train Y",
            waitingCount = 1
        })
        SignalStatePublisher.syncState()

        assert.same({}, events)
    end)
end)
