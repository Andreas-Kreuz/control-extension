insulate("ce.mods.road.TrafficLight", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.mods.road.TrafficLight")
        clearModule("ce.mods.road.IntersectionSettings")
    end)

    it("stores the constructor name as traffic signal name", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local signal = TrafficLight:newForSignal("K1", -1, TrafficLightModel.NONE)

        assert.equals("K1", signal.vehicleSignalName)
        assert.is_nil(signal.pedestrianSignalName)
        assert.equals(TrafficLight.Use.VEHICLE_ONLY, signal.use)
    end)

    it("keeps new as compatibility alias", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local signal = TrafficLight:new("K2", -1, TrafficLightModel.NONE)

        assert.equals("K2", signal.vehicleSignalName)
        assert.equals(TrafficLight.Use.VEHICLE_ONLY, signal.use)
    end)
    it("creates plain structure lights without a real EEP signal", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        EEPStructureSetLight("#1_Rot", false)
        EEPStructureSetLight("#1_Gruen", false)
        EEPStructureSetLight("#1_Gelb", false)
        EEPStructureSetLight("#1_A", false)
        local signal = TrafficLight:newForLightStructure("S1", "#1_Rot", "#1_Gruen", "#1_Gelb", "#1_A")

        assert.equals("S1", signal.vehicleSignalName)
        assert.equals(TrafficLightModel.NONE, signal.trafficLightModel)
        assert.equals(TrafficLight.Use.VEHICLE_ONLY, signal.use)
        assert.is_true(signal.signalId < 0)
    end)

    it("stores light structure housing tags", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local StorageUtility = require("ce.hub.util.StorageUtility")

        EEPStructureSetLight("#1_Rot", false)
        EEPStructureSetLight("#1_Links", false)
        EEPStructureSetLight("#1_Gelb", false)
        EEPStructureSetLight("#1_A", false)
        TrafficLight:newForLightStructure("S1", "#1_Rot", "#1_Links", "#1_Gelb", "#1_A", "#1_Gehaeuse",
                                          "#1_Blende")

        local _, housingTag = EEPStructureGetTagText("#1_Gehaeuse")
        local values = StorageUtility.parseTableFromString(housingTag)
        assert.equals("#1_Rot", values.F0)
        assert.equals("#1_Links", values.F3)
        assert.equals("#1_Gelb", values.F4)
        assert.equals("#1_A", values.A)
        assert.equals("#1_Blende", values.bl)
        assert.equals("#1_Rot", values.r)
        assert.equals("#1_Gelb", values.y)
        assert.equals("#1_Links", values.g)
        local _, redTag = EEPStructureGetTagText("#1_Rot")
        local _, blendTag = EEPStructureGetTagText("#1_Blende")
        assert.equals(housingTag, redTag)
        assert.equals(housingTag, blendTag)
    end)
    it("adds a pedestrian signal name with chainable asPedestrianSignal", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local signal = TrafficLight:newForSignal("K1", -1, TrafficLightModel.NONE)
        local returned = signal:asPedestrianSignal("F1")

        assert.equals(signal, returned)
        assert.equals("K1", signal.vehicleSignalName)
        assert.equals("F1", signal.pedestrianSignalName)
        assert.equals(TrafficLight.Use.VEHICLE_AND_PEDESTRIAN, signal.use)
    end)

    it("creates pedestrian only lights", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local signal = TrafficLight:newPedestrianOnly("F1", -1, TrafficLightModel.NONE)

        assert.is_nil(signal.vehicleSignalName)
        assert.equals("F1", signal.pedestrianSignalName)
        assert.equals(TrafficLight.Use.PEDESTRIAN_ONLY, signal.use)
    end)

    it("moves the constructor name when marked as pedestrian only", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local signal = TrafficLight:new("F1", -1, TrafficLightModel.NONE)
        local returned = signal:asPedestrianOnly()

        assert.equals(signal, returned)
        assert.is_nil(signal.vehicleSignalName)
        assert.equals("F1", signal.pedestrianSignalName)
        assert.equals(TrafficLight.Use.PEDESTRIAN_ONLY, signal.use)
    end)

    it("renders combined signal names with role specific colors", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local SignalIndication = require("ce.mods.road.SignalIndication")

        local signal = TrafficLight:newForSignal("K1_main", -1, TrafficLightModel.NONE):asPedestrianSignal("F1_walk")
        signal.currentIndication = SignalIndication.PEDESTRIAN

        assert.equals(
            "<bgrgb=255,96,96><b>K1</b><bgrgb=255,255,255><br>" ..
            "<bgrgb=0,128,0><fgrgb=255,255,255><b>F1</b><bgrgb=255,255,255><fgrgb=0,0,0>",
            signal:signalNamesTippText())
    end)

    it("renders off signal names as grey text without background", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local SignalIndication = require("ce.mods.road.SignalIndication")

        local signal = TrafficLight:newForSignal("K1_main", -1, TrafficLightModel.NONE):asPedestrianSignal("F1_walk")
        signal.currentIndication = SignalIndication.OFF

        assert.equals("<fgrgb=128,128,128><b>K1</b><fgrgb=0,0,0>", signal:vehicleSignalNameTippText())
        assert.equals("<fgrgb=128,128,128><b>F1</b><fgrgb=0,0,0>", signal:pedestrianSignalNameTippText())
    end)

    it("renders selected tooltip sections in configured order", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local SignalIndication = require("ce.mods.road.SignalIndication")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local fmt = require("ce.hub.eep.TippTextFormatter")

        local signal = TrafficLight:newForSignal("K1", -1, TrafficLightModel.NONE)
        signal.currentIndication = SignalIndication.RED
        signal:setLaneNameInfo(fmt.bgGrey("Lane 1"))
        signal:setLaneInfo(fmt.lightGrey("BELEGT") .. "<br>#Car1")
        signal:setPhaseInfo("<br><j>P1 " .. fmt.bgGreen("(Gruen)"))
        IntersectionSettings.showSignalIdOnSignal = true
        IntersectionSettings.showModelInfoOnSignal = true
        IntersectionSettings.showLaneNamesOnSignal = true
        IntersectionSettings.showNameAndPhaseOnSignal = true
        IntersectionSettings.showRequestsOnSignal = true
        IntersectionSettings.showPhaseOnSignal = true

        local infoText
        stub(signal, "showInfoText", function () end)
        stub(signal, "changeInfoText", function (_, text) infoText = text end)

        signal:refreshInfo()

        assert.equals(
            "<j>Signal: -2<br>" ..
            "NO SIGNAL MODEL<br>" ..
            "<bgrgb=160,160,160>Lane 1<bgrgb=255,255,255><br>" ..
            "<bgrgb=255,96,96><b>K1</b><bgrgb=255,255,255><br>" ..
            "<bgrgb=196,196,196><fgrgb=66,66,66>BELEGT<bgrgb=255,255,255><fgrgb=0,0,0><br>#Car1" ..
            "<br><br><b>Phase: </b><br><j>P1 <bgrgb=0,192,0>(Gruen)<bgrgb=255,255,255>",
            infoText)
    end)
    it("uses the EEP signal model path for model info when it is known", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

        local signal = TrafficLight:newForSignal("K1", 40, TrafficLightModel.NONE)
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

        local infoText
        stub(signal, "showInfoText", function () end)
        stub(signal, "changeInfoText", function (_, text) infoText = text end)

        signal:refreshInfo()

        assert.is_truthy(string.find(infoText, TrafficLightModel.JS2_3er_mit_FG.name, 1, true))
        assert.is_truthy(string.find(infoText, "<b>3: Gruen</b>.", 1, true))
    end)

    it("does not show lane signals for short name and color alone", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

        local signal = TrafficLight:newForSignal("L1", -1, TrafficLightModel.NONE)
        signal.isLaneSignal = true
        IntersectionSettings.showNameAndPhaseOnSignal = true

        local visible
        stub(signal, "showInfoText", function (_, showInfo) visible = showInfo end)
        stub(signal, "changeInfoText", function () error("no tooltip text expected") end)

        signal:refreshInfo()

        assert.is_false(visible)
    end)

    it("shows short name and color for lane signals that are part of a signal group", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local SignalGroup = require("ce.mods.road.SignalGroup")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

        local signal = TrafficLight:newForSignal("L1", -1, TrafficLightModel.NONE)
        signal.isLaneSignal = true
        SignalGroup:new("sgLane1"):addVehicleSignals(signal)
        IntersectionSettings.showNameAndPhaseOnSignal = true

        local infoText
        stub(signal, "showInfoText", function () end)
        stub(signal, "changeInfoText", function (_, text) infoText = text end)

        signal:refreshInfo()

        assert.is_truthy(string.find(infoText, "<b>L1</b>", 1, true))
    end)
    it("shows lane signal name and lane name only for lane signal setting", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
        local fmt = require("ce.hub.eep.TippTextFormatter")

        local signal = TrafficLight:newForSignal("L1", -1, TrafficLightModel.NONE)
        signal.isLaneSignal = true
        signal:setLaneNameInfo(signal:signalNamesTippText() .. " " .. fmt.bgLightBlue("Lane 1"))
        IntersectionSettings.showLaneNamesOnSignal = true

        local infoText
        stub(signal, "showInfoText", function () end)
        stub(signal, "changeInfoText", function (_, text) infoText = text end)

        signal:refreshInfo()

        assert.is_truthy(string.find(infoText, "<b>L1</b>", 1, true))
        assert.is_truthy(string.find(infoText, "Lane 1", 1, true))
    end)

    it("shows the housing structure id as signal id for structure lights", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

        EEPStructureSetLight("#2201_Rot", false)
        EEPStructureSetLight("#2202_Gruen", false)
        local signal = TrafficLight:newForLightStructure("S3", "#2201_Rot", "#2202_Gruen", nil, nil, "#2200_Gehaeuse")
        IntersectionSettings.showSignalIdOnSignal = true

        local infoText
        stub(signal, "showInfoText", function () end)
        stub(signal, "changeInfoText", function (_, text) infoText = text end)

        signal:refreshInfo()

        assert.is_truthy(string.find(infoText, "Immo: #2200", 1, true))
        assert.is_nil(string.find(infoText, "#2200_Gehaeuse", 1, true))
        assert.is_nil(string.find(infoText, "Signal: ", 1, true))
    end)
    it("hides and clears all structure tooltip targets when disabled", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

        EEPStructureSetLight("#2_Rot", false)
        EEPStructureSetLight("#2_Gruen", false)
        local signal = TrafficLight:newForLightStructure("S2", "#2_Rot", "#2_Gruen", nil, nil, "#2_Gehaeuse")
        IntersectionSettings.showSignalIdOnSignal = true
        IntersectionSettings.showNameAndPhaseOnSignal = true

        local shown = {}
        local changed = {}
        local showInfoStructureStub = stub(_G, "EEPShowInfoStructure", function (structureName, visible)
            shown[structureName] = visible
        end)
        local changeInfoStructureStub = stub(_G, "EEPChangeInfoStructure", function (structureName, text)
            changed[structureName] = text
        end)
        finally(function ()
            showInfoStructureStub:revert()
            changeInfoStructureStub:revert()
        end)

        signal:refreshInfo()
        IntersectionSettings.showSignalIdOnSignal = false
        IntersectionSettings.showNameAndPhaseOnSignal = false
        signal:refreshInfo()

        assert.is_false(shown["#2_Gehaeuse"])
        assert.is_false(shown["#2_Rot"])
        assert.is_false(shown["#2_Gruen"])
        assert.equals("", changed["#2_Gehaeuse"])
        assert.equals("", changed["#2_Rot"])
        assert.equals("", changed["#2_Gruen"])
    end)
    it("uses the housing structure for structure light tooltip text", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

        EEPStructureSetLight("#1_Rot", false)
        EEPStructureSetLight("#1_Gruen", false)
        local signal = TrafficLight:newForLightStructure("S1", "#1_Rot", "#1_Gruen", nil, nil, "#1_Gehaeuse")
        IntersectionSettings.showNameAndPhaseOnSignal = true

        local shownStructure
        local changedStructure
        local showInfoStructureStub = stub(_G, "EEPShowInfoStructure", function (structureName)
            shownStructure = structureName
        end)
        local changeInfoStructureStub = stub(_G, "EEPChangeInfoStructure", function (structureName)
            changedStructure = structureName
        end)
        finally(function ()
            showInfoStructureStub:revert()
            changeInfoStructureStub:revert()
        end)

        signal:refreshInfo()

        assert.equals("#1_Gehaeuse", shownStructure)
        assert.equals("#1_Gehaeuse", changedStructure)
    end)
end)
