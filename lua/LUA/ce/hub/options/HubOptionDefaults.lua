if CeDebugLoad then print("[#Start] Loading ce.hub.options.HubOptionDefaults ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")

local HubOptionDefaults = {}

function HubOptionDefaults.create()
    return {
        ceTypes = {
            modules = {
                ceType = HubCeTypes.Module,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {}
            },
            eepVersion = {
                ceType = HubCeTypes.EepVersion,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {}
            },
            runtimes = {
                ceType = HubCeTypes.Runtime,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {}
            },
            frameData = {
                ceType = HubCeTypes.FrameData,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {}
            },
            saveSlots = {
                ceType = HubCeTypes.SaveSlot,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {}
            },
            freeSlots = {
                ceType = HubCeTypes.FreeSlot,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {}
            },
            signals = {
                ceType = HubCeTypes.Signal,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {
                    tag = "always",
                    stopDistance = "always",
                    itemName = "always",
                    functions = "always"
                },
                fieldPublish = {
                    tag = "always",
                    stopDistance = "always",
                    itemName = "always",
                    functions = "always"
                }
            },
            waitingOnSignals = {
                ceType = HubCeTypes.WaitingOnSignal,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {}
            },
            switches = {
                ceType = HubCeTypes.Switch,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {}
            },
            structures = {
                ceType = HubCeTypes.Structure,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {
                    tag = "always",
                    light = "always",
                    smoke = "always",
                    fire = "always"
                },
                fieldPublish = {
                    tag = "always",
                    light = "always",
                    smoke = "always",
                    fire = "always"
                }
            },
            scenario = {
                ceType = HubCeTypes.Scenario,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {}
            },
            time = {
                ceType = HubCeTypes.Time,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {}
            },
            weather = {
                ceType = HubCeTypes.Weather,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {}
            },
            auxiliaryTracks = {
                ceType = HubCeTypes.AuxiliaryTrack,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {
                    reserved = "always",
                    reservedByTrainName = "always"
                }
            },
            controlTracks = {
                ceType = HubCeTypes.ControlTrack,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {
                    reserved = "always",
                    reservedByTrainName = "always"
                }
            },
            roadTracks = {
                ceType = HubCeTypes.RoadTrack,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {
                    reserved = "always",
                    reservedByTrainName = "always"
                }
            },
            railTracks = {
                ceType = HubCeTypes.RailTrack,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {
                    reserved = "always",
                    reservedByTrainName = "always"
                }
            },
            tramTracks = {
                ceType = HubCeTypes.TramTrack,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {
                    reserved = "always",
                    reservedByTrainName = "always"
                }
            },
            trains = {
                ceType = HubCeTypes.Train,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {
                    route = "always",
                    rollingStockCount = "always",
                    length = "always",
                    trackType = "always",
                    movesForward = "always",
                    speed = "always",
                    targetSpeed = "always",
                    couplingFront = "always",
                    couplingRear = "always",
                    active = "always",
                    inTrainyard = "always",
                    trainyardId = "always"
                },
                fieldPublish = {
                    route = "always",
                    rollingStockCount = "always",
                    length = "always",
                    trackType = "always",
                    movesForward = "always",
                    speed = "onselection",
                    targetSpeed = "onselection",
                    couplingFront = "onselection",
                    couplingRear = "onselection",
                    active = "onselection",
                    inTrainyard = "onselection",
                    trainyardId = "onselection"
                }
            },
            rollingStocks = {
                ceType = HubCeTypes.RollingStock,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {
                    trainName = "always",
                    positionInTrain = "always",
                    couplingFront = "always",
                    couplingRear = "always",
                    length = "always",
                    propelled = "always",
                    modelType = "always",
                    modelTypeText = "always",
                    tag = "always",
                    nr = "always",
                    trackType = "always",
                    hookStatus = "always",
                    hookGlueMode = "always",
                    surfaceTexts = "onselection",
                    trackId = "onselection",
                    trackDistance = "onselection",
                    trackDirection = "onselection",
                    trackSystem = "onselection",
                    posX = "onselection",
                    posY = "onselection",
                    posZ = "onselection",
                    mileage = "onselection",
                    orientationForward = "always",
                    smoke = "always",
                    active = "always",
                    rotX = "onselection",
                    rotY = "onselection",
                    rotZ = "onselection"
                },
                fieldPublish = {
                    trainName = "always",
                    positionInTrain = "always",
                    couplingFront = "always",
                    couplingRear = "always",
                    length = "always",
                    propelled = "always",
                    modelType = "always",
                    modelTypeText = "always",
                    tag = "always",
                    nr = "always",
                    trackType = "always",
                    hookStatus = "always",
                    hookGlueMode = "always",
                    surfaceTexts = "always",
                    trackId = "onselection",
                    trackDistance = "onselection",
                    trackDirection = "onselection",
                    trackSystem = "onselection",
                    posX = "onselection",
                    posY = "onselection",
                    posZ = "onselection",
                    mileage = "onselection",
                    orientationForward = "onselection",
                    smoke = "onselection",
                    active = "onselection",
                    rotX = "onselection",
                    rotY = "onselection",
                    rotZ = "onselection"
                }
            }
        }
    }
end

return HubOptionDefaults
