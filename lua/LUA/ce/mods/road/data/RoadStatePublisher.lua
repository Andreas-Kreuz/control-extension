if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadStatePublisher ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local Intersection = require("ce.mods.road.Intersection")
local RoadDataCollector = require("ce.mods.road.data.RoadDataCollector")
local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")
local RoadOptionsRegistry = require("ce.mods.road.options.RoadOptionsRegistry")

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

    if RoadOptionsRegistry.isPublishEnabled("intersections") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionDtoList(crossingData.intersections))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionLanes") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionLaneDtoList(crossingData.intersectionLanes))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionSwitchings") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionSwitchingDtoList(crossingData.intersectionSwitchings))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionTrafficLights") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionTrafficLightDtoList(crossingData.intersectionTrafficLights))
    end
    if RoadOptionsRegistry.isPublishEnabled("moduleSettings") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionModuleSettingDtoList(moduleSettings))
    end

    return {}
end

return RoadStatePublisher
