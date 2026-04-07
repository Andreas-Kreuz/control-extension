if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainStatePublisher ...") end
local TrainPublisher = require("ce.hub.data.trains.TrainPublisher")

local TrainStatePublisher = {}
TrainStatePublisher.enabled = true
local initialized = false
TrainStatePublisher.name = "ce.hub.data.trains.TrainStatePublisher"

TrainStatePublisher.options = {
    ceTypes = {
        trains = { ceType = "ce.hub.Train", mode = "selected" }
    },
    fields = {
        route = { collect = true },
        rollingStockCount = { collect = true },
        length = { collect = true },
        line = { collect = true },
        destination = { collect = true },
        direction = { collect = true },
        trackType = { collect = true },
        movesForward = { collect = true },
        speed = { collect = true },
        targetSpeed = { collect = true },
        couplingFront = { collect = true },
        couplingRear = { collect = true },
        active = { collect = true },
        inTrainyard = { collect = true },
        trainyardId = { collect = true }
    }
}

function TrainStatePublisher.initialize()
    if not TrainStatePublisher.enabled or initialized then return end
    initialized = true
end

function TrainStatePublisher.syncState()
    if not TrainStatePublisher.enabled then return end
    if not initialized then TrainStatePublisher.initialize() end

    return TrainPublisher.syncState(TrainStatePublisher.options)
end

return TrainStatePublisher
