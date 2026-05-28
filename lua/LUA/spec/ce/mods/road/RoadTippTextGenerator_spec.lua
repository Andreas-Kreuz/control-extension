insulate("ce.mods.road.tipptext.RoadTippTextGenerator", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.eep.EepSimulatorRuntime")
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.data.signals.SignalRegistry")
        clearModule("ce.hub.data.structures.StructureRegistry")
        clearModule("ce.hub.data.structures.SignalHousingStructure")
        clearModule("ce.mods.road.IntersectionSettings")
        clearModule("ce.mods.road.Intersection")
        clearModule("ce.mods.road.Lane")
        clearModule("ce.mods.road.SignalGroup")
        clearModule("ce.mods.road.TrafficLight")
        clearModule("ce.mods.road.ZipperMerge")
        clearModule("ce.mods.road.tipptext.RoadTippTextOptions")
        clearModule("ce.mods.road.tipptext.RoadSignalTippTextComposer")
        clearModule("ce.mods.road.tipptext.RoadOverviewTippTextComposer")
        clearModule("ce.mods.road.tipptext.RoadTippTextGenerator")
        require("ce.hub.eep.EepSimulator")
        _G.EEPTime = nil
    end)

    local function desiredForSignal(signalId)
        return require("ce.mods.road.tipptext.RoadTippTextGenerator").generate().signals[signalId]
    end

    local function addStructure(id, name, gsbname)
        local Structure = require("ce.hub.data.structures.Structure")
        local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
        local structure = Structure:new(id, name)
        structure:setGsbname(gsbname)
        StructureRegistry.add(structure)
        return structure
    end

    it("needs road state refresh only for waiting vehicle text", function ()
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local generator = require("ce.mods.road.tipptext.RoadTippTextGenerator")

        assert.is_false(generator.needsRoadStateRefresh())
        IntersectionSettings.showLaneNamesOnSignal = true
        assert.is_false(generator.needsRoadStateRefresh())
        IntersectionSettings.showRequestsOnSignal = true
        assert.is_true(generator.needsRoadStateRefresh())
    end)

    it("does not generate tipp text while all options are disabled and no managed targets exist", function ()
        local generator = require("ce.mods.road.tipptext.RoadTippTextGenerator")

        assert.equals("false|false|false|false|false|false|false|0|0|0", generator.fingerprint())
        assert.are.same({
            signals = {},
            structures = {}
        }, generator.generate())
    end)

    it("generates zipper merge debug tipp text through managed signal states", function ()
        local ZipperMerge = require("ce.mods.road.ZipperMerge")
        ZipperMerge.debug = true
        local zipperMerge = ZipperMerge:new("Merge Debug", 445, 446)

        zipperMerge:trafficOnMain("#Car1")
        local desired = require("ce.mods.road.tipptext.RoadTippTextGenerator").generate()

        assert.is_true(desired.signals[445].visible)
        assert.is_truthy(string.find(desired.signals[445].text, "ZipperMerge Merge Debug", 1, true))
        assert.is_truthy(string.find(desired.signals[445].text, "Signal: main", 1, true))
        assert.is_truthy(string.find(desired.signals[445].text, "Main count: 1", 1, true))
        assert.is_true(desired.signals[446].visible)
        assert.is_truthy(string.find(desired.signals[446].text, "Signal: merge", 1, true))
    end)

    it("generates managed clears while all options are disabled", function ()
        local Signal = require("ce.hub.data.signals.Signal")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
        local TrafficLight = require("ce.mods.road.TrafficLight")

        SignalRegistry.add(Signal:new(444))
        addStructure("#5003", "#5003_Gehaeuse", "\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm")
        TrafficLight:newForLightStructure("S6_main", "#6_Rot", "#6_Gruen", nil, nil, "#6_Gehaeuse")

        local desired = require("ce.mods.road.tipptext.RoadTippTextGenerator").generate()

        assert.is_false(desired.signals[444].visible)
        assert.equals("", desired.signals[444].text)
        assert.is_false(desired.structures["#5003_Gehaeuse"].visible)
        assert.equals("", desired.structures["#5003_Gehaeuse"].text)
        assert.is_false(desired.structures["#6_Gehaeuse"].visible)
        assert.is_false(desired.structures["#6_Rot"].visible)
        assert.is_false(desired.structures["#6_Gruen"].visible)
    end)

    it("does not fetch model data while model info is disabled", function ()
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        TrafficLight:new("K1", 40, TrafficLightModel.NONE)
        IntersectionSettings.showSignalIdOnSignal = true
        local getOrCreateStub = stub(SignalRegistry, "getOrCreate", function ()
            error("model data should not be fetched")
        end)
        finally(function () getOrCreateStub:revert() end)

        require("ce.mods.road.tipptext.RoadTippTextGenerator").fingerprint()
        local state = desiredForSignal(40)

        assert.is_true(state.visible)
        assert.is_nil(string.find(state.text, TrafficLightModel.NONE.name, 1, true))
    end)

    it("does not read lane request state while waiting vehicles are disabled", function ()
        local Intersection = require("ce.mods.road.Intersection")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local laneSignal = TrafficLight:new("L1_main", 102, TrafficLightModel.Unsichtbar_2er)
        local lane = Intersection:new("C1"):newLane("Lane 1", laneSignal)
        IntersectionSettings.showLaneNamesOnSignal = true
        local requestStateStub = stub(lane, "getRequestState", function ()
            error("request state should not be read")
        end)
        finally(function () requestStateStub:revert() end)

        local state = desiredForSignal(102)

        assert.is_true(state.visible)
        assert.is_truthy(string.find(state.text, "Lane 1", 1, true))
    end)

    it("enables signal id text for registered traffic lights and structures", function ()
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        TrafficLight:new("K1_main", 101, TrafficLightModel.Unsichtbar_2er)
        local structureSignal = TrafficLight:newForLightStructure("S3", "#2201_Rot", "#2202_Gruen", nil, nil,
                                                                  "#2200_Gehaeuse")
        IntersectionSettings.showSignalIdOnSignal = true

        local desired = require("ce.mods.road.tipptext.RoadTippTextGenerator").generate()

        assert.is_true(desired.signals[101].visible)
        assert.is_truthy(string.find(desired.signals[101].text, "Signal: 101", 1, true))
        assert.is_true(desired.structures["#2200_Gehaeuse"].visible)
        assert.is_truthy(string.find(desired.structures["#2200_Gehaeuse"].text, "Immo: #2200", 1, true))
        assert.is_nil(string.find(desired.structures["#2200_Gehaeuse"].text, "#2200_Gehaeuse", 1, true))
        assert.equals(structureSignal, TrafficLight.getAll()[2])
    end)

    it("uses the inferred EEP signal model and active function for model info", function ()
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        TrafficLight:new("K1", 40, TrafficLightModel.NONE)
        IntersectionSettings.showModelInfoOnSignal = true

        local getSignalItemNameStub = stub(_G, "EEPGetSignalItemName", function ()
            return true, "Resourcen/Signale/3erAmpel_FG_JS2.3dm"
        end)
        local getSignalFunctionsStub = stub(_G, "EEPGetSignalFunctions", function () return true, 6 end)
        local getSignalFunctionStub = stub(_G, "EEPGetSignalFunction", function (_, index)
            return true, "F" .. index
        end)
        local getSignalStub = stub(_G, "EEPGetSignal", function () return 3 end)
        finally(function ()
            getSignalItemNameStub:revert()
            getSignalFunctionsStub:revert()
            getSignalFunctionStub:revert()
            getSignalStub:revert()
        end)

        local state = desiredForSignal(40)

        assert.is_true(state.visible)
        assert.is_truthy(string.find(state.text, TrafficLightModel.JS2_3er_mit_FG.name, 1, true))
        assert.is_truthy(string.find(state.text, "<b>3: Gruen</b>.", 1, true))
    end)

    it("fingerprints current model info facts while model info is enabled", function ()
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        TrafficLight:new("K1", 41, TrafficLightModel.NONE)
        IntersectionSettings.showModelInfoOnSignal = true
        local currentPosition = 1
        local itemNameCalls = 0
        local functionsCalls = 0
        local positionCalls = 0

        local getSignalItemNameStub = stub(_G, "EEPGetSignalItemName", function (_, withModelPath)
            itemNameCalls = itemNameCalls + 1
            if withModelPath then return true, "Resourcen/Signale/3erAmpel_FG_JS2.3dm" end
            return true, "3erAmpel_FG_JS2"
        end)
        local getSignalFunctionsStub = stub(_G, "EEPGetSignalFunctions", function ()
            functionsCalls = functionsCalls + 1
            return true, 3
        end)
        local getSignalFunctionStub = stub(_G, "EEPGetSignalFunction", function (_, index)
            return true, "F" .. index
        end)
        local getSignalStub = stub(_G, "EEPGetSignal", function ()
            positionCalls = positionCalls + 1
            return currentPosition
        end)
        finally(function ()
            getSignalItemNameStub:revert()
            getSignalFunctionsStub:revert()
            getSignalFunctionStub:revert()
            getSignalStub:revert()
        end)

        local generator = require("ce.mods.road.tipptext.RoadTippTextGenerator")
        local firstFingerprint = generator.fingerprint()
        currentPosition = 2
        local secondFingerprint = generator.fingerprint()

        assert.is_true(firstFingerprint ~= secondFingerprint)
        assert.equals(2, itemNameCalls)
        assert.equals(1, functionsCalls)
        assert.equals(2, positionCalls)
    end)

    it("shows lane signal name and color together with the lane name", function ()
        local Intersection = require("ce.mods.road.Intersection")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local laneSignal = TrafficLight:new("L1_main", 102, TrafficLightModel.Unsichtbar_2er)
        Intersection:new("C1"):newLane("Lane 1", laneSignal):scriptVariableName("c1Lane1")
        IntersectionSettings.showLaneNamesOnSignal = true

        local state = desiredForSignal(102)

        assert.is_true(state.visible)
        assert.is_truthy(string.find(state.text, "<b>L1</b>", 1, true))
        assert.is_truthy(string.find(state.text, "Lane 1", 1, true))
        assert.is_truthy(string.find(state.text, "c1Lane1", 1, true))
    end)

    it("shows short name and color for regular signals and grouped lane signals only", function ()
        local Intersection = require("ce.mods.road.Intersection")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local SignalGroup = require("ce.mods.road.SignalGroup")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        TrafficLight:new("K1_main", 103, TrafficLightModel.Unsichtbar_2er)
        local laneSignal = TrafficLight:new("L1_main", 104, TrafficLightModel.Unsichtbar_2er)
        Intersection:new("C1"):newLane("Lane 1", laneSignal)
        IntersectionSettings.showNameAndPhaseOnSignal = true

        local desired = require("ce.mods.road.tipptext.RoadTippTextGenerator").generate()
        assert.is_true(desired.signals[103].visible)
        assert.is_truthy(string.find(desired.signals[103].text, "<b>K1</b>", 1, true))
        assert.is_false(desired.signals[104].visible)

        SignalGroup:new("sgLane1"):addVehicleSignals(laneSignal)
        desired = require("ce.mods.road.tipptext.RoadTippTextGenerator").generate()
        assert.is_true(desired.signals[104].visible)
        assert.is_truthy(string.find(desired.signals[104].text, "<b>L1</b>", 1, true))
    end)

    it("shows non-empty phase info only for signals participating in phases", function ()
        local Intersection = require("ce.mods.road.Intersection")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local laneSignal = TrafficLight:new("L1", 105, TrafficLightModel.Unsichtbar_2er)
        local headSignal = TrafficLight:new("K1", 106, TrafficLightModel.Unsichtbar_2er)
        local crossing = Intersection:new("C1")
        local lane = crossing:newLane("Lane 1", laneSignal)
        headSignal:applyToLane(lane)
        local group = crossing:newSignalGroup("sgK1"):addVehicleSignals(headSignal)
        local phase = crossing:newPhase("P1", 15):addSignalGroup(group)
        Intersection.initPhases()
        crossing:onSwitchedToPhase(phase)
        IntersectionSettings.showPhaseOnSignal = true

        local desired = require("ce.mods.road.tipptext.RoadTippTextGenerator").generate()

        assert.is_false(desired.signals[105].visible)
        assert.is_true(desired.signals[106].visible)
        assert.is_truthy(string.find(desired.signals[106].text, "Phase: ", 1, true))
        assert.is_truthy(string.find(desired.signals[106].text, "P1", 1, true))
        assert.is_truthy(string.find(desired.signals[106].text, "Gruen", 1, true))
    end)

    it("builds waiting vehicle text from Lane:getRequestState", function ()
        local Intersection = require("ce.mods.road.Intersection")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local laneSignal = TrafficLight:new("L1", 107, TrafficLightModel.Unsichtbar_2er)
        local lane = Intersection:new("C1"):newLane("Lane 1", laneSignal)
        lane:vehicleEntered("#Car1")
        IntersectionSettings.showRequestsOnSignal = true

        local state = desiredForSignal(107)

        assert.is_true(state.visible)
        assert.is_truthy(string.find(state.text, "BELEGT", 1, true))
        assert.is_truthy(string.find(state.text, "#Car1", 1, true))
    end)

    it("applies Signal-ID fallback only from registered signals", function ()
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local Signal = require("ce.hub.data.signals.Signal")
        local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")

        SignalRegistry.add(Signal:new(333))
        IntersectionSettings.showSignalIdOnSignal = true
        local getOrCreateStub = stub(SignalRegistry, "getOrCreate", function ()
            error("fallback should not create signals")
        end)
        finally(function () getOrCreateStub:revert() end)

        local desired = require("ce.mods.road.tipptext.RoadTippTextGenerator").generate()

        assert.is_true(desired.signals[333].visible)
        assert.equals("<j>Signal: 333", desired.signals[333].text)
        assert.is_nil(desired.signals[332])
    end)

    it("applies Signal-ID fallback to registered signal housing structures only", function ()
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

        addStructure("#5000", "#5000_Gehaeuse", "\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm")
        addStructure("#5001", "#5001_Gehaeuse", "\\Immobilien\\Verkehr\\Sonstiges\\Haus.3dm")
        IntersectionSettings.showSignalIdOnSignal = true

        local desired = require("ce.mods.road.tipptext.RoadTippTextGenerator").generate()

        assert.is_true(desired.structures["#5000_Gehaeuse"].visible)
        assert.equals("<j>Immo: #5000", desired.structures["#5000_Gehaeuse"].text)
        assert.is_nil(desired.structures["#5001_Gehaeuse"])
    end)

    it("keeps richer traffic light text for signal housing structures", function ()
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
        local TrafficLight = require("ce.mods.road.TrafficLight")

        TrafficLight:newForLightStructure("S5_main", "#5_Rot", "#5_Gruen", nil, nil, "#5_Gehaeuse")
        StructureRegistry.getOrCreate("#5_Gehaeuse"):setGsbname(
            "\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm"
        )
        IntersectionSettings.showSignalIdOnSignal = true
        IntersectionSettings.showNameAndPhaseOnSignal = true

        local desired = require("ce.mods.road.tipptext.RoadTippTextGenerator").generate()

        assert.is_true(desired.structures["#5_Gehaeuse"].visible)
        assert.is_truthy(string.find(desired.structures["#5_Gehaeuse"].text, "Immo: #5", 1, true))
        assert.is_truthy(string.find(desired.structures["#5_Gehaeuse"].text, "<b>S5</b>", 1, true))
    end)

    it("fingerprints structure registry changes while signal id text is enabled", function ()
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local generator = require("ce.mods.road.tipptext.RoadTippTextGenerator")

        IntersectionSettings.showSignalIdOnSignal = true
        local firstFingerprint = generator.fingerprint()
        addStructure("#5002", "#5002_Gehaeuse", "\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm")
        local secondFingerprint = generator.fingerprint()

        assert.is_true(firstFingerprint ~= secondFingerprint)
    end)

    it("fingerprints structure registry changes while signal id text is disabled", function ()
        local generator = require("ce.mods.road.tipptext.RoadTippTextGenerator")

        local firstFingerprint = generator.fingerprint()
        addStructure("#5004", "#5004_Gehaeuse", "\\Immobilien\\Verkehr\\Signale\\StrabaSigGM_4_MA1.3dm")
        local secondFingerprint = generator.fingerprint()

        assert.is_true(firstFingerprint ~= secondFingerprint)
    end)

    it("shows structure housing targets and clears all related structure targets", function ()
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local TrafficLight = require("ce.mods.road.TrafficLight")

        TrafficLight:newForLightStructure("S2", "#2_Rot", "#2_Gruen", nil, nil, "#2_Gehaeuse")
        IntersectionSettings.showNameAndPhaseOnSignal = true

        local desired = require("ce.mods.road.tipptext.RoadTippTextGenerator").generate()
        assert.is_true(desired.structures["#2_Gehaeuse"].visible)
        assert.is_truthy(string.find(desired.structures["#2_Gehaeuse"].text, "<b>S2</b>", 1, true))
        assert.is_false(desired.structures["#2_Rot"].visible)
        assert.equals("", desired.structures["#2_Rot"].text)

        IntersectionSettings.showNameAndPhaseOnSignal = false
        desired = require("ce.mods.road.tipptext.RoadTippTextGenerator").generate()
        assert.is_false(desired.structures["#2_Gehaeuse"].visible)
        assert.equals("", desired.structures["#2_Gehaeuse"].text)
        assert.is_false(desired.structures["#2_Rot"].visible)
        assert.equals("", desired.structures["#2_Rot"].text)
        assert.is_false(desired.structures["#2_Gruen"].visible)
        assert.equals("", desired.structures["#2_Gruen"].text)
    end)

    it("shows crossing overview phases with current phase emphasis and shrinking green bar", function ()
        local Intersection = require("ce.mods.road.Intersection")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local headSignal = TrafficLight:new("K1", 201, TrafficLightModel.Unsichtbar_2er)
        local laneSignal = TrafficLight:new("L1", 202, TrafficLightModel.Unsichtbar_2er)
        local crossing = Intersection:new("Overview Crossing"):setTippStructure("#Overview")
        local lane = crossing:newLane("Lane 1", laneSignal)
        headSignal:applyToLane(lane)
        local group = crossing:newSignalGroup("sgK1"):addVehicleSignals(headSignal)
        local phase = crossing:newPhase("P1", 15):addSignalGroup(group)
        crossing:newPhase("P2", 15):addSignalGroup(group)
        Intersection.initPhases()
        crossing:onSwitchedToPhase(phase)
        crossing.currentPhaseStartedAt = 100
        _G.EEPTime = 109
        IntersectionSettings.showLanesOnStructure = true

        local target = require("ce.mods.road.tipptext.RoadTippTextGenerator").generate().structures["#Overview"]

        assert.is_true(target.visible)
        assert.is_truthy(string.find(target.text, "<b>Overview Crossing</b>", 1, true))
        assert.is_truthy(string.find(target.text, "<bgrgb=0,192,0>X___<bgrgb=255,255,255>__  <b>P1</b>", 1, true))
        assert.is_truthy(string.find(target.text, "X_____", 1, true))
        assert.is_nil(string.find(target.text, "Lane 1", 1, true))
    end)
end)
