local LineSegment = require("ce.mods.transit.LineSegment")
local RoadStation = require("ce.mods.transit.RoadStation")
local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")
local TransitMeasurementRecorder = require("ce.mods.transit.measurement.TransitMeasurementRecorder")
if CeDebugLoad then print("[#Start] Loading ce.mods.transit.Line ...") end

local Line = {}
Line.debug = CeDebugLoad or false
---@type table<string, Line>
local lines = {}
---@type table<string, LineSegment>
local lineSegmentsByRouteName = {}

function Line.forName(name)
    local LineRegistry = require("ce.mods.transit.LineRegistry")
    local line, _ = LineRegistry.getOrCreate(name)
    return line
end

function Line:new(o)
    assert(type(o) == "table", "Need 'o' as table")
    assert(type(o.nr) == "string", "Need 'o.nr' as string")
    assert(type(o.trafficType) == "nil" or o.trafficType == "TRAM" or o.trafficType == "BUS",
           "Need 'o.trafficType' as 'BUS' or 'TRAM'")
    o.id = o.nr
    o.type = "Line"
    o.trafficType = o.trafficType or "TRAM"
    o.lineSegments = {}
    self.__index = self
    setmetatable(o, self)
    lines[o.nr] = o
    return o
end

local function createSection(line, routeName, destination)
    assert(type(line) == "table" and line.type == "Line", "Call this method with ':'")
    assert(type(routeName) == "string", "Need 'routeName' as string")
    assert(type(destination) == "string", "Need 'destination' as string")
    local existingSegment = lineSegmentsByRouteName[routeName]
    if existingSegment then
        print(string.format(
            "[#Line] EEP route '%s' is already assigned to line '%s' and destination '%s'",
            routeName,
            existingSegment.line.nr,
            existingSegment.destination
        ))
        return existingSegment
    end

    local lineSegment = LineSegment:new(routeName, line, destination)
    line.lineSegments[routeName] = lineSegment
    lineSegmentsByRouteName[routeName] = lineSegment
    return lineSegment
end

function Line:addSection(routeName, destination)
    return createSection(self, routeName, destination)
end

function Line:createDepotSection(routeName)
    local depotSection = createSection(self, routeName, "")
    depotSection.autoReleaseDepotSignal = false
    return depotSection
end

local function lineSegmentForRouteName(train, routeName, options)
    assert(type(routeName) == "string", "Need 'routeName' as string")
    options = options or {}

    local lineSegment = lineSegmentsByRouteName[routeName]
    if not lineSegment then
        if not options.suppressUnknownRouteLog then
            print(string.format(
                "[#Line] Could not find lineSegment for route: '%s' for train: %s",
                routeName,
                train.name
            ))
        end
        return nil
    end

    if options.requireDepotSignalAutoRelease and not lineSegment.autoReleaseDepotSignal then return nil end

    local transitTrain = TransitTrainRegistry.forTrain(train)
    local display = lineSegment:displayMatches(transitTrain:getLine(), transitTrain:getDestination())
        and {
            line = transitTrain:getLine(),
            destination = transitTrain:getDestination()
        } or lineSegment:chooseDisplay()
    local lineName = display.line
    local destination = display.destination

    if transitTrain:getLine() ~= lineName or transitTrain:getDestination() ~= destination then
        transitTrain:changeDestination(destination, lineName)
    end

    local origin = lineSegment:getFirstStation()
    if origin and transitTrain:getOrigin() ~= origin.name then transitTrain:setOrigin(origin.name) end

    return lineSegment, transitTrain
end

function Line.applyCachedRouteForTrain(train, options)
    assert(type(train) == "table" and train.type == "Train", "Need 'train' as Train")
    return lineSegmentForRouteName(train, train:getRoute(), options)
end

function Line.setTrainSection(trainName, section)
    assert(type(trainName) == "string", "Need 'trainName' as string")
    assert(type(section) == "table" and section.type == "LineSegment", "Need 'section' as LineSegment")

    local train = TrainRegistry.getOrCreate(trainName)
    local transitTrain = TransitTrainRegistry.forTrain(train)
    local display = section:chooseDisplay()

    train:setRoute(section.routeName)
    transitTrain:changeDestination(display.destination, display.line)
    local origin = section:getFirstStation()
    if origin then transitTrain:setOrigin(origin.name) end
    transitTrain:setNextStations({})
end

local function lineSegmentForTrainRoute(train)
    return lineSegmentForRouteName(train, train:getRoute())
end

local function clearTransitDeparturesForTrain(train)
    for _, station in pairs(RoadStation.getAll()) do station:removeTrain(train.name) end

    local transitTrain = TransitTrainRegistry.get(train.name)
    if transitTrain then transitTrain:setNextStations({}) end
end

local function removeTransitInfoForTrain(train)
    clearTransitDeparturesForTrain(train)

    local transitTrain = TransitTrainRegistry.get(train.name)
    if not transitTrain then return end

    transitTrain:clearTransitInfo()
    TransitTrainRegistry.remove(train.name)
end

local function lineSegmentForTrainAtStation(train, station)
    local lineSegment, transitTrain = lineSegmentForTrainRoute(train)
    if not lineSegment then
        removeTransitInfoForTrain(train)
        return nil
    end

    if not lineSegment:hasStation(station) then
        if Line.debug then
            print(string.format(
                "[#Line] Station '%s' is not part of route '%s' for train: %s",
                station.name,
                lineSegment.routeName,
                train.name
            ))
        end
        clearTransitDeparturesForTrain(train)
        return nil
    end

    return lineSegment, transitTrain
end

function Line.scheduleDeparture(trainName, station, timeInMinutes)
    assert(type(trainName) == "string", "Need 'trainName' as string")
    assert(type(station) == "table", "Need 'station' as table")
    assert(station.type == "RoadStation", "Provide 'station' as 'RoadStation'")
    assert(type(timeInMinutes) == "number", "Need 'timeInMinutes' as number")

    local train = TrainRegistry.getOrCreate(trainName)
    local lineSegment = lineSegmentForTrainAtStation(train, station)
    if lineSegment then
        lineSegment:prepareDepartureAt(train, station, timeInMinutes)
        TransitMeasurementRecorder.recordScheduledDeparture(train, lineSegment, station, timeInMinutes)
    end
end

function Line.trainArrived(trainName, station)
    assert(type(trainName) == "string", "Need 'trainName' as string")
    assert(type(station) == "table", "Need 'station' as table")
    assert(station.type == "RoadStation", "Provide 'station' as 'RoadStation'")

    local train = TrainRegistry.getOrCreate(trainName)
    local lineSegment, transitTrain = lineSegmentForTrainAtStation(train, station)
    if lineSegment then
        lineSegment:prepareDepartureAt(train, station, 0)
        TransitMeasurementRecorder.recordTrainArrived(train, lineSegment, station, transitTrain)
    end
end

function Line.trainDeparted(trainName, station)
    assert(type(trainName) == "string", "Need 'trainName' as string")
    assert(type(station) == "table", "Need 'station' as table")
    assert(station.type == "RoadStation", "Provide 'station' as 'RoadStation'")

    local train = TrainRegistry.getOrCreate(trainName)
    local lineSegment, transitTrain = lineSegmentForTrainAtStation(train, station)
    if not lineSegment then return end
    ---@cast transitTrain TransitTrain

    station:trainLeft(trainName, transitTrain:getDestination(), transitTrain:getLine())
    TransitMeasurementRecorder.recordTrainDeparted(train, lineSegment, station, transitTrain)
    lineSegment:trainDeparted(train, station)
end

function Line:toJsonStatic()
    local lineSegments = {}
    for _, segment in pairs(self.lineSegments) do table.insert(lineSegments, segment:toJsonStatic()) end
    return { id = self.id, nr = self.nr, trafficType = self.trafficType, lineSegments = lineSegments }
end

function Line.getLines()
    local ret = {}
    for _, line in pairs(lines) do table.insert(ret, line:toJsonStatic()) end
    return ret
end

return Line
