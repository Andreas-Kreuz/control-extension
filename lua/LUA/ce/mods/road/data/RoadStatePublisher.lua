if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadStatePublisher ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
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

local function isSelectedIntersection(intersection)
    return InterestSyncRegistry.isSelected(RoadCeTypes.Intersection, tostring(intersection.id))
end

local function isSelectedLane(lane)
    return InterestSyncRegistry.isSelected(RoadCeTypes.IntersectionLane, tostring(lane.id))
end

local function isSelectedSwitching(switching)
    return InterestSyncRegistry.isSelected(RoadCeTypes.IntersectionSwitching, tostring(switching.id))
end

local function isSelectedTrafficLight(trafficLight)
    return InterestSyncRegistry.isSelected(RoadCeTypes.IntersectionTrafficLight, tostring(trafficLight.id))
end

local function isSelectedModuleSetting(setting)
    return InterestSyncRegistry.isSelected(RoadCeTypes.ModuleSetting, tostring(setting.name))
end

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
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionDtoList(crossingData.intersections,
                                                                              isSelectedIntersection))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionLanes") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionLaneDtoList(crossingData.intersectionLanes,
                                                                                  isSelectedLane))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionSwitchings") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionSwitchingDtoList(
            crossingData.intersectionSwitchings, isSelectedSwitching))
    end
    if RoadOptionsRegistry.isPublishEnabled("intersectionTrafficLights") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionTrafficLightDtoList(
            crossingData.intersectionTrafficLights, isSelectedTrafficLight))
    end
    if RoadOptionsRegistry.isPublishEnabled("moduleSettings") then
        DataChangeBus.fireListChange(RoadDtoFactory.createIntersectionModuleSettingDtoList(moduleSettings,
                                                                                           isSelectedModuleSetting))
    end
end

return RoadStatePublisher
