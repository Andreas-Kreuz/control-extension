insulate("ce.mods.transit.data.TransitTrain", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.eep.EepSimulatorStore")
        require("ce.hub.eep.EepSimulator")
        clearModule("ce.hub.data.rollingstock.RollingStock")
        clearModule("ce.hub.data.rollingstock.RollingStockRegistry")
        clearModule("ce.mods.transit.data.TransitTrain")
    end)

    local function newTransitTrain()
        local TransitTrain = require("ce.mods.transit.data.TransitTrain")
        local hubTrain = { id = "T1", type = "Train" }
        ---@cast hubTrain Train
        return TransitTrain:new(hubTrain)
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

    it("sets origin on each rolling stock model", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
        local transitTrain = newTransitTrain()
        local calls = {}
        local model = {
            setOrigin = function (_, rollingStockName, origin)
                table.insert(calls, { rollingStockName = rollingStockName, origin = origin })
            end
        }
        EepSimulator.simulateAddTrain("T1", "RS1", "RS2")
        RollingStockRegistry.forName("RS1").model = model
        RollingStockRegistry.forName("RS2").model = model

        transitTrain:setOrigin("Depot")

        assert.equals("Depot", transitTrain:getOrigin())
        assert.is_true(transitTrain.dirtyFields.origin)
        assert.same({
                        { rollingStockName = "RS1", origin = "Depot" },
                        { rollingStockName = "RS2", origin = "Depot" },
                    }, calls)
    end)

    it("sets first next station as next stop on each rolling stock model", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local RoadStation = require("ce.mods.transit.RoadStation")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
        local transitTrain = newTransitTrain()
        local calls = {}
        local model = {
            setNextStop = function (_, rollingStockName, nextStop)
                table.insert(calls, { rollingStockName = rollingStockName, nextStop = nextStop })
            end
        }
        EepSimulator.simulateAddTrain("T1", "RS1", "RS2")
        RollingStockRegistry.forName("RS1").model = model
        RollingStockRegistry.forName("RS2").model = model

        transitTrain:setNextStations({
            { station = RoadStation.forName("Central"), platform = "2", departureInMinutes = 3 },
            { station = RoadStation.forName("Market"),  platform = "1", departureInMinutes = 5 },
        })

        assert.same({
                        { rollingStockName = "RS1", nextStop = "Central" },
                        { rollingStockName = "RS2", nextStop = "Central" },
                    }, calls)
    end)

    it("clears next stop on each rolling stock model without next stations", function ()
        local EepSimulator = require("ce.hub.eep.EepSimulator")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
        local transitTrain = newTransitTrain()
        local calls = {}
        local model = {
            setNextStop = function (_, rollingStockName, nextStop)
                table.insert(calls, { rollingStockName = rollingStockName, nextStop = nextStop })
            end
        }
        EepSimulator.simulateAddTrain("T1", "RS1", "RS2")
        RollingStockRegistry.forName("RS1").model = model
        RollingStockRegistry.forName("RS2").model = model

        transitTrain:setNextStations(nil)

        assert.same({
                        { rollingStockName = "RS1", nextStop = "" },
                        { rollingStockName = "RS2", nextStop = "" },
                    }, calls)
    end)
end)
