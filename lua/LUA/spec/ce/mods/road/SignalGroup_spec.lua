insulate("ce.mods.road.SignalGroup", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.mods.road.SignalGroup")
        clearModule("ce.mods.road.TrafficLight")
        clearModule("ce.mods.road.TrafficPhase")
    end)

    it("adds every signal head from a group to a traffic phase", function ()
        local SignalGroup = require("ce.mods.road.SignalGroup")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local TrafficPhase = require("ce.mods.road.TrafficPhase")

        local K1 = TrafficLight:new("K1", -1, TrafficLightModel.NONE)
        local K2 = TrafficLight:new("K2", -1, TrafficLightModel.NONE)
        local sg = SignalGroup:new("sgLane1Straight"):addVehicleSignals(K1, K2)
        local phase = TrafficPhase:new("P1"):addSignalGroup(sg)
        local _, green = phase:signalHeadsToTurnRedAndGreen()

        assert.equals(TrafficPhase.Type.CAR, green[K1])
        assert.equals(TrafficPhase.Type.CAR, green[K2])
    end)

    it("asserts duplicate logical signal-group membership", function ()
        local SignalGroup = require("ce.mods.road.SignalGroup")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local K1 = TrafficLight:new("K1", -1, TrafficLightModel.NONE)
        SignalGroup:new("sgA"):addVehicleSignals(K1)

        assert.has_error(function ()
            SignalGroup:new("sgB"):addVehicleSignals(K1)
        end, "Signal logical use already belongs to signal group: K1")
    end)

    it("asserts a vehicle and pedestrian release on the same physical signal in one phase", function ()
        local SignalGroup = require("ce.mods.road.SignalGroup")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")
        local TrafficPhase = require("ce.mods.road.TrafficPhase")

        local K1 = TrafficLight:new("K1", -1, TrafficLightModel.NONE):withPedestrian("F1")
        local sgVehicle = SignalGroup:new("sgLane1Straight"):addVehicleSignals(K1)
        local sgPedestrian = SignalGroup:new("sgPedNorthSouth"):addPedestrianSignals(K1)

        assert.has_error(function ()
            TrafficPhase:new("P1"):addSignalGroup(sgVehicle, sgPedestrian)
        end, "Ein Signal darf in derselben Phase nicht gleichzeitig Fahrzeug- und Fu\223g\228ngerverkehr freigeben.")
    end)

    it("asserts that multi-group lane control uses an independent lane signal", function ()
        local Lane = require("ce.mods.road.Lane")
        local SignalGroup = require("ce.mods.road.SignalGroup")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local K1 = TrafficLight:new("K1", -1, TrafficLightModel.NONE)
        local K2 = TrafficLight:new("K2", -1, TrafficLightModel.NONE)
        local lane = Lane:new("Lane 1", -1, K1)
        local sgA = SignalGroup:new("sgLane1Straight"):addVehicleSignals(K1)
        local sgB = SignalGroup:new("sgLane1Right"):addVehicleSignals(K2)

        local expectedError = "Wenn eine Fahrspur durch mehrere Signalgruppen gesteuert wird, " ..
            "ben\246tigt sie eine unabh\228ngige Ampel - verwende eine eigene unsichtbare Ampel."
        assert.has_error(function ()
            lane:driveOnDefaultSignalGroups(sgA, sgB)
        end, expectedError)
    end)
end)
