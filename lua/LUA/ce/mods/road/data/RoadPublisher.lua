if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadPublisher ...") end

local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local IncrementalListPublisher = require("ce.hub.publish.IncrementalListPublisher")
local Intersection = require("ce.mods.road.Intersection")
local RoadCeTypes = require("ce.mods.road.data.RoadCeTypes")
local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")
local RoadOptionsRegistry = require("ce.mods.road.options.RoadOptionsRegistry")

local RoadPublisher = {}
local listPublisher = IncrementalListPublisher:new()

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
        listPublisher:publish(RoadDtoFactory.createIntersectionDtoList(crossingData.intersections,
                                                                       isSelectedIntersection))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionLanes") then
        listPublisher:publish(RoadDtoFactory.createIntersectionLaneDtoList(crossingData.intersectionLanes,
                                                                           isSelectedLane))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionPhases") then
        listPublisher:publish(RoadDtoFactory.createIntersectionPhaseDtoList(crossingData.intersectionPhases,
                                                                            isSelectedPhase))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionTrafficLights") then
        listPublisher:publish(RoadDtoFactory.createIntersectionTrafficLightDtoList(
            crossingData.intersectionTrafficLights, isSelectedSignal))
    end
    if RoadOptionsRegistry.isPublishEnabled("moduleSettings") then
        listPublisher:publish(RoadDtoFactory.createIntersectionModuleSettingDtoList(
            RoadDtoFactory.createModuleSettings(), isSelectedModuleSetting))
    end
end

function RoadPublisher.requestFullSync()
    listPublisher:requestFullSync(RoadCeTypes.Intersection)
    listPublisher:requestFullSync(RoadCeTypes.IntersectionLane)
    listPublisher:requestFullSync(RoadCeTypes.IntersectionPhase)
    listPublisher:requestFullSync(RoadCeTypes.IntersectionTrafficLight)
    listPublisher:requestFullSync(RoadCeTypes.ModuleSetting)
end

return RoadPublisher
