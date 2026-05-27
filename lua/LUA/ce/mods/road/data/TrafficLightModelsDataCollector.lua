if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.TrafficLightModelsDataCollector ...") end
local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

local TrafficLightModelsDataCollector = {}

function TrafficLightModelsDataCollector.collectTrafficLightModels()
    local trafficLightModels = {}
    for _, model in ipairs(TrafficLightModel.getAllOrdered()) do
        table.insert(trafficLightModels, {
            id = model.id,
            name = model.name,
            type = "road",
            modelNamePatterns = model.modelNamePatterns or {},
            modelNameMatchOrder = model.modelNameMatchOrder,
            positions = {
                positionRed = model.signalIndexRed,
                positionGreen = model.signalIndexGreen,
                positionYellow = model.signalIndexYellow,
                positionRedYellow = model.signalIndexRedYellow,
                positionPedestrians = model.signalIndexPedestrian,
                positionOff = model.signalIndexSwitchOff,
                positionOffBlinking = model.signalIndexBlinkYellow
            }
        })
    end
    return trafficLightModels
end

return TrafficLightModelsDataCollector
