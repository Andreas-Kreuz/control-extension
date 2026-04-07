if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockStatePublisher ...") end
local RollingStockPublisher = require("ce.hub.data.rollingstock.RollingStockPublisher")

local RollingStockStatePublisher = {}
RollingStockStatePublisher.enabled = true
local initialized = false
RollingStockStatePublisher.name = "ce.hub.data.rollingstock.RollingStockStatePublisher"

RollingStockStatePublisher.options = {
    ceTypes = {
        rollingStocks = { ceType = "ce.hub.RollingStock", mode = "selected" }
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

    return RollingStockPublisher.syncState(RollingStockStatePublisher.options)
end

return RollingStockStatePublisher
