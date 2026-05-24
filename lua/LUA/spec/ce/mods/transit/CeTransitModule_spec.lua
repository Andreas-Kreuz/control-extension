insulate("ce.mods.transit.CeTransitModule", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.mods.transit.CeTransitModule")
        clearModule("ce.mods.transit.DepotSignalRegistry")
        clearModule("ce.mods.transit.DepotSignalReleaseUpdater")
        clearModule("ce.mods.transit.Line")
        clearModule("ce.mods.transit.LineRegistry")
        clearModule("ce.mods.transit.RoadStation")
        clearModule("ce.mods.transit.data.TransitTrainRegistry")
        clearModule("ce.mods.transit.data.TransitTrainUpdater")
        clearModule("ce.mods.transit.options.TransitOptionsRegistry")
        clearModule("ce.mods.transit.data.TransitDtoFactory")
        clearModule("ce.hub.data.signals.Signal")
        clearModule("ce.hub.data.signals.SignalRegistry")
        clearModule("ce.hub.data.signals.WaitingOnSignal")
        clearModule("ce.hub.data.signals.WaitingOnSignalRegistry")
        clearModule("ce.hub.data.signals.SignalUpdater")
        clearModule("ce.hub.data.trains.TrainRegistry")
        clearModule("ce.hub.data.InterestSyncRegistry")
        clearModule("ce.hub.options.HubOptionsRegistry")
    end)

    local function makeStation(name, queueEntries, routePlatforms)
        return {
            name = name,
            routePlatforms = routePlatforms or {},
            queue = {
                getTrainEntries = function () return queueEntries or {} end
            }
        }
    end

    local function withSignalFunctions(functionsBySignalId, fn)
        local originalGetSignalFunctions = _G.EEPGetSignalFunctions
        local originalGetSignalFunction = _G.EEPGetSignalFunction
        _G.EEPGetSignalFunctions = function (signalId)
            local functions = functionsBySignalId[signalId]
            return functions ~= nil, functions and #functions or 0
        end
        _G.EEPGetSignalFunction = function (signalId, selectionIndex)
            local functions = functionsBySignalId[signalId]
            local signalFunction = functions and functions[selectionIndex] or nil
            return signalFunction ~= nil, signalFunction
        end

        local ok, err = pcall(fn)
        _G.EEPGetSignalFunctions = originalGetSignalFunctions
        _G.EEPGetSignalFunction = originalGetSignalFunction
        if not ok then error(err) end
    end

    it("returns the module from setOptions for chaining", function ()
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        assert.equals(CeTransitModule, CeTransitModule.setOptions({}))
    end)

    it("returns the module from loadSettingsFromSlot for chaining", function ()
        local StorageUtility = require("ce.hub.util.StorageUtility")
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local TransitSettings = require("ce.mods.transit.TransitSettings")

        assert.equals(CeTransitModule, CeTransitModule:loadSettingsFromSlot(25))

        TransitSettings.setShowDepartureTippText(true)

        local data = StorageUtility.loadTable(25, "Transit settings")
        assert.equals("true", data["depInfo"])
    end)

    it("registers depot signals without changing train route polling policy", function ()
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
        local WaitingOnSignalRegistry = require("ce.hub.data.signals.WaitingOnSignalRegistry")

        assert.equals(CeTransitModule, CeTransitModule:registerDepotSignals(701, 702))

        assert.is_true(SignalRegistry.has(701))
        assert.is_true(WaitingOnSignalRegistry.getWatchedSignalIds()[701])
        assert.equals("always", HubOptionsRegistry.getFieldUpdatePolicies("trains").route)
        assert.is_nil(HubOptionsRegistry.getFieldUpdatePolicies("waitingOnSignals").vehicleName)
    end)

    it("selects depot waiting trains for route updates while they wait", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
        local WaitingOnSignalRegistry = require("ce.hub.data.signals.WaitingOnSignalRegistry")

        EepSimulator.simulateQueueTrainOnSignal(705, "#DepotInterestTrain")
        CeTransitModule:registerDepotSignals(705)

        CeTransitModule.run()

        local waiting = WaitingOnSignalRegistry.get("705-1")
        assert.equals("#DepotInterestTrain", waiting.vehicleName)
        assert.is_true(InterestSyncRegistry.isSelected(HubCeTypes.Train, "#DepotInterestTrain"))

        EepSimulator.simulateRemoveAllTrainsFromSignal(705)
        CeTransitModule.run()

        assert.is_nil(WaitingOnSignalRegistry.get("705-1"))
        assert.is_false(InterestSyncRegistry.isSelected(HubCeTypes.Train, "#DepotInterestTrain"))
    end)

    it("does not remove user interest when depot interest ends", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")

        InterestSyncRegistry.startSyncFor(HubCeTypes.Train, "#DepotManualInterestTrain")
        EepSimulator.simulateQueueTrainOnSignal(706, "#DepotManualInterestTrain")
        CeTransitModule:registerDepotSignals(706)

        CeTransitModule.run()
        EepSimulator.simulateRemoveAllTrainsFromSignal(706)
        CeTransitModule.run()

        assert.is_true(InterestSyncRegistry.isSelected(HubCeTypes.Train, "#DepotManualInterestTrain"))
    end)

    it("wraps transit constructors and display model access", function ()
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local displayModel = require("ce.mods.transit.models.RoadStationDisplayModel")

        local station = CeTransitModule:newRoadStation("Sugar Station", -1)
        local stationWithoutSaveSlot = CeTransitModule:newRoadStation("Sugar Station without Save Slot")
        local line = CeTransitModule:newLine({ nr = "Sugar" })

        assert.equals("RoadStation", station.type)
        assert.equals("RoadStation", stationWithoutSaveSlot.type)
        assert.equals(-1, stationWithoutSaveSlot.eepSaveId)
        assert.equals("Line", line.type)
        assert.equals(displayModel, CeTransitModule:getDisplayModel())
    end)

    it("reconciles train line and destination from a known cached hub route", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local Line = require("ce.mods.transit.Line")
        local RoadStation = require("ce.mods.transit.RoadStation")
        local TagKeys = require("ce.hub.data.rollingstock.TagKeys")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")

        EepSimulator.simulateAddTrain("#RouteUpdateTrain", "RouteUpdateTrain RS")
        local startStation = RoadStation:new("Route Update Start", -1)
        local segment = Line.forName("RU"):addSection("Route Update Known", "Route Update Destination")
        segment:addStop(startStation:platform(1), 0)

        local train = TrainRegistry.getOrCreate("#RouteUpdateTrain")
        train:setRoute(segment.routeName)
        train:setValue(TagKeys.Train.line, "Old")
        train:setValue(TagKeys.Train.destination, "Old Destination")

        CeTransitModule.run()

        local transitTrain = TransitTrainRegistry.get("#RouteUpdateTrain")
        assert.equals("RU", transitTrain:getLine())
        assert.equals("Route Update Destination", transitTrain:getDestination())
        assert.equals("RU", train:getValue(TagKeys.Train.line))
        assert.equals("Route Update Destination", train:getValue(TagKeys.Train.destination))
    end)

    it("reconciles transit trains from cached hub values without reloading rolling stock tags", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local TagKeys = require("ce.hub.data.rollingstock.TagKeys")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")

        EepSimulator.simulateAddTrain("#CachedTransitTrain", "CachedTransitTrain RS")
        local train = TrainRegistry.getOrCreate("#CachedTransitTrain")
        train:setValue(TagKeys.Train.line, "42")
        train:setValue(TagKeys.Train.destination, "Cached Destination")
        train:setValue(TagKeys.Train.direction, "North")
        train.load = function () error("TransitTrainUpdater must not reload rolling stock tags") end

        CeTransitModule.run()

        local transitTrain = TransitTrainRegistry.get("#CachedTransitTrain")
        assert.equals("42", transitTrain:getLine())
        assert.equals("Cached Destination", transitTrain:getDestination())
        assert.equals("North", transitTrain:getDirection())
    end)

    it("station DTO: platforms always present, queue absent when not selected (default options)", function ()
        require("ce.mods.transit.CeTransitModule")
        local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")

        local queueEntry = { trainName = "T1", line = "10", destination = "Central", timeInMinutes = 3, platform = "1" }
        local station = makeStation("Station A", { queueEntry }, { Route10 = { platform = 2 } })

        local _, _, _, dto = TransitDtoFactory.createStationDto(station, false)

        assert.same({ { nr = 2, routes = { "Route10" } } }, dto.platforms) -- "always" -> populated
        assert.same({}, dto.queue)                                         -- "oninterest", not selected -> empty
    end)

    it("station DTO: queue present when selected (default options)", function ()
        require("ce.mods.transit.CeTransitModule")
        local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")

        local queueEntry = { trainName = "T1", line = "10", destination = "Central", timeInMinutes = 3, platform = "1" }
        local station = makeStation("Station A", { queueEntry }, {})

        local _, _, _, dto = TransitDtoFactory.createStationDto(station, true)

        -- "oninterest" + selected -> populated
        assert.same({
                        { trainName = "T1", line = "10", destination = "Central", timeInMinutes = 3, platform = "1" }
                    }, dto.queue)
    end)

    it("station DTO: queue present when not selected after setOptions with queue always", function ()
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")

        CeTransitModule.setOptions({
            ceTypes = {
                stations = {
                    fieldPublish = { queue = "always" }
                }
            }
        })

        local queueEntry = { trainName = "T1", line = "10", destination = "Central", timeInMinutes = 3, platform = "1" }
        local station = makeStation("Station A", { queueEntry }, {})

        local _, _, _, dto = TransitDtoFactory.createStationDto(station, false)

        assert.same({
                        { trainName = "T1", line = "10", destination = "Central", timeInMinutes = 3, platform = "1" }
                    }, dto.queue)
    end)

    it("station DTO: platforms absent even when selected after setOptions with platforms never", function ()
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")

        CeTransitModule.setOptions({
            ceTypes = {
                stations = {
                    fieldPublish = { platforms = "never" }
                }
            }
        })

        local station = makeStation("Station A", {}, { Route10 = { platform = 2 } })

        local _, _, _, dto = TransitDtoFactory.createStationDto(station, true)

        assert.same({}, dto.platforms)
    end)

    it("setOptions deep-merges: unspecified ceTypes retain their defaults", function ()
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")

        CeTransitModule.setOptions({
            ceTypes = {
                stations = {
                    fieldPublish = { queue = "always" }
                }
            }
        })

        local line = { id = "10", nr = "10", trafficType = "BUS", lineSegments = {} }
        local _, _, _, dto = TransitDtoFactory.createLineDto(line)

        assert.equals("10", dto.nr)
        assert.equals("BUS", dto.trafficType)
        assert.same({}, dto.lineSegments)
    end)

    it("releases a depot signal when the first waiting train uses a known transit route", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local Line = require("ce.mods.transit.Line")
        local RoadStation = require("ce.mods.transit.RoadStation")
        local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")

        EepSimulator.simulateAddTrain("#DepotKnownTrain", "Depot Known RS")
        local startStation = RoadStation:new("Depot Start", -1)
        local segment = Line.forName("D"):addSection("Depot Route Known", "Depot Destination")
        segment:addStop(startStation:platform(1), 0)
        local train = TrainRegistry.getOrCreate("#DepotKnownTrain")
        train:setRoute(segment.routeName)
        EEPSetSignal(801, 1)
        EepSimulator.simulateQueueTrainOnSignal(801, "#DepotKnownTrain")
        CeTransitModule:registerDepotSignals(801)

        SignalUpdater.runUpdate()
        CeTransitModule.run()

        local transitTrain = TransitTrainRegistry.get("#DepotKnownTrain")
        assert.equals(2, EEPGetSignal(801))
        assert.equals("D", transitTrain:getLine())
        assert.equals("Depot Destination", transitTrain:getDestination())
        assert.equals("Depot Start", transitTrain:getOrigin())
    end)

    it("uses the detected signal function index to release a depot signal", function ()
        withSignalFunctions({ [803] = { 1, 2 } }, function ()
            local EepSimulator = require("ce.hub.eep.EepSimulator")
            local CeTransitModule = require("ce.mods.transit.CeTransitModule")
            local Line = require("ce.mods.transit.Line")
            local RoadStation = require("ce.mods.transit.RoadStation")
            local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")
            local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

            EepSimulator.simulateAddTrain("#DepotGreenIndexTrain", "Depot Green Index RS")
            local startStation = RoadStation:new("Depot Green Index Start", -1)
            local segment = Line.forName("G"):addSection("Depot Green Index Route", "Depot Green Index Destination")
            segment:addStop(startStation:platform(1), 0)
            TrainRegistry.getOrCreate("#DepotGreenIndexTrain"):setRoute(segment.routeName)
            EEPSetSignal(803, 2)
            EepSimulator.simulateQueueTrainOnSignal(803, "#DepotGreenIndexTrain")
            CeTransitModule:registerDepotSignals(803)

            SignalUpdater.runUpdate()
            CeTransitModule.run()

            assert.equals(1, EEPGetSignal(803))
        end)
    end)

    it("does not release a depot signal for a wait-in-depot route", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local Line = require("ce.mods.transit.Line")
        local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local TransitTrainRegistry = require("ce.mods.transit.data.TransitTrainRegistry")

        EepSimulator.simulateAddTrain("#DepotWaitTrain", "Depot Wait RS")
        local depotSection = Line.forName("DepotWaitInternal"):createDepotSection("Depot Wait Route")
            :addDepotDisplay("zZ", "Ich mach Pause")
        depotSection:setDepotDisplayChooser(function () return 1 end)
        TrainRegistry.getOrCreate("#DepotWaitTrain"):setRoute(depotSection.routeName)
        EEPSetSignal(804, 1)
        EepSimulator.simulateQueueTrainOnSignal(804, "#DepotWaitTrain")
        CeTransitModule:registerDepotSignals(804)

        SignalUpdater.runUpdate()
        CeTransitModule.run()

        local transitTrain = TransitTrainRegistry.get("#DepotWaitTrain")
        assert.equals(1, EEPGetSignal(804))
        assert.equals("zZ", transitTrain:getLine())
        assert.equals("Ich mach Pause", transitTrain:getDestination())
    end)

    it("does not release a depot signal for an unknown route", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local CeTransitModule = require("ce.mods.transit.CeTransitModule")
        local SignalUpdater = require("ce.hub.data.signals.SignalUpdater")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

        EepSimulator.simulateAddTrain("#DepotUnknownTrain", "Depot Unknown RS")
        TrainRegistry.getOrCreate("#DepotUnknownTrain"):setRoute("Depot Route Unknown")
        EEPSetSignal(802, 1)
        EepSimulator.simulateQueueTrainOnSignal(802, "#DepotUnknownTrain")
        CeTransitModule:registerDepotSignals(802)

        local originalPrint = _G.print
        local printedLines = {}
        _G.print = function (message) table.insert(printedLines, message) end
        SignalUpdater.runUpdate()
        CeTransitModule.run()
        _G.print = originalPrint

        assert.equals(1, EEPGetSignal(802))
        for _, message in ipairs(printedLines) do
            assert.not_match("Could not find lineSegment", message)
        end
    end)
end)
