insulate("ce.mods.road.TramCrossing", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local Scheduler
    local TramCrossing

    local function resetScheduler()
        Scheduler.scheduledTasks = {}
        Scheduler.futureTasks = {}
        Scheduler.lastRuntime = 0
        Scheduler.ready = true
    end

    before_each(function ()
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.mods.road.TramCrossing")
        TramCrossing = require("ce.mods.road.TramCrossing")
        Scheduler = require("ce.hub.scheduler.Scheduler")
        resetScheduler()
        _G.EEPTime = 1000
    end)

    it("loads count from the primary signal tag and switches occupied", function ()
        EEPSignalSetTagText(101, "c=2,")

        local crossing = TramCrossing:new("Crossing A", 101, 1, 2, 3)

        assert.equals("Crossing A", crossing.name)
        assert.equals(2, crossing.count)
        assert.equals(1, EEPGetSignal(101))
    end)

    it("uses zero when the primary signal tag is missing", function ()
        local crossing = TramCrossing:new("Crossing B", 102, 1, 2, 3)

        assert.equals(0, crossing.count)
        assert.equals(2, EEPGetSignal(102))
    end)

    it("uses zero when the primary signal tag count is invalid", function ()
        EEPSignalSetTagText(103, "c=invalid,")

        local crossing = TramCrossing:new("Crossing C", 103, 1, 2, 3)

        assert.equals(0, crossing.count)
        assert.equals(2, EEPGetSignal(103))
    end)

    it("increments count, stores it, and switches from yellow to occupied", function ()
        local crossing = TramCrossing:new("Crossing D", 104, 1, 2, 3)

        crossing:trainEntered("#Tram1")
        local okYellowTag, yellowTag = EEPSignalGetTagText(104)

        assert.is_true(okYellowTag)
        assert.equals("c=1,", yellowTag)
        assert.equals(1, crossing.count)
        assert.equals(3, EEPGetSignal(104))

        _G.EEPTime = _G.EEPTime + 2
        Scheduler:runTasks()

        assert.equals(1, EEPGetSignal(104))
    end)

    it("switches clear immediately when count reaches zero", function ()
        EEPSignalSetTagText(105, "c=1,")
        local crossing = TramCrossing:new("Crossing E", 105, 1, 2, 3)

        crossing:trainExited("#Tram1")
        local okTag, tag = EEPSignalGetTagText(105)

        assert.is_true(okTag)
        assert.equals("c=0,", tag)
        assert.equals(0, crossing.count)
        assert.equals(2, EEPGetSignal(105))
    end)

    it("clamps count at zero when a train leaves too often", function ()
        local crossing = TramCrossing:new("Crossing F", 106, 1, 2, 3)

        crossing:trainExited("#Tram1")
        local _, tag = EEPSignalGetTagText(106)

        assert.equals(0, crossing.count)
        assert.equals("c=0,", tag)
        assert.equals(2, EEPGetSignal(106))
    end)

    it("adds more signals for switching without storing counts in them", function ()
        local crossing = TramCrossing:new("Crossing G", 107, 1, 2, 3)
        local returned = crossing:addSignal(108, 4, 5, 6)

        assert.equals(crossing, returned)

        crossing:trainEntered("#Tram1")
        local _, primaryTag = EEPSignalGetTagText(107)
        local _, addedTag = EEPSignalGetTagText(108)

        assert.equals("c=1,", primaryTag)
        assert.is_nil(addedTag)
        assert.equals(3, EEPGetSignal(107))
        assert.equals(6, EEPGetSignal(108))

        _G.EEPTime = _G.EEPTime + 2
        Scheduler:runTasks()

        assert.equals(1, EEPGetSignal(107))
        assert.equals(4, EEPGetSignal(108))
    end)

    it("uses occupied as yellow fallback when no yellow position is configured", function ()
        local crossing = TramCrossing:new("Crossing H", 109, 1, 2)

        crossing:trainEntered("#Tram1")

        assert.equals(1, EEPGetSignal(109))
    end)

    it("uses a configurable yellow phase duration", function ()
        local crossing = TramCrossing:new("Crossing I", 110, 1, 2, 3):setYellowPhaseSeconds(5)

        crossing:trainEntered("#Tram1")
        _G.EEPTime = _G.EEPTime + 4
        Scheduler:runTasks()

        assert.equals(3, EEPGetSignal(110))

        _G.EEPTime = _G.EEPTime + 1
        Scheduler:runTasks()

        assert.equals(1, EEPGetSignal(110))
    end)

    it("switches to clear immediately when the crossing clears during the yellow phase", function ()
        local crossing = TramCrossing:new("Crossing J", 111, 1, 2, 3)

        crossing:trainEntered("#Tram1")
        assert.equals(3, EEPGetSignal(111))

        crossing:trainExited("#Tram1")
        assert.equals(2, EEPGetSignal(111))

        _G.EEPTime = _G.EEPTime + 2
        Scheduler:runTasks()

        assert.equals(2, EEPGetSignal(111))
    end)
end)
