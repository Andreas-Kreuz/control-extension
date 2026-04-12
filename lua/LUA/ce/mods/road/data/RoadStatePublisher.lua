if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadStatePublisher ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
local Intersection = require("ce.mods.road.Intersection")
local RoadCeTypes = require("ce.mods.road.data.RoadCeTypes")
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
    local function byCeTypeAndId(ceType, id) return DynamicUpdateRegistry.isSelected(ceType, tostring(id)) end

    if RoadOptionsRegistry.isPublishEnabled("intersections") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionDtoList(crossingData.intersections,
                                                                             function (intersection)
            return byCeTypeAndId(RoadCeTypes.Intersection, intersection.id)
        end))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionLanes") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionLaneDtoList(crossingData.intersectionLanes,
                                                                                 function (lane)
            return byCeTypeAndId(RoadCeTypes.IntersectionLane, lane.id)
        end))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionSwitchings") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionSwitchingDtoList(crossingData
        .intersectionSwitchings, function (switching)
            return byCeTypeAndId(RoadCeTypes.IntersectionSwitching, switching.id)
        end))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionTrafficLights") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionTrafficLightDtoList(crossingData
        .intersectionTrafficLights, function (trafficLight)
            return byCeTypeAndId(RoadCeTypes.IntersectionTrafficLight, trafficLight.id)
        end))
    end
    if RoadOptionsRegistry.isPublishEnabled("moduleSettings") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionModuleSettingDtoList(moduleSettings,
                                                                                          function (setting)
            return byCeTypeAndId(RoadCeTypes.ModuleSetting, setting.name)
        end))
    end

    return {}
end

return RoadStatePublisher
