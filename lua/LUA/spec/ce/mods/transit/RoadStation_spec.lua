insulate("ce.mods.transit.RoadStation", function ()
    it("does not update displays when a departure removes no queue entry", function ()
        require("ce.hub.eep.EepSimulator")
        local RoadStation = require("ce.mods.transit.RoadStation")
        local station = RoadStation:new("Idempotent Departure", -1)
        local updateCalls = 0
        station.updateDisplays = function () updateCalls = updateCalls + 1 end

        station.queue:push("Train 1", "Central", "10", 0, "1")

        station:trainLeft("Train 1", "Central", "10")
        station:trainLeft("Train 1", "Central", "10")

        assert.equals(1, updateCalls)
    end)
end)
