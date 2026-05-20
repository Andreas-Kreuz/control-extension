insulate("ce.mods.road.PedestrianCrossing", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.mods.road.PedestrianCrossing")
        clearModule("ce.mods.road.SignalGroup")
        clearModule("ce.mods.road.TrafficLight")
    end)

    it("stores identity and approach", function ()
        local PedestrianCrossing = require("ce.mods.road.PedestrianCrossing")

        local crossing = PedestrianCrossing:new("Furt Nord")
            :setScriptVariableName("c1PedCrossingNorth1")
            :setApproach(PedestrianCrossing.Approach.NORTH)

        assert.equals("PedestrianCrossing", crossing:getType())
        assert.equals("Furt Nord", crossing:getName())
        assert.equals("c1PedCrossingNorth1", crossing:getScriptVariableName())
        assert.equals(PedestrianCrossing.Approach.NORTH, crossing:getApproach())
        assert.equals(PedestrianCrossing.Heading.SOUTH, crossing:getHeading())
    end)

    it("keeps scriptVariableName as compatibility alias", function ()
        local PedestrianCrossing = require("ce.mods.road.PedestrianCrossing")
        local crossing = PedestrianCrossing:new("Furt Nord")

        assert.equals(crossing, crossing:scriptVariableName("c1PedCrossingNorth1"))
        assert.equals("c1PedCrossingNorth1", crossing:getScriptVariableName())
    end)
    it("maps legacy heading to opposite approach", function ()
        local PedestrianCrossing = require("ce.mods.road.PedestrianCrossing")

        local crossing = PedestrianCrossing:new("Furt Nord")
            :setHeading(PedestrianCrossing.Heading.NORTH)

        assert.equals(PedestrianCrossing.Approach.SOUTH, crossing:getApproach())
        assert.equals(PedestrianCrossing.Heading.NORTH, crossing:getHeading())
    end)

    it("rejects invalid approaches", function ()
        local PedestrianCrossing = require("ce.mods.road.PedestrianCrossing")
        local printStub = stub(_G, "print")
        local crossing = PedestrianCrossing:new("Furt Nord")

        crossing:setApproach("UP")

        assert.equals(PedestrianCrossing.Approach.SOUTH, crossing:getApproach())
        assert.stub(printStub).was_called_with("[#PedestrianCrossing] No such approach: UP")
        printStub:revert()
    end)

    it("can be assigned to a signal group without owning signals", function ()
        local PedestrianCrossing = require("ce.mods.road.PedestrianCrossing")
        local SignalGroup = require("ce.mods.road.SignalGroup")
        local TrafficLight = require("ce.mods.road.TrafficLight")
        local TrafficLightModel = require("ce.mods.road.TrafficLightModel")

        local F1 = TrafficLight:newForSignal("F1", -1, TrafficLightModel.NONE):asPedestrianOnly()
        local crossing = PedestrianCrossing:new("Furt Nord")
        local signalGroup = SignalGroup:new("sgPedNorth")
            :addPedestrianCrossings(crossing)
            :addPedestrianSignals(F1)

        assert.equals(crossing, signalGroup:getPedestrianCrossings()[1])
        assert.equals(SignalGroup.Type.PEDESTRIAN, signalGroup:getSignalHeads()[F1])
    end)
end)
