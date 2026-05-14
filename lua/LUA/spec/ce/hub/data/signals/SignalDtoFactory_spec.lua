insulate("ce.hub.data.signals.SignalDtoFactory", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.signals.SignalDtoFactory")
        clearModule("ce.hub.options.HubOptionsRegistry")
    end)

    local function createSignal()
        return {
            id = 7,
            position = 1,
            tag = "Stop",
            waitingVehiclesCount = 3,
            stopDistance = 15,
            itemName = "Signal 7",
            itemNameWithModelPath = "Signals/Signal 7",
            signalFunctions = { "1", "2" },
            activeFunction = "1",
            getTag = function (self) return self.tag end,
            getStopDistance = function (self) return self.stopDistance end,
            getItemName = function (self) return self.itemName end,
            getItemNameWithModelPath = function (self) return self.itemNameWithModelPath end,
            getSignalFunctions = function (self) return self.signalFunctions end,
            getActiveFunction = function (self) return self.activeFunction end
        }
    end

    local function createWaiting()
        return {
            ceType = "ce.hub.WaitingOnSignal",
            id = "7-1",
            signalId = 7,
            waitingPosition = 1,
            vehicleName = "Bus 1",
            waitingCount = 3
        }
    end

    it("projects unselected signals and waiting entries with oninterest placeholders", function ()
        local SignalDtoFactory = require("ce.hub.data.signals.SignalDtoFactory")
        local signal = createSignal()
        local waiting = createWaiting()

        local signalRoom, signalKeyId, signalKey, signalDto = SignalDtoFactory.createSignalDto(signal)
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
                        waitingVehiclesCount = 0,
                        stopDistance = 15,
                        itemName = "Signal 7",
                        itemNameWithModelPath = "Signals/Signal 7",
                        signalFunctions = { "1", "2" },
                        activeFunction = "1"
                    }, signalDto)
        assert.equals("ce.hub.WaitingOnSignal", waitingListRoom)
        assert.equals("id", waitingListKeyId)
        assert.same({
                        {
                            ceType = "ce.hub.WaitingOnSignal",
                            id = "7-1",
                            signalId = 7,
                            waitingPosition = 0,
                            vehicleName = "",
                            waitingCount = 0
                        }
                    }, waitingDtos)
    end)

    it("projects selected signals and waiting entries with real oninterest values", function ()
        local SignalDtoFactory = require("ce.hub.data.signals.SignalDtoFactory")
        local signal = createSignal()
        local waiting = createWaiting()

        local _, _, _, signalDto = SignalDtoFactory.createSignalDto(signal, true)
        local _, _, _, waitingDto = SignalDtoFactory.createWaitingOnSignalDto(waiting, true)

        assert.equals(3, signalDto.waitingVehiclesCount)
        assert.same({
                        ceType = "ce.hub.WaitingOnSignal",
                        id = "7-1",
                        signalId = 7,
                        waitingPosition = 1,
                        vehicleName = "Bus 1",
                        waitingCount = 3
                    }, waitingDto)
    end)

    it("suppresses unselected oninterest waiting patch fields", function ()
        local SignalDtoFactory = require("ce.hub.data.signals.SignalDtoFactory")
        local waiting = createWaiting()

        local _, _, _, unselectedDto = SignalDtoFactory.createWaitingOnSignalPatchDto(waiting, {
            waitingPosition = true,
            vehicleName = true,
            waitingCount = true
        })
        local _, _, _, selectedDto = SignalDtoFactory.createWaitingOnSignalPatchDto(waiting, {
                                                                                        waitingPosition = true,
                                                                                        vehicleName = true,
                                                                                        waitingCount = true
                                                                                    }, true)

        assert.same({
                        ceType = "ce.hub.WaitingOnSignal",
                        id = "7-1"
                    }, unselectedDto)
        assert.same({
                        ceType = "ce.hub.WaitingOnSignal",
                        id = "7-1",
                        waitingPosition = 1,
                        vehicleName = "Bus 1",
                        waitingCount = 3
                    }, selectedDto)
    end)
end)
