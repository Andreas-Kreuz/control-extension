if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainStatePublisher ...") end
local TrainPublisher = require("ce.hub.data.trains.TrainPublisher")

local TrainStatePublisher = {}
TrainStatePublisher.enabled = true
local initialized = false
TrainStatePublisher.name = "ce.hub.data.trains.TrainStatePublisher"
TrainStatePublisher.ceTypes = require("ce.hub.data.HubCeTypes").Train

function TrainStatePublisher.initialize()
    if not TrainStatePublisher.enabled or initialized then return end
    initialized = true
end

function TrainStatePublisher.syncState()
    if not TrainStatePublisher.enabled then return end
    if not initialized then TrainStatePublisher.initialize() end

    return TrainPublisher.syncState()
end

return TrainStatePublisher
