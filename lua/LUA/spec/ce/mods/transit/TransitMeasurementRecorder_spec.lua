insulate("TransitMeasurementRecorder", function ()
    local EepSimulator = require("ce.hub.eep.EepSimulator")
    local Line = require("ce.mods.transit.Line")
    local RoadStation = require("ce.mods.transit.RoadStation")
    local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
    local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")
    local TransitMeasurementRecorder = require("ce.mods.transit.measurement.TransitMeasurementRecorder")

    local originalPrint = _G.print
    local printedLines = {}
    local trainCounter = 0

    local function setTime(seconds)
        rawset(_G, "EEPTime", seconds)
    end

    local function capturePrint()
        printedLines = {}
        _G.print = function (message) table.insert(printedLines, message) end
    end

    local function restorePrint()
        _G.print = originalPrint
    end

    local function createMeasuredLine(name)
        local stationA = RoadStation:new(name .. " A", -1)
        local stationB = RoadStation:new(name .. " B", -1)
        local stationC = RoadStation:new(name .. " C", -1)

        local line = Line.forName(name)
        local outbound = line:addSection(name .. " Outbound", "C")
        outbound:addStop(stationA:platform(1), 0)
        outbound:addStop(stationB:platform(1), 1)
        outbound:addStop(stationC:platform(1), 2)

        return stationA, stationB, stationC, outbound
    end

    local function createMeasuredLineWithFourStations(name)
        local stationA = RoadStation:new(name .. " A", -1)
        local stationB = RoadStation:new(name .. " B", -1)
        local stationC = RoadStation:new(name .. " C", -1)
        local stationD = RoadStation:new(name .. " D", -1)

        local line = Line.forName(name)
        local outbound = line:addSection(name .. " Outbound", "D")
        outbound:addStop(stationA:platform(1), 0)
        outbound:addStop(stationB:platform(1), 1)
        outbound:addStop(stationC:platform(1), 2)
        outbound:addStop(stationD:platform(1), 3)

        return stationA, stationB, stationC, stationD, outbound
    end

    local function createTrain(route, measured)
        trainCounter = trainCounter + 1
        local trainName = "#Measurement Train " .. tostring(trainCounter)
        local rollingStockName = "Measurement RS " .. tostring(trainCounter)
        EepSimulator.simulateAddTrain(trainName, rollingStockName)
        if measured then EEPRollingstockSetTagText(rollingStockName, "v=1,") end

        local train = TrainRegistry.getOrCreate(trainName)
        local transitTrain = TransitTrainRegistry.forTrain(train)
        train:setRoute(route.routeName)
        transitTrain:changeDestination(route.destination, route.line.nr)
        printedLines = {}
        return trainName
    end

    before_each(function ()
        TransitMeasurementRecorder.reset()
        setTime(0)
        capturePrint()
    end)

    after_each(function ()
        restorePrint()
    end)

    it("prints travel and stop times in the station table", function ()
        local stationA, stationB, stationC, outbound = createMeasuredLine("MeasurementNormal")
        local trainName = createTrain(outbound, true)

        setTime(0)
        Line.trainDeparted(trainName, stationA)
        setTime(200)
        Line.trainArrived(trainName, stationB)
        setTime(250)
        Line.trainDeparted(trainName, stationB)
        setTime(405)
        Line.trainArrived(trainName, stationC)

        assert.are.equal(
            "Messfahrt Linie MeasurementNormal nach C\n" ..
            "Gesamtfahrzeit: 06:45 min\n" ..
            "| Abfahrten Soll / Ist | Fahrzeit | Standzeit | Haltestelle |\n" ..
            "| 00:00 min, 00:00 min | --:-- min | --:-- min | MeasurementNormal A |\n" ..
            "| 01:00 min, 04:10 min | 03:20 min | 00:50 min | MeasurementNormal B (von MeasurementNormal A) |\n" ..
            "| 02:00 min, 02:35 min | 02:35 min | --:-- min | MeasurementNormal C (von MeasurementNormal B) |",
            printedLines[1]
        )
    end)

    it("warns when a station is departed without a preceding arrival", function ()
        local stationA, stationB, stationC, outbound = createMeasuredLine("MeasurementMissingArrival")
        local trainName = createTrain(outbound, true)

        setTime(0)
        Line.trainDeparted(trainName, stationA)
        setTime(250)
        Line.trainDeparted(trainName, stationB)
        setTime(405)
        Line.trainArrived(trainName, stationC)

        assert.are.equal(
            "Messfahrt Linie MeasurementMissingArrival nach C\n" ..
            "Gesamtfahrzeit: 06:45 min\n" ..
            "ACHTUNG: Aufruf von trainDeparted an MeasurementMissingArrival B, ohne dass vorher " ..
            "trainArrived an MeasurementMissingArrival B aufgerufen wurde.\n" ..
            "| Abfahrten Soll / Ist | Fahrzeit | Standzeit | Haltestelle |\n" ..
            "| 00:00 min, 00:00 min | --:-- min | --:-- min | MeasurementMissingArrival A |\n" ..
            "| 01:00 min, 04:10 min | --:-- min | --:-- min | " ..
            "MeasurementMissingArrival B (von MeasurementMissingArrival A) |\n" ..
            "| 02:00 min, 02:35 min | 02:35 min | --:-- min | " ..
            "MeasurementMissingArrival C (von MeasurementMissingArrival B) |",
            printedLines[1]
        )
    end)

    it("warns when the next station is arrived without departing the previous station", function ()
        local stationA, stationB, stationC, outbound = createMeasuredLine("MeasurementMissingDeparture")
        local trainName = createTrain(outbound, true)

        setTime(0)
        Line.trainDeparted(trainName, stationA)
        setTime(180)
        Line.trainArrived(trainName, stationB)
        setTime(360)
        Line.trainArrived(trainName, stationC)

        assert.are.equal(
            "Messfahrt Linie MeasurementMissingDeparture nach C\n" ..
            "Gesamtfahrzeit: 06:00 min\n" ..
            "ACHTUNG: Aufruf von trainArrived an MeasurementMissingDeparture C, ohne dass die vorherige Station " ..
            "MeasurementMissingDeparture B mit trainDeparted verlassen wurde.\n" ..
            "| Abfahrten Soll / Ist | Fahrzeit | Standzeit | Haltestelle |\n" ..
            "| 00:00 min, 00:00 min | --:-- min | --:-- min | MeasurementMissingDeparture A |\n" ..
            "| 01:00 min, --:-- min | 03:00 min | --:-- min | " ..
            "MeasurementMissingDeparture B (von MeasurementMissingDeparture A) |\n" ..
            "| 02:00 min, --:-- min | --:-- min | --:-- min | " ..
            "MeasurementMissingDeparture C (von MeasurementMissingDeparture B) |",
            printedLines[1]
        )
    end)

    it("warns when a planned station is skipped", function ()
        local stationA, _, stationC, outbound = createMeasuredLine("MeasurementSkipped")
        local trainName = createTrain(outbound, true)

        setTime(0)
        Line.trainDeparted(trainName, stationA)
        setTime(340)
        Line.trainArrived(trainName, stationC)

        assert.are.equal(
            "Messfahrt Linie MeasurementSkipped nach C\n" ..
            "Gesamtfahrzeit: 05:40 min\n" ..
            "ACHTUNG: Zwischen MeasurementSkipped A und MeasurementSkipped C wurden Stationen " ..
            string.char(252) .. "bersprungen: " ..
            "MeasurementSkipped B.\n" ..
            "| Abfahrten Soll / Ist | Fahrzeit | Standzeit | Haltestelle |\n" ..
            "| 00:00 min, 00:00 min | --:-- min | --:-- min | MeasurementSkipped A |\n" ..
            "| 03:00 min, 05:40 min | 05:40 min | --:-- min | MeasurementSkipped C (von MeasurementSkipped A) |",
            printedLines[1]
        )
    end)

    it("warns with all skipped stations in route order", function ()
        local stationA, _, _, stationD, outbound = createMeasuredLineWithFourStations("MeasurementMultiSkipped")
        local trainName = createTrain(outbound, true)

        setTime(0)
        Line.trainDeparted(trainName, stationA)
        setTime(420)
        Line.trainArrived(trainName, stationD)

        assert.is_truthy(string.find(
            printedLines[1],
            "Stationen " .. string.char(252) .. "bersprungen: MeasurementMultiSkipped B, MeasurementMultiSkipped C.",
            1,
            true
        ))
        assert.is_truthy(string.find(printedLines[1], "Gesamtfahrzeit: 07:00 min", 1, true))
        assert.is_truthy(string.find(printedLines[1], "| 06:00 min, 07:00 min | 07:00 min |", 1, true))
    end)

    it("does not report the previous station itself as skipped when it appears again in the route", function ()
        local stationA = RoadStation:new("MeasurementRepeatedStart A", -1)
        local stationB = RoadStation:new("MeasurementRepeatedStart B", -1)
        local stationC = RoadStation:new("MeasurementRepeatedStart C", -1)
        local line = Line.forName("MeasurementRepeatedStart")
        local outbound = line:addSection("MeasurementRepeatedStart Outbound", "C")
        outbound:addStop(stationA:platform(1), 0)
        outbound:addStop(stationB:platform(1), 1)
        outbound:addStop(stationA:platform(2), 2)
        outbound:addStop(stationC:platform(1), 3)
        local trainName = createTrain(outbound, true)

        setTime(0)
        Line.trainDeparted(trainName, stationA)
        setTime(420)
        Line.trainArrived(trainName, stationC)

        assert.is_truthy(string.find(
            printedLines[1],
            "Stationen " .. string.char(252) .. "bersprungen: MeasurementRepeatedStart B.",
            1,
            true
        ))
        assert.is_falsy(string.find(
            printedLines[1],
            "Stationen " .. string.char(252) .. "bersprungen: MeasurementRepeatedStart B, MeasurementRepeatedStart A.",
            1,
            true
        ))
        assert.is_truthy(string.find(printedLines[1], "Gesamtfahrzeit: 07:00 min", 1, true))
    end)
    it("prints only once when the end station departure comes before its arrival", function ()
        local stationA, stationB, stationC, outbound = createMeasuredLine("MeasurementEndDepartureFirst")
        local trainName = createTrain(outbound, true)

        setTime(0)
        Line.trainDeparted(trainName, stationA)
        setTime(200)
        Line.trainArrived(trainName, stationB)
        setTime(250)
        Line.trainDeparted(trainName, stationB)
        setTime(405)
        Line.trainDeparted(trainName, stationC)
        setTime(430)
        Line.trainArrived(trainName, stationC)

        assert.are.equal(1, #printedLines)
        assert.is_truthy(string.find(printedLines[1], "Gesamtfahrzeit: 06:45 min", 1, true))
        assert.is_truthy(string.find(
            printedLines[1],
            "ACHTUNG: Aufruf von trainDeparted an MeasurementEndDepartureFirst C",
            1,
            true
        ))
    end)

    it("keeps measurements for multiple marked trains separate", function ()
        local stationA1, stationB1, stationC1, outbound1 = createMeasuredLine("MeasurementTrainOne")
        local stationA2, stationB2, stationC2, outbound2 = createMeasuredLine("MeasurementTrainTwo")
        local trainName1 = createTrain(outbound1, true)
        local trainName2 = createTrain(outbound2, true)

        setTime(0)
        Line.trainDeparted(trainName1, stationA1)
        setTime(30)
        Line.trainDeparted(trainName2, stationA2)
        setTime(60)
        Line.trainArrived(trainName1, stationB1)
        setTime(90)
        Line.trainArrived(trainName2, stationB2)
        setTime(120)
        Line.trainDeparted(trainName1, stationB1)
        setTime(150)
        Line.trainDeparted(trainName2, stationB2)
        setTime(240)
        Line.trainArrived(trainName1, stationC1)
        setTime(270)
        Line.trainArrived(trainName2, stationC2)

        assert.are.equal(2, #printedLines)
        assert.is_truthy(string.find(printedLines[1], "Messfahrt Linie MeasurementTrainOne nach C", 1, true))
        assert.is_truthy(string.find(printedLines[2], "Messfahrt Linie MeasurementTrainTwo nach C", 1, true))
    end)

    it("does not print measurements for unmarked trains", function ()
        local stationA, stationB, stationC, outbound = createMeasuredLine("MeasurementUnmarked")
        local trainName = createTrain(outbound, false)

        setTime(0)
        Line.trainDeparted(trainName, stationA)
        setTime(60)
        Line.trainArrived(trainName, stationB)
        setTime(180)
        Line.trainArrived(trainName, stationC)

        assert.are.equal(0, #printedLines)
    end)

    it("uses cached train values to detect measurement trains", function ()
        local stationA, _, _, outbound = createMeasuredLine("MeasurementCachedFlag")
        local trainName = createTrain(outbound, true)
        local StorageUtility = require("ce.hub.util.StorageUtility")
        local originalLoadTableRollingStock = StorageUtility.loadTableRollingStock
        StorageUtility.loadTableRollingStock = function ()
            error("TransitMeasurementRecorder must not reload rolling stock tags")
        end

        local ok, err = pcall(function ()
            Line.trainDeparted(trainName, stationA)
        end)
        StorageUtility.loadTableRollingStock = originalLoadTableRollingStock

        assert.is_true(ok, err)
    end)

    it("keeps elapsed times positive across midnight", function ()
        local stationA, _, stationC, outbound = createMeasuredLine("MeasurementMidnight")
        local trainName = createTrain(outbound, true)

        setTime(86340)
        Line.trainDeparted(trainName, stationA)
        setTime(60)
        Line.trainArrived(trainName, stationC)

        assert.are.equal(1, #printedLines)
        assert.is_truthy(string.find(printedLines[1], "Gesamtfahrzeit: 02:00 min", 1, true))
    end)
end)
