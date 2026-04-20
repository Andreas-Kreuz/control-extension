insulate("ce.mods.transit.data.TransitTrain", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.mods.transit.data.TransitTrain")
    end)

    local function newTransitTrain()
        local TransitTrain = require("ce.mods.transit.data.TransitTrain")
        return TransitTrain:new({ id = "T1", type = "Train" })
    end

    it("starts with an empty next station list", function ()
        local transitTrain = newTransitTrain()

        assert.same({}, transitTrain:getNextStations())
    end)

    it("does not mark equivalent next stations dirty again", function ()
        local RoadStation = require("ce.mods.transit.RoadStation")
        local transitTrain = newTransitTrain()
        local station = RoadStation.forName("Central")
        local nextStations = {
            { station = station, platform = "2", departureInMinutes = 3 }
        }

        transitTrain:setNextStations(nextStations)
        assert.is_true(transitTrain.dirtyFields.nextStations)

        transitTrain:resetDirty()
        transitTrain:setNextStations(nextStations)

        assert.is_nil(transitTrain.dirtyFields.nextStations)
    end)

    it("keeps at most five next stations", function ()
        local RoadStation = require("ce.mods.transit.RoadStation")
        local transitTrain = newTransitTrain()
        local nextStations = {}
        for index = 1, 6 do
            table.insert(nextStations, {
                station = RoadStation.forName("Station " .. index),
                platform = tostring(index),
                departureInMinutes = index
            })
        end

        transitTrain:setNextStations(nextStations)

        local storedNextStations = transitTrain:getNextStations()
        assert.are.equal(5, #storedNextStations)
        assert.are.equal("Station 5", storedNextStations[5].station.name)
    end)
end)
