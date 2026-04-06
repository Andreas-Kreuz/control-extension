if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.RollingStockStatePublisher ...") end
local TrainDetection = require("ce.hub.data.trains.TrainDetection")
local RollingStockInfoUpdater = require("ce.hub.data.rollingstock.RollingStockInfoUpdater")
local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")

local RollingStockStatePublisher = {}
RollingStockStatePublisher.enabled = true
local initialized = false
RollingStockStatePublisher.name = "ce.hub.data.trains.RollingStockStatePublisher"

RollingStockStatePublisher.options = {
    ceTypes = {
        rollingStock = { ceType = "ce.hub.RollingStock", mode = "selected" }
    },
    fields = {
        trainName = { collect = true },
        positionInTrain = { collect = true },
        couplingFront = { collect = true },
        couplingRear = { collect = true },
        length = { collect = true },
        propelled = { collect = true },
        modelType = { collect = true },
        modelTypeText = { collect = true },
        tag = { collect = true },
        nr = { collect = true },
        trackType = { collect = true },
        hookStatus = { collect = true },
        hookGlueMode = { collect = true },
        surfaceTexts = { collect = true },
        trackId = { collect = true },
        trackDistance = { collect = true },
        trackDirection = { collect = true },
        trackSystem = { collect = true },
        posX = { collect = true },
        posY = { collect = true },
        posZ = { collect = true },
        mileage = { collect = true },
        orientationForward = { collect = true },
        smoke = { collect = true },
        active = { collect = true },
        rotX = { collect = true },
        rotY = { collect = true },
        rotZ = { collect = true }
    }
}

function RollingStockStatePublisher.initialize()
    if not RollingStockStatePublisher.enabled or initialized then return end
    initialized = true
end

function RollingStockStatePublisher.syncState()
    if not RollingStockStatePublisher.enabled then return end
    if not initialized then RollingStockStatePublisher.initialize() end

    local snapshot = TrainDetection.getCurrentSnapshot()
    if not snapshot then return {} end

    RollingStockInfoUpdater.refresh(snapshot.allKnownTrains, RollingStockStatePublisher.options.fields,
                                    snapshot.selectedCeTypes)
    RollingStockRegistry.fireChangeRollingStockEvents(RollingStockStatePublisher.options.ceTypes,
                                                      RollingStockStatePublisher.options.fields)
    return {}
end

return RollingStockStatePublisher
