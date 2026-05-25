insulate("ce.mods.road.TrafficLight", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.eep.EepSimulatorStore")
        clearModule("ce.hub.eep.EepSimulatorRuntime")
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.data.signals.SignalRegistry")
        clearModule("ce.hub.data.structures.StructureRegistry")
        clearModule("ce.mods.road.TrafficLight")
        require("ce.hub.eep.EepSimulator")
    end)

    it("stores the constructor name as traffic signal name", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local signal = TrafficLight:newForSignal("K1", -1, TrafficLightModel.NONE)

        assert.equals("K1", signal:getVehicleSignalName())
        assert.is_nil(signal:getPedestrianSignalName())
        assert.equals(TrafficLight.Use.VEHICLE_ONLY, signal:getUse())
    end)

    it("keeps new as compatibility alias", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local signal = TrafficLight:new("K2", -1, TrafficLightModel.NONE)

        assert.equals("K2", signal:getVehicleSignalName())
        assert.equals(TrafficLight.Use.VEHICLE_ONLY, signal:getUse())
    end)

    it("creates plain structure lights without a real EEP signal", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        EEPStructureSetLight("#1_Rot", false)
        EEPStructureSetLight("#1_Gruen", false)
        EEPStructureSetLight("#1_Gelb", false)
        EEPStructureSetLight("#1_A", false)
        local signal = TrafficLight:newForLightStructure("S1", "#1_Rot", "#1_Gruen", "#1_Gelb", "#1_A")

        assert.equals("S1", signal:getVehicleSignalName())
        assert.equals(TrafficLightModel.NONE, signal:getTrafficLightModel())
        assert.equals(TrafficLight.Use.VEHICLE_ONLY, signal:getUse())
        assert.is_true(signal:getSignalId() < 0)
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
        assert.equals("K1", signal:getVehicleSignalName())
        assert.equals("F1", signal:getPedestrianSignalName())
        assert.equals(TrafficLight.Use.VEHICLE_AND_PEDESTRIAN, signal:getUse())
    end)

    it("creates pedestrian only lights", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local signal = TrafficLight:newPedestrianOnly("F1", -1, TrafficLightModel.NONE)

        assert.is_nil(signal:getVehicleSignalName())
        assert.equals("F1", signal:getPedestrianSignalName())
        assert.equals(TrafficLight.Use.PEDESTRIAN_ONLY, signal:getUse())
    end)

    it("exposes signal group and structure target facts", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local SignalGroup = require("ce.mods.road.SignalGroup")

        local signal = TrafficLight:newForLightStructure("S1", "#1_Rot", "#1_Gruen", "#1_Gelb", "#1_A",
                                                        "#1_Gehaeuse", "#1_Blende")
        local group = SignalGroup:new("sg1"):addVehicleSignals(signal)

        assert.equals(group, signal:getSignalGroupsByUse().VEHICLE)
        assert.are.same({ "#1_Gehaeuse" }, signal:getPrimaryTippTextStructures())
        assert.are.same({ "#1_Gehaeuse", "#1_Rot", "#1_Gruen", "#1_Gelb", "#1_A", "#1_Blende" },
                        signal:getAllTippTextStructures())
    end)
end)
