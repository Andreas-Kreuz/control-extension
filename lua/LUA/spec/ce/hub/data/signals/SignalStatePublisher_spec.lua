insulate("ce.hub.data.signals.SignalStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.signals.SignalStatePublisher")
        clearModule("ce.hub.data.signals.SignalDiscovery")
        clearModule("ce.hub.data.signals.SignalDtoFactory")
        clearModule("ce.hub.data.signals.SignalRegistry")
        clearModule("ce.hub.data.signals.SignalUpdater")
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
    end)

    after_each(function ()
        _G.EEPGetSignal:revert()
        _G.EEPSignalGetTagText:revert()
        _G.EEPGetSignalTrainsCount:revert()
        _G.EEPGetSignalTrainName:revert()
    end)

    it("fires both ceTypes with the existing wire format", function ()
        local SignalDiscovery = require("ce.hub.data.signals.SignalDiscovery")
        local SignalStatePublisher = require("ce.hub.data.signals.SignalStatePublisher")
        local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        SignalDiscovery.runInitialDiscovery()
        SignalUpdater.runUpdate(SignalStatePublisher.options)
        SignalStatePublisher.syncState()

        assert.same({
                        ["9"] = {
                            ceType = "ce.hub.Signal",
                            id = 9,
                            position = 2,
                            tag = "North",
                            waitingVehiclesCount = 1
                        }
                    }, DataStore.getCeType("ce.hub.Signal"))
        assert.same({
                        ["9-1"] = {
                            ceType = "ce.hub.WaitingOnSignal",
                            id = "9-1",
                            signalId = 9,
                            waitingPosition = 1,
                            vehicleName = "Train X",
                            waitingCount = 1
                        }
                    }, DataStore.getCeType("ce.hub.WaitingOnSignal"))
    end)
end)
