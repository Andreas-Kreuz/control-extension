if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitStatePublisher ...") end
local LineRegistry = require("ce.mods.transit.LineRegistry")
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local TransitDataCollector = require("ce.mods.transit.data.TransitDataCollector")
local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")

---@class TransitStatePublisher
TransitStatePublisher = {}
local enabled = true
local initialized = false
TransitStatePublisher.name = "ce.mods.transit.data.TransitStatePublisher"

function TransitStatePublisher.initialize()
    if not enabled or initialized then return end
    initialized = true
end

function TransitStatePublisher.syncState()
    if not enabled then return end
    if not initialized then TransitStatePublisher.initialize() end

    local data = TransitDataCollector.collectTransitData()

    DataChangeBus.fireListChange(
        TransitDtoFactory.createStationDtoList(data.publicTransportStations)
    )
    DataChangeBus.fireListChange(
        TransitDtoFactory.createLineDtoList(data.publicTransportLines)
    )
    DataChangeBus.fireListChange(
        TransitDtoFactory.createModuleSettingDtoList(data.publicTransportSettings)
    )
    LineRegistry.fireChangeLinesEvent()

    return {}
end

return TransitStatePublisher
