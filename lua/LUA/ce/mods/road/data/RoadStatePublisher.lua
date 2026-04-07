if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadStatePublisher ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local Intersection = require("ce.mods.road.Intersection")
local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")
local RoadDataCollector = require("ce.mods.road.data.RoadDataCollector")

---@class RoadStatePublisher
RoadStatePublisher = {}
local enabled = true
local initialized = false
RoadStatePublisher.name = "ce.mods.road.data.RoadStatePublisher"

function RoadStatePublisher.initialize()
    if not enabled or initialized then return end
    initialized = true
end

function RoadStatePublisher.syncState()
    if not enabled then return end
    if not initialized then RoadStatePublisher.initialize() end

    local crossingData = RoadDataCollector.collectCrossings(Intersection.allIntersections)
    local moduleSettings = RoadDataCollector.collectModuleSettings()

    DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionDtoList(crossingData.intersections))
    DataChangeBus.fireListChange(
        RoadDtoFactory.createIntersectionLaneDtoList(crossingData.intersectionLanes)
    )
    DataChangeBus.fireListChange(
        RoadDtoFactory.createIntersectionSwitchingDtoList(crossingData.intersectionSwitchings)
    )
    DataChangeBus.fireListChange(
        RoadDtoFactory.createIntersectionTrafficLightDtoList(crossingData.intersectionTrafficLights)
    )
    DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionModuleSettingDtoList(moduleSettings))

    return {}
end

return RoadStatePublisher
