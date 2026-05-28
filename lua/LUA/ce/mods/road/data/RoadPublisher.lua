if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local Intersection = require("ce.mods.road.Intersection")
local RoadCeTypes = require("ce.mods.road.data.RoadCeTypes")
local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")
local RoadOptionsRegistry = require("ce.mods.road.options.RoadOptionsRegistry")

local RoadPublisher = {}

local function isSelectedIntersection(intersection)
    return InterestSyncRegistry.isSelected(RoadCeTypes.Intersection, tostring(intersection.id))
end

local function isSelectedLane(lane)
    return InterestSyncRegistry.isSelected(RoadCeTypes.IntersectionLane, tostring(lane.id))
end

local function isSelectedPhase(phase)
    return InterestSyncRegistry.isSelected(RoadCeTypes.IntersectionPhase, tostring(phase.id))
end

local function isSelectedSignal(signal)
    return InterestSyncRegistry.isSelected(RoadCeTypes.IntersectionTrafficLight, tostring(signal.id))
end

local function isSelectedModuleSetting(setting)
    return InterestSyncRegistry.isSelected(RoadCeTypes.ModuleSetting, tostring(setting.name))
end

function RoadPublisher.syncState()
    local crossingData = RoadDtoFactory.createCrossingDtos(Intersection.allIntersections)

    if RoadOptionsRegistry.isPublishEnabled("intersections") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionDtoList(crossingData.intersections,
                                                                              isSelectedIntersection))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionLanes") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionLaneDtoList(crossingData.intersectionLanes,
                                                                                  isSelectedLane))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionPhases") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionPhaseDtoList(
            crossingData.intersectionPhases, isSelectedPhase))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionTrafficLights") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionTrafficLightDtoList(
            crossingData.intersectionTrafficLights, isSelectedSignal))
    end
    if RoadOptionsRegistry.isPublishEnabled("moduleSettings") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionModuleSettingDtoList(
            RoadDtoFactory.createModuleSettings(), isSelectedModuleSetting))
    end
end

return RoadPublisher