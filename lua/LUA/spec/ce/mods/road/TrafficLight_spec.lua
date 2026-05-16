insulate("ce.mods.road.TrafficLight", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.mods.road.TrafficLight")
    end)

    it("stores the constructor name as traffic signal name", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local signal = TrafficLight:new("K1", -1, TrafficLightModel.NONE)

        assert.equals("K1", signal.vehicleSignalName)
        assert.is_nil(signal.pedestrianSignalName)
        assert.equals(TrafficLight.Use.VEHICLE_ONLY, signal.use)
    end)

    it("adds a pedestrian signal name with chainable withPedestrian", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local signal = TrafficLight:new("K1", -1, TrafficLightModel.NONE)
        local returned = signal:withPedestrian("F1")

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

        local signal = TrafficLight:new("K1", -1, TrafficLightModel.NONE):withPedestrian("F1")
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

        local signal = TrafficLight:new("K1", -1, TrafficLightModel.NONE):withPedestrian("F1")
        signal.currentIndication = SignalIndication.OFF

        assert.equals("<fgrgb=128,128,128><b>K1</b><fgrgb=0,0,0>", signal:vehicleSignalNameTippText())
        assert.equals("<fgrgb=128,128,128><b>F1</b><fgrgb=0,0,0>", signal:pedestrianSignalNameTippText())
    end)
end)
