insulate("Line Management Ring Line", function ()
    local EepSimulator = require("ce.hub.eep.EepSimulator")

    EepSimulator.simulateAddTrain("train1", "RollingStock 1a", "RollingStock 2b")
    EepSimulator.simulateAddTrain("train2", "RollingStock 2a", "RollingStock 2b")
    EepSimulator.simulateAddTrain("train3", "RollingStock 3a", "RollingStock 3b")
    it("EEPLoadData exists", function () assert.is_truthy(_G.EEPLoadData) end)

    local Line = require("ce.mods.transit.Line")
    local RoadStation = require("ce.mods.transit.RoadStation")
    local RSDM = require("ce.mods.transit.models.RoadStationDisplayModel")

    local ringLine = Line.forName("R")
    ---@type LineSegment
    local ringLineSegment = ringLine:addSection("Linie R: Tram Innerer Ring", "Innerer Ring")
    ringLineSegment:addStop(RoadStation.forName("A"):platform(2), 3)
    ringLineSegment:addStop(RoadStation.forName("B"):platform(2), 4)
    ringLineSegment:addStop(RoadStation.forName("C"):platform(2), 5)

    RoadStation.forName("A"):platform(2):addDisplay("#1", RSDM.SimpleStructure)
    RoadStation.forName("B"):platform(2):addDisplay("#2", RSDM.SimpleStructure)
    RoadStation.forName("C"):platform(2):addDisplay("#3", RSDM.SimpleStructure)

    insulate("train1 changes destination correctly", function ()
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")
        local train1 = TrainRegistry.forName("train1")
        local transitTrain1 = TransitTrainRegistry.forTrain(train1)
        train1:setRoute(ringLineSegment.routeName)
        transitTrain1:changeDestination(ringLineSegment.destination, ringLineSegment.line.nr)
        it("train1 has correct initial route",
           function () assert.are.equal(train1.route, "Linie R: Tram Innerer Ring") end)
        it("train1 got initial destination to Messe Dresden",
           function () assert.are.equal("Innerer Ring", transitTrain1:getDestination()) end)

        Line.scheduleDeparture("train1", RoadStation.forName("C"), 4)
        local scheduledNextStations = transitTrain1:getNextStations()
        local scheduledOrigin = transitTrain1:getOrigin()
        it("train1 gets origin from detected line segment", function () assert.are.equal("A", scheduledOrigin) end)
        it("train1 stores scheduled next stations", function ()
            assert.are.equal(3, #scheduledNextStations)
            assert.are.equal("C", scheduledNextStations[1].station.name)
            assert.are.equal("2", scheduledNextStations[1].platform)
            assert.are.equal(4, scheduledNextStations[1].departureInMinutes)
            assert.are.equal("A", scheduledNextStations[2].station.name)
            assert.are.equal(7, scheduledNextStations[2].departureInMinutes)
        end)

        Line.trainDeparted("train1", RoadStation.forName("C"))
        local departedNextStations = transitTrain1:getNextStations()
        it("train1 has correct initial route",
           function () assert.are.equal(train1.route, "Linie R: Tram Innerer Ring") end)
        it("train1 got initial destination to Messe Dresden",
           function () assert.are.equal("Innerer Ring", transitTrain1:getDestination()) end)
        it("train1 stores departed next stations", function ()
            assert.are.equal(3, #departedNextStations)
            assert.are.equal("A", departedNextStations[1].station.name)
            assert.are.equal("2", departedNextStations[1].platform)
            assert.are.equal(3, departedNextStations[1].departureInMinutes)
        end)
    end)

    insulate("LineSegments", function ()
        ---@type { segment: LineSegment, timeInMinutes: number }[]
        local segments = ringLineSegment:getAllSegments()
        it("Got 1 line segments", function () assert.are.equal(1, #segments) end)
        it("1st line ok", function () assert.are.equal(ringLineSegment, segments[1].segment) end)
        it("1st time ok", function () assert.are.equal(2, segments[1].timeInMinutes) end)

        local stations = ringLineSegment:nextStationList(ringLineSegment.routeName, RoadStation.forName("C"))
        it("Got 1 line segments", function () assert.are.equal(3, #stations) end)
        it("1st line ok", function () assert.are.equal("C", stations[1].station.name) end)
        it("1st line ok", function () assert.are.equal("A", stations[2].station.name) end)
        it("1st line ok", function () assert.are.equal("B", stations[3].station.name) end)
        it("1st time ok", function () assert.are.equal(0, stations[1].totalTime) end)
        it("1st time ok", function () assert.are.equal(3, stations[2].totalTime) end)
        it("1st time ok", function () assert.are.equal(7, stations[3].totalTime) end)
    end)
end)

insulate("Line Management 4 Line segments", function ()
    local EepSimulator = require("ce.hub.eep.EepSimulator")

    EepSimulator.simulateAddTrain("train1", "RollingStock 1a", "RollingStock 2b")
    EepSimulator.simulateAddTrain("train2", "RollingStock 2a", "RollingStock 2b")
    EepSimulator.simulateAddTrain("train3", "RollingStock 3a", "RollingStock 3b")
    it("EEPLoadData exists", function () assert.is_truthy(_G.EEPLoadData) end)

    local ControlExtension = require("ce.ControlExtension")
    local CeRoadModule = require("ce.mods.road.CeRoadModule")
    local CeTransitModule = require("ce.mods.transit.CeTransitModule")
    local Line = require("ce.mods.transit.Line")
    local RoadStation = require("ce.mods.transit.RoadStation")
    local RSDM = require("ce.mods.transit.models.RoadStationDisplayModel")

    ControlExtension.addModules(CeRoadModule, CeTransitModule)
    CeRoadModule.loadSettingsFromSlot(1)
    CeTransitModule.loadSettingsFromSlot(2)

    rawset(_G, "EEPMain", function ()
        ControlExtension.runTasks(1)
        return 1
    end)

    local linie10 = Line.forName("10")
    local linie12 = Line.forName("12")

    ---@type LineSegment
    local linie10Messe = linie10:addSection("Linie 10: Tram in Richtung Messe Dresden", "Messe Dresden")
    linie10Messe:addStop(RoadStation.forName("Ludwig-Hartmann-Stra?e"):platform(1), 0)
    linie10Messe:addStop(RoadStation.forName("Stra?buger Platz"):platform(1), 2)
    linie10Messe:addStop(RoadStation.forName("Hauptbahnhof"):platform(1), 2)

    ---@type LineSegment
    local linie10Striesen = linie10:addSection("Linie 10: Tram in Richtung Striesen", "Striesen")
    linie10Striesen:addStop(RoadStation.forName("Messe Dresden"):platform(1), 0)
    linie10Striesen:addStop(RoadStation.forName("Hauptbahnhof"):platform(2), 2)
    linie10Striesen:addStop(RoadStation.forName("Stra?buger Platz"):platform(2), 2)

    ---@type LineSegment
    local linie12Leutewitz = linie12:addSection("Linie 12: Tram in Richtung Leutewitz", "Leutewitz")
    linie12Leutewitz:addStop(RoadStation.forName("Ludwig-Hartmann-Stra?e"):platform(2), 0)
    linie12Leutewitz:addStop(RoadStation.forName("Stra?buger Platz"):platform(1), 2)
    linie12Leutewitz:addStop(RoadStation.forName("Irgendwo"):platform(1), 2)

    ---@type LineSegment
    local linie12Striesen = linie12:addSection("Linie 12: Tram in Richtung Striesen", "Striesen")
    linie12Striesen:addStop(RoadStation.forName("Leutewitz"):platform(2), 2)
    linie12Striesen:addStop(RoadStation.forName("Irgendwo"):platform(2), 2)
    linie12Striesen:addStop(RoadStation.forName("Stra?buger Platz"):platform(2), 2)

    linie10Messe:setNextSection(linie10Striesen, 6)
    linie10Striesen:setNextSection(linie12Leutewitz, 7)
    linie12Leutewitz:setNextSection(linie12Striesen, 8)
    linie12Striesen:setNextSection(linie10Messe, 9)

    RoadStation.forName("Ludwig-Hartmann-Stra?e"):platform(1):addDisplay("#1", RSDM.SimpleStructure)
    RoadStation.forName("Stra?buger Platz"):platform(1):addDisplay("#2", RSDM.SimpleStructure)
    RoadStation.forName("Stra?buger Platz"):platform(2):addDisplay("#3", RSDM.SimpleStructure)
    RoadStation.forName("Hauptbahnhof"):platform(1):addDisplay("#4", RSDM.SimpleStructure)
    RoadStation.forName("Hauptbahnhof"):platform(2):addDisplay("#5", RSDM.SimpleStructure)
    RoadStation.forName("Messe Dresden"):platform(1):addDisplay("#6", RSDM.SimpleStructure)

    insulate("train1", function ()
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")
        local train1 = TrainRegistry.forName("train1")
        local transitTrain1 = TransitTrainRegistry.forTrain(train1)
        train1:setRoute(linie10Messe.routeName)
        transitTrain1:changeDestination(linie10Messe.destination, linie10Messe.line.nr)
        it("initial route",
           function () assert.are.equal("Linie 10: Tram in Richtung Messe Dresden", train1:getRoute()) end)
        it("initial destination", function () assert.are.equal("Messe Dresden", transitTrain1:getDestination()) end)
        it("initial line", function () assert.are.equal("10", transitTrain1:getLine()) end)

        insulate("train1", function ()
            Line.trainDeparted("train1", RoadStation.forName("Hauptbahnhof"))
            local route = train1:getRoute()
            local destination = transitTrain1:getDestination()

            it("changes line to Striesen",
               function () assert.are.equal("Linie 10: Tram in Richtung Striesen", route) end)
            it("changes destination to Striesen", function () assert.are.equal("Striesen", destination) end)
        end)

        insulate("nextStations", function ()
            EepSimulator.simulateAddTrain("train4", "RollingStock 4a", "RollingStock 4b")
            local train4 = TrainRegistry.forName("train4")
            local transitTrain4 = TransitTrainRegistry.forTrain(train4)
            train4:setRoute(linie10Messe.routeName)
            transitTrain4:changeDestination(linie10Messe.destination, linie10Messe.line.nr)
            local LineSegment = require("ce.mods.transit.LineSegment")

            Line.trainDeparted("train4", RoadStation.forName("Stra?buger Platz"))
            local route = train4:getRoute()
            local nextStationsAfterDeparture = transitTrain4:getNextStations()
            it("", function () assert.are.equal("Linie 10: Tram in Richtung Messe Dresden", route) end)
            it("stores up to five next stations after train departure", function ()
                assert.are.equal(5, #nextStationsAfterDeparture)
                assert.are.equal("Hauptbahnhof", nextStationsAfterDeparture[1].station.name)
                assert.are.equal("1", nextStationsAfterDeparture[1].platform)
                assert.are.equal(2, nextStationsAfterDeparture[1].departureInMinutes)
            end)

            Line.trainDeparted("train4", RoadStation.forName("Hauptbahnhof"))
            local route2 = train4:getRoute()
            local origin2 = transitTrain4:getOrigin()
            local queue = RoadStation.forName("Hauptbahnhof").queue
            local queueLength = #queue.entriesByArrival
            local queueText = RoadStation.queueToText(queue)
            it("", function () assert.are.equal("Linie 10: Tram in Richtung Striesen", route2) end)
            it("sets origin after changing to next section", function () assert.are.equal("Messe Dresden", origin2) end)
            it("", function () assert.are.equal(4, queueLength) end)
            it("", function ()
                assert.are.equal(
                    "10&Striesen&train1|10&Striesen&train4|10&Messe Dresden&train1|10&Messe Dresden&train4", queueText)
            end)

            LineSegment.debug = false
            train4:setRoute(linie12Striesen.routeName)
            transitTrain4:changeDestination(linie12Striesen.destination, linie12Striesen.line.nr)
            Line.trainDeparted("train4", RoadStation.forName("Stra?buger Platz"))
            local route5 = train4:getRoute()
            it("", function () assert.are.equal("Linie 10: Tram in Richtung Messe Dresden", route5) end)
        end)
    end)

    insulate("LineSegments", function ()
        ---@type { segment: LineSegment, timeInMinutes: number }[]
        local segments = linie10Messe:getAllSegments()

        it("Got 4 line segments", function () assert.are.equal(4, #segments) end)
        it("1st line ok", function () assert.are.equal(linie10Messe, segments[1].segment) end)
        it("2nd line ok", function () assert.are.equal(linie10Striesen, segments[2].segment) end)
        it("3rd line ok", function () assert.are.equal(linie12Leutewitz, segments[3].segment) end)
        it("4th line ok", function () assert.are.equal(linie12Striesen, segments[4].segment) end)
        it("1st time ok", function () assert.are.equal(9, segments[1].timeInMinutes) end)
        it("2nd time ok", function () assert.are.equal(6, segments[2].timeInMinutes) end)
        it("3rd time ok", function () assert.are.equal(7, segments[3].timeInMinutes) end)
        it("4th time ok", function () assert.are.equal(8, segments[4].timeInMinutes) end)
    end)
end)

insulate("Line route reconciliation", function ()
    local EepSimulator = require("ce.hub.eep.EepSimulator")
    local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
    local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")
    local Line = require("ce.mods.transit.Line")
    local RoadStation = require("ce.mods.transit.RoadStation")

    EepSimulator.simulateAddTrain("#RouteTrain1", "RouteTrain1 RS")
    EepSimulator.simulateAddTrain("#RouteTrain2", "RouteTrain2 RS")
    EepSimulator.simulateAddTrain("#RouteTrain3", "RouteTrain3 RS")
    EepSimulator.simulateAddTrain("#RouteTrain4", "RouteTrain4 RS")

    local sStriesen = RoadStation:new("Route Test Striesen", -1)
    local sMesse = RoadStation:new("Route Test Messe", -1)
    local sRadebeul = RoadStation:new("Route Test Radebeul", -1)

    local line10 = Line.forName("10")
    local l10Striesen = line10:addSection("Route Test Tram 10 Striesen", "Striesen")
    l10Striesen:addStop(sMesse:platform(1), 0)
    l10Striesen:addStop(sStriesen:platform(1), 2)

    local l10Messe = line10:addSection("Route Test Tram 10 Messe Dresden", "Messe Dresden")
    l10Messe:addStop(sStriesen:platform(2), 0)
    l10Messe:addStop(sMesse:platform(2), 2)

    local line4 = Line.forName("4")
    local l04Striesen = line4:addSection("Route Test Tram 04 Striesen", "Striesen")
    l04Striesen:addStop(sRadebeul:platform(1), 0)
    l04Striesen:addStop(sStriesen:platform(3), 2)

    insulate("raw EEP route change before trainDeparted", function ()
        local train = TrainRegistry.forName("#RouteTrain1")
        local transitTrain = TransitTrainRegistry.forTrain(train)
        train:setRoute(l10Messe.routeName)
        transitTrain:changeDestination(l10Messe.destination, l10Messe.line.nr)

        EEPSetTrainRoute("#RouteTrain1", l04Striesen.routeName)
        Line.trainDeparted("#RouteTrain1", sRadebeul)

        it("updates cached train route from EEP", function ()
            assert.equals(l04Striesen.routeName, train:getRoute())
        end)
        it("updates internal line from route mapping", function () assert.equals("4", transitTrain:getLine()) end)
        it("updates destination from route mapping", function ()
            assert.equals("Striesen", transitTrain:getDestination())
        end)
        it("updates origin from route mapping", function ()
            assert.equals("Route Test Radebeul", transitTrain:getOrigin())
        end)
    end)

    insulate("raw EEP route change before scheduleDeparture", function ()
        local train = TrainRegistry.forName("#RouteTrain2")
        local transitTrain = TransitTrainRegistry.forTrain(train)
        train:setRoute(l10Messe.routeName)
        transitTrain:changeDestination(l10Messe.destination, l10Messe.line.nr)

        EEPSetTrainRoute("#RouteTrain2", l04Striesen.routeName)
        Line.scheduleDeparture("#RouteTrain2", sStriesen, 5)

        it("updates cached train route from EEP", function ()
            assert.equals(l04Striesen.routeName, train:getRoute())
        end)
        it("updates internal line from route mapping", function () assert.equals("4", transitTrain:getLine()) end)
        it("updates destination from route mapping", function ()
            assert.equals("Striesen", transitTrain:getDestination())
        end)
    end)

    insulate("same line route change updates destination", function ()
        local train = TrainRegistry.forName("#RouteTrain3")
        local transitTrain = TransitTrainRegistry.forTrain(train)
        train:setRoute(l10Striesen.routeName)
        transitTrain:changeDestination(l10Striesen.destination, l10Striesen.line.nr)

        EEPSetTrainRoute("#RouteTrain3", l10Messe.routeName)
        Line.scheduleDeparture("#RouteTrain3", sMesse, 3)

        it("keeps the line", function () assert.equals("10", transitTrain:getLine()) end)
        it("updates the destination", function () assert.equals("Messe Dresden", transitTrain:getDestination()) end)
    end)

    insulate("unknown EEP route removes transit state", function ()
        local train = TrainRegistry.forName("#RouteTrain4")
        local transitTrain = TransitTrainRegistry.forTrain(train)
        train:setRoute(l10Striesen.routeName)
        transitTrain:changeDestination(l10Striesen.destination, l10Striesen.line.nr)

        EEPSetTrainRoute("#RouteTrain4", "Route Test Unknown Route")
        local ok = pcall(function () Line.scheduleDeparture("#RouteTrain4", sStriesen, 1) end)

        it("does not fail", function () assert.is_true(ok) end)
        it("clears the previous line", function () assert.equals("", transitTrain:getLine()) end)
        it("clears the previous destination", function ()
            assert.equals("", transitTrain:getDestination())
        end)
        it("removes the train from transit trains", function ()
            assert.is_nil(TransitTrainRegistry.find("#RouteTrain4"))
        end)
    end)

    insulate("duplicate EEP routes keep the first mapping", function ()
        local duplicateLine = Line.forName("Duplicate Route Test")
        local duplicateSegment = duplicateLine:addSection(l10Striesen.routeName, "Duplicate")

        it("returns the existing route mapping", function () assert.equals(l10Striesen, duplicateSegment) end)
    end)
end)

insulate("Line contact guards", function ()
    local EepSimulator = require("ce.hub.eep.EepSimulator")
    local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
    local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")
    local Line = require("ce.mods.transit.Line")
    local RoadStation = require("ce.mods.transit.RoadStation")

    EepSimulator.simulateAddTrain("#GuardTrain1", "GuardTrain1 RS")
    EepSimulator.simulateAddTrain("#GuardTrain2", "GuardTrain2 RS")
    EepSimulator.simulateAddTrain("#GuardTrain3", "GuardTrain3 RS")
    EepSimulator.simulateAddTrain("#GuardTrain4", "GuardTrain4 RS")
    EepSimulator.simulateAddTrain("#GuardTrain5", "GuardTrain5 RS")

    local sGuardStart = RoadStation:new("Guard Test Start", -1)
    local sGuardEnd = RoadStation:new("Guard Test End", -1)
    local sGuardOther = RoadStation:new("Guard Test Other", -1)

    local guardLine10 = Line.forName("Guard10")
    local guardOutbound = guardLine10:addSection("Guard Route 10 Outbound", "Guard End")
    guardOutbound:addStop(sGuardStart:platform(1), 0)
    guardOutbound:addStop(sGuardEnd:platform(1), 2)

    local guardInbound = guardLine10:addSection("Guard Route 10 Inbound", "Guard Start")
    guardInbound:addStop(sGuardEnd:platform(2), 0)
    guardInbound:addStop(sGuardStart:platform(2), 2)
    guardOutbound:setNextSection(guardInbound, 2)

    local guardLine20 = Line.forName("Guard20")
    local guardOther = guardLine20:addSection("Guard Route 20 Other", "Guard Other")
    guardOther:addStop(sGuardOther:platform(1), 0)

    local function stationHasTrain(station, trainName)
        for _, entry in pairs(station.queue.entries) do
            if entry.trainName == trainName then return true end
        end
        return false
    end

    local function transitStationsHaveTrain(trainName)
        return stationHasTrain(sGuardStart, trainName)
            or stationHasTrain(sGuardEnd, trainName)
            or stationHasTrain(sGuardOther, trainName)
    end

    insulate("unknown route clears stale departures", function ()
        local train = TrainRegistry.forName("#GuardTrain1")
        local transitTrain = TransitTrainRegistry.forTrain(train)
        train:setRoute(guardOutbound.routeName)
        transitTrain:changeDestination(guardOutbound.destination, guardOutbound.line.nr)
        Line.scheduleDeparture("#GuardTrain1", sGuardEnd, 4)

        EEPSetTrainRoute("#GuardTrain1", "Guard Route Unknown")
        Line.scheduleDeparture("#GuardTrain1", sGuardEnd, 1)

        it("removes stale station departures", function ()
            assert.is_false(transitStationsHaveTrain("#GuardTrain1"))
        end)
        it("clears next stations", function () assert.are.equal(0, #transitTrain:getNextStations()) end)
        it("clears line information", function () assert.equals("", transitTrain:getLine()) end)
        it("removes transit train state", function ()
            assert.is_nil(TransitTrainRegistry.find("#GuardTrain1"))
        end)
    end)

    insulate("unknown route does not create transit train state", function ()
        local train = TrainRegistry.forName("#GuardTrain5")
        train:setRoute("Guard Route Unknown Without Transit Train")

        Line.scheduleDeparture("#GuardTrain5", sGuardEnd, 1)

        it("does not add station departures", function ()
            assert.is_false(transitStationsHaveTrain("#GuardTrain5"))
        end)
        it("does not create a transit train", function ()
            assert.is_nil(TransitTrainRegistry.find("#GuardTrain5"))
        end)
    end)

    insulate("known route on wrong station clears stale departures", function ()
        local train = TrainRegistry.forName("#GuardTrain2")
        local transitTrain = TransitTrainRegistry.forTrain(train)
        train:setRoute(guardOutbound.routeName)
        transitTrain:changeDestination(guardOutbound.destination, guardOutbound.line.nr)
        Line.scheduleDeparture("#GuardTrain2", sGuardEnd, 4)

        EEPSetTrainRoute("#GuardTrain2", guardOther.routeName)
        Line.scheduleDeparture("#GuardTrain2", sGuardStart, 1)

        it("updates the train line from the EEP route", function ()
            assert.equals("Guard20", transitTrain:getLine())
        end)
        it("removes stale station departures", function ()
            assert.is_false(transitStationsHaveTrain("#GuardTrain2"))
        end)
        it("clears next stations", function () assert.are.equal(0, #transitTrain:getNextStations()) end)
    end)

    insulate("known route on matching station updates normally", function ()
        local train = TrainRegistry.forName("#GuardTrain3")
        local transitTrain = TransitTrainRegistry.forTrain(train)
        train:setRoute(guardOutbound.routeName)
        transitTrain:changeDestination(guardOutbound.destination, guardOutbound.line.nr)

        EEPSetTrainRoute("#GuardTrain3", guardOther.routeName)
        Line.scheduleDeparture("#GuardTrain3", sGuardOther, 3)

        it("updates the train line from the EEP route", function ()
            assert.equals("Guard20", transitTrain:getLine())
        end)
        it("adds station departures", function () assert.is_true(stationHasTrain(sGuardOther, "#GuardTrain3")) end)
        it("stores next stations", function () assert.are.equal(1, #transitTrain:getNextStations()) end)
    end)

    insulate("setNextSection at the last station is not cleared", function ()
        local train = TrainRegistry.forName("#GuardTrain4")
        local transitTrain = TransitTrainRegistry.forTrain(train)
        train:setRoute(guardOutbound.routeName)
        transitTrain:changeDestination(guardOutbound.destination, guardOutbound.line.nr)

        Line.trainDeparted("#GuardTrain4", sGuardEnd)

        it("changes to the next section route", function () assert.equals(guardInbound.routeName, train:getRoute()) end)
        it("keeps transit line state", function () assert.equals("Guard10", transitTrain:getLine()) end)
        it("stores next stations", function () assert.is_true(#transitTrain:getNextStations() > 0) end)
    end)
end)

insulate("Line depot display sections", function ()
    local EepSimulator = require("ce.hub.eep.EepSimulator")
    local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
    local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")
    local Line = require("ce.mods.transit.Line")
    local RoadStation = require("ce.mods.transit.RoadStation")

    EepSimulator.simulateAddTrain("#DepotDisplayTrain1", "DepotDisplayTrain1 RS")
    EepSimulator.simulateAddTrain("#DepotDisplayTrain2", "DepotDisplayTrain2 RS")
    EepSimulator.simulateAddTrain("#DepotDisplayTrain3", "DepotDisplayTrain3 RS")
    EepSimulator.simulateAddTrain("#DepotDisplayTrain4", "DepotDisplayTrain4 RS")

    local sDepotDisplayStart = RoadStation:new("Depot Display Start", -1)
    local sDepotDisplayEnd = RoadStation:new("Depot Display End", -1)

    local serviceLine = Line.forName("DepotDisplay10")
    local service = serviceLine:addSection("Depot Display Service Route", "Depot Display End")
    service:addStop(sDepotDisplayStart:platform(1), 0)
    service:addStop(sDepotDisplayEnd:platform(1), 2)

    local depot = Line.forName("zZ"):createDepotSection("Depot Display Route")
        :addDepotDisplay("zZ", "Ich mach Pause")
        :addDepotDisplay("zZ", "Feierabend")
        :addDepotDisplay("zZ", "Schlaft gut")

    service:setNextSection(depot, 2)

    local function startOnService(trainName)
        local train = TrainRegistry.forName(trainName)
        local transitTrain = TransitTrainRegistry.forTrain(train)
        train:setRoute(service.routeName)
        transitTrain:changeDestination(service.destination, service.line.nr)
        return train, transitTrain
    end

    it("returns the depot section from addDepotDisplay for fluent configuration", function ()
        local fluentDepot = Line.forName("zZ"):createDepotSection("Depot Display Fluent Route")

        assert.equals(fluentDepot, fluentDepot:addDepotDisplay("zZ", "Pause"))
    end)

    it("selects configured depot displays with an injected chooser", function ()
        depot:setDepotDisplayChooser(function () return 1 end)
        assert.same({ line = "zZ", destination = "Ich mach Pause" }, depot:chooseDisplay())

        depot:setDepotDisplayChooser(function () return 2 end)
        assert.same({ line = "zZ", destination = "Feierabend" }, depot:chooseDisplay())

        depot:setDepotDisplayChooser(function () return 3 end)
        assert.same({ line = "zZ", destination = "Schlaft gut" }, depot:chooseDisplay())
    end)

    it("uses the depot display line instead of the section line", function ()
        local displayLineDepot = Line.forName("DepotDisplayInternal"):createDepotSection("Depot Display Line Route")
            :addDepotDisplay("zZ", "Ich mach Pause")
        displayLineDepot:setDepotDisplayChooser(function () return 1 end)

        assert.same({ line = "zZ", destination = "Ich mach Pause" }, displayLineDepot:chooseDisplay())
    end)

    it("changes to depot route and selected depot display after the last station", function ()
        depot:setDepotDisplayChooser(function () return 2 end)
        local train, transitTrain = startOnService("#DepotDisplayTrain1")

        Line.trainDeparted("#DepotDisplayTrain1", sDepotDisplayEnd)

        assert.equals(depot.routeName, train:getRoute())
        assert.equals("zZ", transitTrain:getLine())
        assert.equals("Feierabend", transitTrain:getDestination())
        assert.equals(0, #transitTrain:getNextStations())
    end)

    it("keeps an already selected depot display during later route reconciliation", function ()
        depot:setDepotDisplayChooser(function () return 2 end)
        local train, transitTrain = startOnService("#DepotDisplayTrain1")

        Line.trainDeparted("#DepotDisplayTrain1", sDepotDisplayEnd)
        depot:setDepotDisplayChooser(function () return 3 end)
        Line.applyCachedRouteForTrain(train, { suppressUnknownRouteLog = true })

        assert.equals("zZ", transitTrain:getLine())
        assert.equals("Feierabend", transitTrain:getDestination())
    end)

    it("sets a train to a depot section manually", function ()
        depot:setDepotDisplayChooser(function () return 3 end)
        local trainName = "#DepotDisplayTrain1"
        local train, transitTrain = startOnService(trainName)

        Line.scheduleDeparture(trainName, sDepotDisplayEnd, 2)
        Line.setTrainSection(trainName, depot)

        assert.equals(depot.routeName, train:getRoute())
        assert.equals("zZ", transitTrain:getLine())
        assert.equals("Schlaft gut", transitTrain:getDestination())
        assert.equals(0, #transitTrain:getNextStations())
    end)

    it("sets a train to a normal section manually", function ()
        local _, transitTrain = startOnService("#DepotDisplayTrain2")

        Line.setTrainSection("#DepotDisplayTrain2", service)

        assert.equals(service.routeName, TrainRegistry.forName("#DepotDisplayTrain2"):getRoute())
        assert.equals(service.line.nr, transitTrain:getLine())
        assert.equals(service.destination, transitTrain:getDestination())
        assert.equals("Depot Display Start", transitTrain:getOrigin())
        assert.equals(0, #transitTrain:getNextStations())
    end)

    it("accepts each configured depot display during last-station route changes", function ()
        local expectedDestinations = {
            "Ich mach Pause",
            "Feierabend",
            "Schlaft gut"
        }

        for index, destination in ipairs(expectedDestinations) do
            depot:setDepotDisplayChooser(function () return index end)
            local trainName = "#DepotDisplayTrain" .. tostring(index + 1)
            local _, transitTrain = startOnService(trainName)

            Line.trainDeparted(trainName, sDepotDisplayEnd)

            assert.equals("zZ", transitTrain:getLine())
            assert.equals(destination, transitTrain:getDestination())
        end
    end)

    it("falls back to fixed line and destination without depot displays", function ()
        local emptyDepot = Line.forName("DepotFallback"):createDepotSection("Depot Display Empty Route")

        assert.same({ line = "DepotFallback", destination = "" }, emptyDepot:chooseDisplay())
    end)
end)

insulate("Line Management", function ()
    local EepSimulator = require("ce.hub.eep.EepSimulator")
    local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
    local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")
    local Line = require("ce.mods.transit.Line")
    local RoadStation = require("ce.mods.transit.RoadStation")

    local testTrain = "#Train 1"
    EepSimulator.simulateAddTrain(testTrain, "RollingStock 1", "RollingStock 2")

    local sMesseDresden = RoadStation:new("Messe Dresden", -1)
    local sFeuerwehrGasse = RoadStation:new("Feuerwehrgasse", -1)
    local sHauptbahnhof = RoadStation:new("Hauptbahnhof", -1)
    local sStriesen = RoadStation:new("Striesen", -1)

    local line10 = Line.forName("10")
    local l10Striesen = line10:addSection("10 Striesen", "Striesen")
    l10Striesen:addStop(sMesseDresden:platform(1))
    l10Striesen:addStop(sFeuerwehrGasse:platform(1), 2)
    l10Striesen:addStop(sHauptbahnhof:platform(1), 2)
    l10Striesen:addStop(sStriesen:platform(1), 3)

    local l10MesseDresden = line10:addSection("10 Messe Dresden", "Messe Dresden")
    l10MesseDresden:addStop(sStriesen:platform(2), 0)
    l10MesseDresden:addStop(sHauptbahnhof:platform(2), 3)
    l10MesseDresden:addStop(sFeuerwehrGasse:platform(2), 2)
    l10MesseDresden:addStop(sMesseDresden:platform(2))

    it("Station 1", function () assert.equals("Messe Dresden", l10Striesen:getFirstStation().name) end)
    it("Station 4", function () assert.equals("Striesen", l10Striesen:getLastStation().name) end)

    it("", function () assert.equals("2", sHauptbahnhof.routePlatforms["10->Messe Dresden"].platform) end)
    it("", function () assert.equals("1", sHauptbahnhof.routePlatforms["10->Striesen"].platform) end)
    it("", function () assert.equals("2", sFeuerwehrGasse.routePlatforms["10->Messe Dresden"].platform) end)
    it("", function () assert.equals("1", sFeuerwehrGasse.routePlatforms["10->Striesen"].platform) end)

    it("Station 1", function () assert.equals("Striesen", l10MesseDresden:getFirstStation().name) end)
    it("Station 4", function () assert.equals("Messe Dresden", l10MesseDresden:getLastStation().name) end)

    local function stationArrivalPlanned(trainName, station, timeInMinutes)
        assert(type(trainName) == "string", "Need 'trainName' as string")
        assert(type(station) == "table", "Need 'station' as table")
        assert(station.type == "RoadStation", "Provide 'station' as 'RoadStation'")
        assert(type(timeInMinutes) == "number", "Need 'timeInMinutes' as number")

        Line.scheduleDeparture(trainName, station, timeInMinutes)
    end

    local function stationLeft(trainName, station)
        assert(type(trainName) == "string", "Need 'trainName' as string")
        assert(type(station) == "table", "Need 'station' as table")
        assert(station.type == "RoadStation", "Provide 'station' as 'RoadStation'")

        Line.trainDeparted(trainName, station)
    end

    local function changeDestination(trainName, station, departureTime)
        assert(type(trainName) == "string", "Need 'trainName' as string")
        assert(type(station) == "table", "Need 'station' as table")
        assert(station.type == "RoadStation", "Provide 'station' as 'RoadStation'")
        if departureTime then assert(type(departureTime) == "number", "Need 'departureTime' as number") end
    end

    l10Striesen:setNextSection(l10MesseDresden, 2)
    l10MesseDresden:setNextSection(l10Striesen, 2)

    local hubTrain = TrainRegistry.forName(testTrain)
    hubTrain:setRoute(l10MesseDresden.routeName)
    TransitTrainRegistry.forTrain(hubTrain):changeDestination(l10MesseDresden.destination, l10MesseDresden.line.nr)

    changeDestination(testTrain, sMesseDresden)

    stationLeft(testTrain, sMesseDresden)
    stationArrivalPlanned(testTrain, sFeuerwehrGasse, 3)
    stationArrivalPlanned(testTrain, sFeuerwehrGasse, 2)
    stationArrivalPlanned(testTrain, sFeuerwehrGasse, 1)
    stationArrivalPlanned(testTrain, sFeuerwehrGasse, 0)
    stationLeft(testTrain, sFeuerwehrGasse)
    stationArrivalPlanned(testTrain, sHauptbahnhof, 0)
    stationLeft(testTrain, sHauptbahnhof)
    stationArrivalPlanned(testTrain, sStriesen, 0)
    stationLeft(testTrain, sStriesen)

    changeDestination(testTrain, sStriesen)

    stationArrivalPlanned(testTrain, sStriesen, 0)
    stationLeft(testTrain, sStriesen)
    stationArrivalPlanned(testTrain, sHauptbahnhof, 0)
    stationLeft(testTrain, sHauptbahnhof)
    stationArrivalPlanned(testTrain, sFeuerwehrGasse, 3)
    stationArrivalPlanned(testTrain, sFeuerwehrGasse, 2)
    stationArrivalPlanned(testTrain, sFeuerwehrGasse, 1)
    stationArrivalPlanned(testTrain, sFeuerwehrGasse, 0)
    stationLeft(testTrain, sFeuerwehrGasse)
    stationArrivalPlanned(testTrain, sMesseDresden, 0)
    stationLeft(testTrain, sMesseDresden)
end)
