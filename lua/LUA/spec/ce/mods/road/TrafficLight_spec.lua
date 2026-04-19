insulate("ce.mods.road.TrafficLight", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.mods.road.TrafficLight")
    end)

    it("stores the constructor name as traffic signal name", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local trafficLight = TrafficLight:new("K1", -1, TrafficLightModel.NONE)

        assert.equals("K1", trafficLight.trafficSignalName)
        assert.is_nil(trafficLight.pedestrianSignalName)
        assert.equals(TrafficLight.Use.TRAFFIC_ONLY, trafficLight.use)
    end)

    it("adds a pedestrian signal name with chainable withPedestrian", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local trafficLight = TrafficLight:new("K1", -1, TrafficLightModel.NONE)
        local returned = trafficLight:withPedestrian("F1")

        assert.equals(trafficLight, returned)
        assert.equals("K1", trafficLight.trafficSignalName)
        assert.equals("F1", trafficLight.pedestrianSignalName)
        assert.equals(TrafficLight.Use.TRAFFIC_AND_PEDESTRIAN, trafficLight.use)
    end)

    it("creates pedestrian only lights", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local trafficLight = TrafficLight:newPedestrianOnly("F1", -1, TrafficLightModel.NONE)

        assert.is_nil(trafficLight.trafficSignalName)
        assert.equals("F1", trafficLight.pedestrianSignalName)
        assert.equals(TrafficLight.Use.PEDESTRIAN_ONLY, trafficLight.use)
    end)

    it("moves the constructor name when marked as pedestrian only", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local trafficLight = TrafficLight:new("F1", -1, TrafficLightModel.NONE)
        local returned = trafficLight:asPedestrianOnly()

        assert.equals(trafficLight, returned)
        assert.is_nil(trafficLight.trafficSignalName)
        assert.equals("F1", trafficLight.pedestrianSignalName)
        assert.equals(TrafficLight.Use.PEDESTRIAN_ONLY, trafficLight.use)
    end)

    it("renders combined signal names with role specific colors", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local TrafficLightState = require("ce.mods.road.TrafficLightState")

        local trafficLight = TrafficLight:new("K1", -1, TrafficLightModel.NONE):withPedestrian("F1")
        trafficLight.phase = TrafficLightState.PEDESTRIAN

        assert.equals(
            "<bgrgb=255,96,96><b>K1</b><bgrgb=255,255,255><br>" ..
            "<bgrgb=0,128,0><fgrgb=255,255,255><b>F1</b><bgrgb=255,255,255><fgrgb=0,0,0>",
            trafficLight:signalNamesTippText())
    end)

    it("renders off signal names as grey text without background", function ()
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local TrafficLightState = require("ce.mods.road.TrafficLightState")

        local trafficLight = TrafficLight:new("K1", -1, TrafficLightModel.NONE):withPedestrian("F1")
        trafficLight.phase = TrafficLightState.OFF

        assert.equals("<fgrgb=128,128,128><b>K1</b><fgrgb=0,0,0>", trafficLight:trafficSignalNameTippText())
        assert.equals("<fgrgb=128,128,128><b>F1</b><fgrgb=0,0,0>", trafficLight:pedestrianSignalNameTippText())
    end)
end)
