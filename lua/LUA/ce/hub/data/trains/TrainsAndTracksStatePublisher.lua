if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainsAndTracksStatePublisher ...") end
local TrainDetection = require("ce.hub.data.trains.TrainDetection")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local HubCeTypes = require("ce.hub.data.HubCeTypes")

TrainsAndTracksStatePublisher = {}

local enabled = true
local initialized = false
TrainsAndTracksStatePublisher.name = "ce.hub.data.trains.TrainsAndTracksStatePublisher"

local data = {}
local selectedCeTypes = {}

local function isSelected(...)
    if next(selectedCeTypes) == nil then return true end
    for i = 1, select("#", ...) do
        if selectedCeTypes[select(i, ...)] then return true end
    end
    return false
end

function TrainsAndTracksStatePublisher.setCollectedCeTypes(collected)
    selectedCeTypes = collected or {}
end

function TrainsAndTracksStatePublisher.initialize()
    if not enabled or initialized then return end
    TrainDetection.initialize(selectedCeTypes)

    initialized = true
end

function TrainsAndTracksStatePublisher.syncState()
    if not enabled then return end

    if not initialized then TrainsAndTracksStatePublisher.initialize() end
    TrainDetection.update(selectedCeTypes)

    if isSelected(HubCeTypes.TrainStatic, HubCeTypes.TrainDynamic) then
        TrainRegistry.fireChangeTrainEvents(selectedCeTypes)
    end
    RollingStockRegistry.fireChangeRollingStockEvents(selectedCeTypes)

    return data
end

return TrainsAndTracksStatePublisher
