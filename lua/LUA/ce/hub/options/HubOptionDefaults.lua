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
                    waitingVehiclesCount = "oninterest",
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
                fieldPublish = {
                    waitingPosition = "oninterest",
                    vehicleName = "oninterest",
                    waitingCount = "oninterest"
                }
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
                    tag = "oninterest",
                    light = "oninterest",
                    smoke = "oninterest",
                    fire = "oninterest",
                    pos_x = "oninterest",
                    pos_y = "oninterest",
                    pos_z = "oninterest",
                    rot_x = "oninterest",
                    rot_y = "oninterest",
                    rot_z = "oninterest"
                },
                fieldPublish = {
                    tag = "always",
                    light = "always",
                    smoke = "always",
                    fire = "always",
                    gsbname = "always"
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
            routes = {
                ceType = HubCeTypes.Route,
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
            contacts = {
                ceType = HubCeTypes.Contact,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {},
                fieldPublish = {
                    luaFn = "always",
                    tipTxt = "oninterest"
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
                    targetSpeed = "oninterest",
                    couplingFront = "oninterest",
                    couplingRear = "oninterest",
                    lights = "oninterest",
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
                    speed = "oninterest",
                    targetSpeed = "oninterest",
                    couplingFront = "oninterest",
                    couplingRear = "oninterest",
                    lights = "oninterest",
                    active = "oninterest",
                    inTrainyard = "oninterest",
                    trainyardId = "oninterest"
                }
            },
            rollingStocks = {
                ceType = HubCeTypes.RollingStock,
                discoveryAndUpdate = true,
                publish = true,
                fieldUpdates = {
                    trainName = "always",
                    positionInTrain = "always",
                    couplingFront = "oninterest",
                    couplingRear = "oninterest",
                    length = "oninterest",
                    propelled = "oninterest",
                    modelType = "oninterest",
                    modelTypeText = "oninterest",
                    tag = "oninterest",
                    nr = "oninterest",
                    trackType = "always",
                    hookStatus = "oninterest",
                    hookGlueMode = "oninterest",
                    axisValues = "oninterest",
                    surfaceTexts = "oninterest",
                    trackId = "oninterest",
                    trackDistance = "oninterest",
                    trackDirection = "oninterest",
                    trackSystem = "oninterest",
                    posX = "oninterest",
                    posY = "oninterest",
                    posZ = "oninterest",
                    mileage = "oninterest",
                    orientationForward = "oninterest",
                    smoke = "oninterest",
                    active = "always",
                    axisNamesKnown = "always",
                    rotX = "oninterest",
                    rotY = "oninterest",
                    rotZ = "oninterest"
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
                    axisNames = "always",
                    axisValues = "always",
                    surfaceTexts = "always",
                    textureNames = "always",
                    trackId = "oninterest",
                    trackDistance = "oninterest",
                    trackDirection = "oninterest",
                    trackSystem = "oninterest",
                    posX = "oninterest",
                    posY = "oninterest",
                    posZ = "oninterest",
                    mileage = "oninterest",
                    orientationForward = "oninterest",
                    smoke = "oninterest",
                    active = "oninterest",
                    axisNamesKnown = "always",
                    rotX = "oninterest",
                    rotY = "oninterest",
                    rotZ = "oninterest",
                    xmlModel = "always"
                }
            }
        }
    }
end

return HubOptionDefaults
