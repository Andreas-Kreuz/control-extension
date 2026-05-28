if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.TrafficLightModelPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local TrafficLightModelDtoFactory = require("ce.mods.road.data.TrafficLightModelDtoFactory")

local TrafficLightModelPublisher = {}

function TrafficLightModelPublisher.syncState()
    DataChangeBus.fireListChange(TrafficLightModelDtoFactory.createTrafficLightModelDtoListFromModels())
end

return TrafficLightModelPublisher