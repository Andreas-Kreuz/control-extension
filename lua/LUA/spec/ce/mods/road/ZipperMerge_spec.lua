insulate("ce.mods.road.ZipperMerge", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local ZipperMerge
    local StorageUtility

    local function tagValues(signalId)
        local ok, tag = EEPSignalGetTagText(signalId)
        assert.is_true(ok)
        return StorageUtility.parseTableFromString(tag)
    end

    before_each(function ()
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.eep.EepSimulatorRuntime")
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.data.signals.SignalRegistry")
        clearModule("ce.mods.road.ZipperMerge")
        require("ce.hub.eep.EepSimulator")
        StorageUtility = require("ce.hub.util.StorageUtility")
        ZipperMerge = require("ce.mods.road.ZipperMerge")
    end)

    it("loads persisted state without switching signals red when blocked or empty", function ()
        EEPSignalSetTagText(101, "x=keep,zmb=true,zmc=2,zml=merge,zmq=#Car1|#Car2,")
        EEPSetSignal(101, 1)
        EEPSetSignal(102, 1)

        local blocked = ZipperMerge:new("Blocked", 101, 102)
        local mirroredMergeValues = tagValues(102)

        assert.equals("Blocked", blocked.name)
        assert.equals(2, blocked.mainQueue:size())
        assert.equals(0, blocked.mergeQueue:size())
        assert.equals(1, blocked.resultingQueue:size())
        assert.is_true(blocked.resultingLaneBlocked)
        assert.equals("merge", blocked.lastGreen)
        assert.equals(1, EEPGetSignal(101))
        assert.equals(1, EEPGetSignal(102))
        assert.equals("true", mirroredMergeValues.zmb)
        assert.equals("1", mirroredMergeValues.zmrc)
        assert.equals("merge", mirroredMergeValues.zml)

        EEPSetSignal(103, 1)
        EEPSetSignal(104, 1)
        ZipperMerge:new("Empty", 103, 104)

        assert.equals(1, EEPGetSignal(103))
        assert.equals(1, EEPGetSignal(104))
    end)

    it("lets main traffic pass by switching only main green", function ()
        EEPSetSignal(202, 1)
        local zipperMerge = ZipperMerge:new("Main only", 201, 202)

        zipperMerge:trafficOnMain("#Car1")
        local mainValues = tagValues(201)
        local mergeValues = tagValues(202)

        assert.equals(1, EEPGetSignal(201))
        assert.equals(1, EEPGetSignal(202))
        assert.equals("1", mainValues.zmc)
        assert.equals("#Car1", mainValues.zmq)
        assert.equals("1", mainValues.zmrc)
        assert.equals("#Car1", mainValues.zmrq)
        assert.equals("0", mergeValues.zmc)
        assert.equals("true", mainValues.zmb)
        assert.equals("main", mainValues.zml)
    end)

    it("lets merge traffic pass by switching only merge green", function ()
        EEPSetSignal(211, 1)
        local zipperMerge = ZipperMerge:new("Merge only", 211, 212)

        zipperMerge:trafficOnMerge("#Car1")

        assert.equals(1, EEPGetSignal(211))
        assert.equals(1, EEPGetSignal(212))
        assert.equals("merge", tagValues(212).zml)
    end)

    it("uses main first when both lanes are waiting without a previous green side", function ()
        EEPSignalSetTagText(301, "zmc=1,")
        EEPSignalSetTagText(302, "zmc=1,")

        local zipperMerge = ZipperMerge:new("Both first", 301, 302)

        assert.equals(1, EEPGetSignal(301))
        assert.equals(2, EEPGetSignal(302))
        assert.equals("main", zipperMerge.lastGreen)
        assert.is_true(zipperMerge.resultingLaneBlocked)
    end)

    it("alternates after the resulting lane is free", function ()
        local zipperMerge = ZipperMerge:new("Alternating", 401, 402)

        zipperMerge:trafficOnMain("#Car1")
        zipperMerge:trafficOnMerge("#Car2")

        assert.equals(1, EEPGetSignal(401))
        assert.equals(2, EEPGetSignal(402))

        EEPSetSignal(401, 2)
        zipperMerge:resultingLaneFree("#Car1")
        local mainValues = tagValues(401)
        local mergeValues = tagValues(402)

        assert.equals(2, EEPGetSignal(401))
        assert.equals(1, EEPGetSignal(402))
        assert.equals("0", mainValues.zmc)
        assert.equals("1", mergeValues.zmc)
        assert.equals("#Car2", mergeValues.zmq)
        assert.equals("1", mergeValues.zmrc)
        assert.equals("#Car2", mergeValues.zmrq)
        assert.equals("merge", mainValues.zml)
        assert.equals("true", mergeValues.zmb)

        EEPSetSignal(402, 2)
        zipperMerge:resultingLaneFree("#Car2")

        assert.equals(2, EEPGetSignal(401))
        assert.equals(2, EEPGetSignal(402))
        assert.equals("0", tagValues(402).zmc)
        assert.equals("0", tagValues(402).zmrc)
        assert.equals("false", tagValues(401).zmb)
    end)

    it("counts repeated cars while the resulting lane is still blocked", function ()
        local zipperMerge = ZipperMerge:new("Counted", 451, 452)

        zipperMerge:trafficOnMain("#Car1")
        zipperMerge:trafficOnMain("#Car2")

        assert.equals(2, zipperMerge.mainQueue:size())
        assert.equals("2", tagValues(451).zmc)

        EEPSetSignal(451, 2)
        zipperMerge:resultingLaneFree("#Car1")

        assert.equals(1, zipperMerge.mainQueue:size())
        assert.equals(1, zipperMerge.resultingQueue:size())
        assert.equals(1, EEPGetSignal(451))
        assert.equals("1", tagValues(451).zmc)
        assert.equals("#Car2", tagValues(451).zmq)
        assert.equals("#Car2", tagValues(451).zmrq)
        assert.equals("true", tagValues(451).zmb)
    end)

    it("self-corrects a lane queue by clearing all cars up to the resulting lane vehicle", function ()
        local zipperMerge = ZipperMerge:new("Self correcting", 461, 462)

        zipperMerge:trafficOnMerge("#Car1")
        zipperMerge:trafficOnMerge("#Car2")
        zipperMerge:trafficOnMerge("#Car3")
        zipperMerge.lastGreen = "main"
        EEPSetSignal(462, 2)
        zipperMerge:resultingLaneFree("#Car2")

        assert.equals(1, zipperMerge.mergeQueue:size())
        assert.equals(1, zipperMerge.resultingQueue:size())
        assert.are.same({ "#Car3" }, zipperMerge.mergeQueue:elements())
        assert.are.same({ "#Car3" }, zipperMerge.resultingQueue:elements())
        assert.equals("1", tagValues(462).zmc)
        assert.equals("#Car3", tagValues(462).zmq)
        assert.equals("#Car3", tagValues(462).zmrq)
    end)

    it("resets both queues and shared zipper state", function ()
        local zipperMerge = ZipperMerge:new("Reset", 471, 472)

        zipperMerge:trafficOnMain("#Car1")
        zipperMerge:trafficOnMerge("#Car2")
        zipperMerge:reset()

        assert.equals(0, zipperMerge.mainQueue:size())
        assert.equals(0, zipperMerge.mergeQueue:size())
        assert.equals(0, zipperMerge.resultingQueue:size())
        assert.is_false(zipperMerge.resultingLaneBlocked)
        assert.is_nil(zipperMerge.lastGreen)
        assert.equals("0", tagValues(471).zmc)
        assert.equals("", tagValues(471).zmq)
        assert.equals("0", tagValues(471).zmrc)
        assert.equals("", tagValues(471).zmrq)
        assert.equals("false", tagValues(471).zmb)
    end)

    it("preserves unrelated signal tag values", function ()
        EEPSignalSetTagText(501, "x=keep,")
        EEPSignalSetTagText(502, "y=stay,")
        local zipperMerge = ZipperMerge:new("Preserve tags", 501, 502)

        zipperMerge:trafficOnMain("#Car1")

        assert.equals("keep", tagValues(501).x)
        assert.equals("stay", tagValues(502).y)
    end)

    it("exposes debug tipp texts for the road tipp text composer", function ()
        ZipperMerge.debug = true
        local zipperMerge = ZipperMerge:new("Debug", 551, 552)
        zipperMerge:trafficOnMain("#Car1")

        local mainText = ZipperMerge.debugTippTextForSignalId(551)
        local mergeText = ZipperMerge.debugTippTextForSignalId(552)

        assert.is_truthy(string.find(mainText, "ZipperMerge Debug", 1, true))
        assert.is_truthy(string.find(mainText, "Signal: main", 1, true))
        assert.is_truthy(string.find(mainText, "Main count: 1", 1, true))
        assert.is_truthy(string.find(mergeText, "Signal: merge", 1, true))
    end)

    it("supports registry resolution and warns on duplicate keys", function ()
        local first = ZipperMerge:new("Registry A", 601, 602):setKpId("zipperA")
        local second = ZipperMerge:new("Registry B", 603, 604)
        local printStub = stub(_G, "print")

        assert.equals(first, ZipperMerge.resolve("zipperA"))
        assert.equals(second, second:setKpId("zipperA"))
        assert.equals(second, ZipperMerge.resolve("zipperA"))
        assert.stub(printStub).was_called()

        printStub:revert()
    end)
end)
