if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.TrafficLightModelPublisher ...") end

local IncrementalListPublisher = require("ce.hub.publish.IncrementalListPublisher")
local TrafficLightModelDtoFactory = require("ce.mods.road.data.TrafficLightModelDtoFactory")

local TrafficLightModelPublisher = {}
local listPublisher = IncrementalListPublisher:new()

function TrafficLightModelPublisher.syncState()
    listPublisher:publish(TrafficLightModelDtoFactory.createTrafficLightModelDtoListFromModels())
end

function TrafficLightModelPublisher.requestFullSync()
    listPublisher:requestFullSync(require("ce.mods.road.data.RoadCeTypes").TrafficLightModel)
end

return TrafficLightModelPublisher
