if CeDebugLoad then print("[#Start] Loading ce.mods.road.options.RoadOptionDefaults ...") end

local RoadCeTypes = require("ce.mods.road.data.RoadCeTypes")

local RoadOptionDefaults = {}

-- NOTE: data collection cannot be disabled per ceType — the entire module is skipped on loading.
-- Only publish and field-level policies (always / oninterest / never) are configurable here.
function RoadOptionDefaults.create()
    return {
        ceTypes = {
            intersections = {
                ceType = RoadCeTypes.Intersection,
                publish = true,
                fieldUpdates = {
                    name = "always",
                    manualPhase = "always",
                    currentPhase = "always",
                    nextPhase = "always",
                    phases = "always",
                    ready = "always",
                    staticCams = "always",
                    greenTimeSeconds = "always"
                },
                fieldPublish = {
                    name = "always",
                    manualPhase = "oninterest",
                    currentPhase = "oninterest",
                    nextPhase = "oninterest",
                    phases = "always",
                    ready = "oninterest",
                    staticCams = "always",
                    greenTimeSeconds = "always"
                }
            },
            intersectionLanes = {
                ceType = RoadCeTypes.IntersectionLane,
                publish = true,
                fieldUpdates = {
                    countType = "always",
                    directions = "always",
                    eepSaveId = "always",
                    intersectionId = "always",
                    name = "always",
                    currentIndication = "always",
                    phases = "always",
                    tracks = "always",
                    type = "always",
                    vehicleMultiplier = "always",
                    waitingForGreenCyclesCount = "always",
                    waitingTrains = "always"
                },
                fieldPublish = {
                    name = "always",
                    countType = "always",
                    directions = "always",
                    eepSaveId = "always",
                    intersectionId = "always",
                    phases = "always",
                    tracks = "always",
                    type = "always",
                    vehicleMultiplier = "always",
                    currentIndication = "oninterest",
                    waitingForGreenCyclesCount = "oninterest",
                    waitingTrains = "oninterest"
                }
            },
            intersectionPhases = {
                ceType = RoadCeTypes.IntersectionPhase,
                publish = true,
                fieldUpdates = {
                    intersectionId = "always",
                    name = "always",
                    prio = "always"
                },
                fieldPublish = {
                    intersectionId = "always",
                    name = "always",
                    prio = "always"
                }
            },
            intersectionTrafficLights = {
                ceType = RoadCeTypes.IntersectionTrafficLight,
                publish = true,
                fieldUpdates = {
                    axisStructures = "always",
                    currentIndication = "always",
                    intersectionId = "always",
                    lightStructures = "always",
                    modelId = "always",
                    pedestrianSignalName = "always",
                    signalId = "always",
                    vehicleSignalName = "always",
                    use = "always"
                },
                fieldPublish = {
                    axisStructures = "always",
                    intersectionId = "always",
                    lightStructures = "always",
                    modelId = "always",
                    pedestrianSignalName = "always",
                    signalId = "always",
                    vehicleSignalName = "always",
                    use = "always",
                    currentIndication = "oninterest"
                }
            },
            moduleSettings = {
                ceType = RoadCeTypes.ModuleSetting,
                publish = true,
                fieldUpdates = {
                    category = "always",
                    description = "always",
                    eepFunction = "always",
                    type = "always",
                    value = "always"
                },
                fieldPublish = {
                    category = "always",
                    description = "always",
                    eepFunction = "always",
                    type = "always",
                    value = "always"
                }
            }
        }
    }
end

return RoadOptionDefaults
