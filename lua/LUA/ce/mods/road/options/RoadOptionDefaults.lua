if CeDebugLoad then print("[#Start] Loading ce.mods.road.options.RoadOptionDefaults ...") end

local RoadCeTypes = require("ce.mods.road.data.RoadCeTypes")

local RoadOptionDefaults = {}

-- NOTE: data collection cannot be disabled per ceType — the entire module is skipped on loading.
-- Only publish and field-level policies (always / onselection / never) are configurable here.
function RoadOptionDefaults.create()
    return {
        ceTypes = {
            intersections = {
                ceType = RoadCeTypes.Intersection,
                publish = true,
                fieldUpdates = {
                    name = "always",
                    manualSwitching = "always",
                    currentSwitching = "always",
                    nextSwitching = "always",
                    ready = "always",
                    staticCams = "always",
                    timeForGreen = "always"
                },
                fieldPublish = {
                    name = "always",
                    manualSwitching = "always",
                    currentSwitching = "onselection",
                    nextSwitching = "onselection",
                    ready = "onselection",
                    staticCams = "onselection",
                    timeForGreen = "onselection"
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
                    phase = "always",
                    switchings = "always",
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
                    switchings = "always",
                    tracks = "always",
                    type = "always",
                    vehicleMultiplier = "always",
                    phase = "onselection",
                    waitingForGreenCyclesCount = "onselection",
                    waitingTrains = "onselection"
                }
            },
            intersectionSwitchings = {
                ceType = RoadCeTypes.IntersectionSwitching,
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
                    currentPhase = "always",
                    intersectionId = "always",
                    lightStructures = "always",
                    modelId = "always",
                    signalId = "always"
                },
                fieldPublish = {
                    axisStructures = "always",
                    intersectionId = "always",
                    lightStructures = "always",
                    modelId = "always",
                    signalId = "always",
                    currentPhase = "onselection"
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
