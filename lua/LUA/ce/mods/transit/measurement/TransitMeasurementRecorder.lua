if CeDebugLoad then print("[#Start] Loading ce.mods.transit.measurement.TransitMeasurementRecorder ...") end

local StorageUtility = require("ce.hub.util.StorageUtility")
local TagKeys = require("ce.hub.data.rollingstock.TagKeys")

local TransitMeasurementRecorder = {}

local measurementsByTrainName = {}
local secondsPerDay = 86400

local function currentSeconds()
    return tonumber(EEPTime) or 0
end

local function elapsedSeconds(startSeconds, endSeconds)
    local elapsed = endSeconds - startSeconds
    if elapsed < 0 then elapsed = elapsed + secondsPerDay end
    return elapsed
end

local function formatDuration(seconds)
    if not seconds then return "--:-- min" end
    seconds = math.floor(seconds + 0.5)
    return string.format("%02d:%02d min", math.floor(seconds / 60), seconds % 60)
end

local function lineAndDestination(lineSegment, transitTrain)
    local line = transitTrain and transitTrain:getLine() or lineSegment.line.nr
    local destination = transitTrain and transitTrain:getDestination() or lineSegment.destination
    return line or lineSegment.line.nr, destination or lineSegment.destination
end

local function isMeasurementTrain(train)
    local carCount = EEPGetRollingstockItemsCount(train.name)
    for i = 0, carCount - 1 do
        local rollingStockName = EEPGetRollingstockItemName(train.name, i)
        local values = StorageUtility.loadTableRollingStock(rollingStockName)
        if values[TagKeys.Train.measurement] == "1" then return true end
    end
    return false
end

local function stationLabel(station, previousStation)
    if not previousStation then return station.name end
    return string.format("%s (von %s)", station.name, previousStation.name)
end

local function rowToText(row)
    return string.format(
        "| %s, %s | %s | %s | %s |",
        formatDuration(row.plannedSeconds),
        formatDuration(row.departureActualSeconds),
        formatDuration(row.travelSeconds),
        formatDuration(row.standSeconds),
        stationLabel(row.station, row.previousStation)
    )
end

local function printMeasurement(measurement)
    local lines = { string.format("Messfahrt Linie %s nach %s", measurement.line, measurement.destination) }
    table.insert(lines, string.format("Gesamtfahrzeit: %s", formatDuration(measurement.totalTravelSeconds)))
    for _, warning in ipairs(measurement.warnings) do table.insert(lines, warning) end
    table.insert(lines, "| Abfahrten Soll / Ist | Fahrzeit | Standzeit | Haltestelle |")
    for _, row in ipairs(measurement.rows) do table.insert(lines, rowToText(row)) end
    print(table.concat(lines, "\n"))
end

local function addWarning(measurement, warning)
    table.insert(measurement.warnings, warning)
end

local function warningDepartedWithoutArrival(station)
    return string.format(
        "ACHTUNG: Aufruf von trainDeparted an %s, ohne dass vorher trainArrived an %s aufgerufen wurde.",
        station.name,
        station.name
    )
end

local function warningArrivedWithoutPreviousDeparture(station, previousStation)
    return string.format(
        "ACHTUNG: Aufruf von trainArrived an %s, ohne dass die vorherige Station %s mit trainDeparted verlassen wurde.",
        station.name,
        previousStation.name
    )
end

local function warningSkippedStations(previousStation, station, skippedStations)
    local stationNames = {}
    for _, skippedStation in ipairs(skippedStations) do table.insert(stationNames, skippedStation.name) end
    return string.format(
        "ACHTUNG: Zwischen %s und %s wurden Stationen übersprungen: %s.",
        previousStation.name,
        station.name,
        table.concat(stationNames, ", ")
    )
end

local function addSkippedStationWarning(measurement, lineSegment, station)
    if not measurement.currentStation or measurement.currentStation == station then return end
    local skippedStations = lineSegment:skippedStationsBetween(
        measurement.routeName,
        measurement.currentStation,
        station
    )
    if #skippedStations == 0 then return end
    addWarning(measurement, warningSkippedStations(measurement.currentStation, station, skippedStations))
end

local function addStartRow(measurement, station)
    local row = {
        station = station,
        previousStation = nil,
        plannedSeconds = 0,
        departureActualSeconds = 0,
        travelSeconds = nil,
        standSeconds = nil,
        segmentStartDepartedSeconds = nil
    }
    table.insert(measurement.rows, row)
    measurement.currentRow = row
end

local function newMeasurement(train, lineSegment, station, transitTrain)
    local line, destination = lineAndDestination(lineSegment, transitTrain)
    local measurement = {
        trainName = train.name,
        routeName = train:getRoute(),
        line = line,
        destination = destination,
        rows = {},
        warnings = {},
        currentStation = station,
        currentArrivedSeconds = nil,
        currentDepartedSeconds = nil,
        firstDepartedSeconds = nil,
        totalTravelSeconds = nil,
        currentRow = nil,
        completed = false
    }
    addStartRow(measurement, station)
    return measurement
end

local function nextMeasurementSegment(lineSegment)
    local segmentInfo = lineSegment.nextLineSegmentInfo
    return segmentInfo and segmentInfo.followingSegment or lineSegment
end

local function newMeasurementAfterEndStation(train, lineSegment, station)
    local nextSegment = nextMeasurementSegment(lineSegment)
    local now = currentSeconds()
    local measurement = {
        trainName = train.name,
        routeName = nextSegment.routeName,
        line = nextSegment.line.nr,
        destination = nextSegment.destination,
        rows = {},
        warnings = {},
        currentStation = station,
        currentArrivedSeconds = nil,
        currentDepartedSeconds = now,
        firstDepartedSeconds = now,
        totalTravelSeconds = nil,
        currentRow = nil,
        completed = false
    }
    addStartRow(measurement, station)
    return measurement
end

local function addStationRow(measurement, lineSegment, station, eventSeconds, eventName)
    local plannedMinutes = lineSegment:plannedMinutesBetween(measurement.routeName, measurement.currentStation, station)
    if not plannedMinutes then return false end

    local previousStation = measurement.currentStation
    local segmentStartDepartedSeconds = measurement.currentDepartedSeconds
    local isEndStation = station == lineSegment:getLastStation()
    local travelSeconds = nil
    local departureActualSeconds = nil

    if eventName == "trainArrived" and segmentStartDepartedSeconds then
        travelSeconds = elapsedSeconds(segmentStartDepartedSeconds, eventSeconds)
        if isEndStation then departureActualSeconds = travelSeconds end
    elseif eventName == "trainDeparted" and segmentStartDepartedSeconds then
        departureActualSeconds = elapsedSeconds(segmentStartDepartedSeconds, eventSeconds)
    end

    local row = {
        station = station,
        previousStation = previousStation,
        plannedSeconds = plannedMinutes * 60,
        departureActualSeconds = departureActualSeconds,
        travelSeconds = travelSeconds,
        standSeconds = nil,
        segmentStartDepartedSeconds = segmentStartDepartedSeconds
    }
    table.insert(measurement.rows, row)
    measurement.currentStation = station
    measurement.currentArrivedSeconds = nil
    measurement.currentDepartedSeconds = nil
    measurement.currentRow = row
    return true
end

local function completeAtEndStation(measurement, lineSegment, station)
    if station ~= lineSegment:getLastStation() then return end
    local now = currentSeconds()
    measurement.totalTravelSeconds = elapsedSeconds(measurement.firstDepartedSeconds or now, now)
    measurement.completed = true
    printMeasurement(measurement)
end

local function recordArrival(measurement, lineSegment, station)
    local now = currentSeconds()

    if measurement.currentStation ~= station then
        if not measurement.currentDepartedSeconds then
            addWarning(measurement, warningArrivedWithoutPreviousDeparture(station, measurement.currentStation))
        end
        addSkippedStationWarning(measurement, lineSegment, station)
        if not addStationRow(measurement, lineSegment, station, now, "trainArrived") then return end
    end

    measurement.currentArrivedSeconds = now
    completeAtEndStation(measurement, lineSegment, station)
end

local function recordDeparture(measurement, lineSegment, station)
    local now = currentSeconds()

    if measurement.currentStation ~= station then
        addSkippedStationWarning(measurement, lineSegment, station)
        if not addStationRow(measurement, lineSegment, station, now, "trainDeparted") then return end
    end

    if not measurement.currentArrivedSeconds and not measurement.currentDepartedSeconds then
        addWarning(measurement, warningDepartedWithoutArrival(station))
    end

    if measurement.currentArrivedSeconds then
        measurement.currentRow.standSeconds = elapsedSeconds(measurement.currentArrivedSeconds, now)
    end
    if measurement.currentRow.previousStation and measurement.currentRow.segmentStartDepartedSeconds then
        measurement.currentRow.departureActualSeconds = elapsedSeconds(
            measurement.currentRow.segmentStartDepartedSeconds,
            now
        )
    end
    if not measurement.firstDepartedSeconds then measurement.firstDepartedSeconds = now end
    measurement.currentDepartedSeconds = now
    completeAtEndStation(measurement, lineSegment, station)
end

function TransitMeasurementRecorder.recordTrainArrived(train, lineSegment, station, transitTrain)
    assert(type(train) == "table" and train.type == "Train", "Need 'train' as Train")
    assert(type(lineSegment) == "table" and lineSegment.type == "LineSegment", "Need 'lineSegment' as LineSegment")
    assert(type(station) == "table" and station.type == "RoadStation", "Need 'station' as RoadStation")

    if not isMeasurementTrain(train) then return end

    local measurement = measurementsByTrainName[train.name]
    if measurement and measurement.completed and measurement.currentStation == station then return end
    if not measurement or measurement.completed then
        measurement = newMeasurement(train, lineSegment, station, transitTrain)
        measurementsByTrainName[train.name] = measurement
    end
    recordArrival(measurement, lineSegment, station)
end

function TransitMeasurementRecorder.recordScheduledDeparture(train, lineSegment, station, timeInMinutes)
    assert(type(timeInMinutes) == "number", "Need 'timeInMinutes' as number")
    if timeInMinutes ~= 0 then return end
    TransitMeasurementRecorder.recordTrainArrived(train, lineSegment, station)
end

function TransitMeasurementRecorder.recordTrainDeparted(train, lineSegment, station, transitTrain)
    assert(type(train) == "table" and train.type == "Train", "Need 'train' as Train")
    assert(type(lineSegment) == "table" and lineSegment.type == "LineSegment", "Need 'lineSegment' as LineSegment")
    assert(type(station) == "table" and station.type == "RoadStation", "Need 'station' as RoadStation")

    if not isMeasurementTrain(train) then return end

    local measurement = measurementsByTrainName[train.name]
    if not measurement then
        local now = currentSeconds()
        measurement = newMeasurement(train, lineSegment, station, transitTrain)
        measurement.currentDepartedSeconds = now
        measurement.firstDepartedSeconds = now
        measurementsByTrainName[train.name] = measurement
        return
    end

    if measurement.completed then
        measurementsByTrainName[train.name] = newMeasurementAfterEndStation(train, lineSegment, station)
        return
    end

    recordDeparture(measurement, lineSegment, station)
end

function TransitMeasurementRecorder.reset()
    measurementsByTrainName = {}
end

return TransitMeasurementRecorder
