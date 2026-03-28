insulate("ce.hub.data.signals.SignalDtoFactory", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.signals.SignalDtoFactory")
    end)

    it("projects signals and waiting entries to detached DTO tables", function ()
        local SignalDtoFactory = require("ce.hub.data.signals.SignalDtoFactory")
        local signal = { id = 7, position = 1, tag = "Stop", waitingVehiclesCount = 3 }
        local waiting = {
            ceType = "ce.hub.WaitingOnSignal",
            id = "7-1",
            signalId = 7,
            waitingPosition = 1,
            vehicleName = "Bus 1",
            waitingCount = 3
        }

        local signalRoom, signalKeyId, signalKey, signalDto = SignalDtoFactory.createSignalDto(signal)
        local waitingRoom, waitingKeyId, waitingKey, waitingDto = SignalDtoFactory.createWaitingOnSignalDto(waiting)
        local signalListRoom, signalListKeyId, signalDtos = SignalDtoFactory.createSignalDtoList({ signal })
        local waitingListRoom, waitingListKeyId, waitingDtos =
            SignalDtoFactory.createWaitingOnSignalDtoList({ waiting })

        signal.tag = "Changed"
        waiting.vehicleName = "Changed"

        assert.equals("ce.hub.Signal", signalRoom)
        assert.equals("id", signalKeyId)
        assert.equals(7, signalKey)
        assert.same({
                        ceType = "ce.hub.Signal",
                        id = 7,
                        position = 1,
                        tag = "Stop",
                        waitingVehiclesCount = 3
                    }, signalDto)
        assert.equals("ce.hub.WaitingOnSignal", waitingRoom)
        assert.equals("id", waitingKeyId)
        assert.equals("7-1", waitingKey)
        assert.same({
                        ceType = "ce.hub.WaitingOnSignal",
                        id = "7-1",
                        signalId = 7,
                        waitingPosition = 1,
                        vehicleName = "Bus 1",
                        waitingCount = 3
                    }, waitingDto)
        assert.equals("ce.hub.Signal", signalListRoom)
        assert.equals("id", signalListKeyId)
        assert.same({
                        {
                            ceType = "ce.hub.Signal",
                            id = 7,
                            position = 1,
                            tag = "Stop",
                            waitingVehiclesCount = 3
                        }
                    }, signalDtos)
        assert.equals("ce.hub.WaitingOnSignal", waitingListRoom)
        assert.equals("id", waitingListKeyId)
        assert.same({
                        {
                            ceType = "ce.hub.WaitingOnSignal",
                            id = "7-1",
                            signalId = 7,
                            waitingPosition = 1,
                            vehicleName = "Bus 1",
                            waitingCount = 3
                        }
                    }, waitingDtos)
    end)
end)
