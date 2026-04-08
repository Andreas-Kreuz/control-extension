describe("ce.hub.data.trains.Train", function ()
    local EepSimulator = require("ce.hub.eep.EepSimulator")
    EepSimulator.simulateAddTrain("#EepTrain1", "RollingStock 1", "RollingStock 2")

    insulate("new Train keeps generic tag values", function ()
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

        local tram = TrainRegistry.forName("#EepTrain1");

        it("Train has right name", function () assert.equals("#EepTrain1", tram.name) end)
        it("Values table exists", function () assert.same({}, tram.values) end)
    end)
end)

describe("ce.hub.data.trains.Train", function ()
    local EepSimulator = require("ce.hub.eep.EepSimulator")
    EepSimulator.simulateAddTrain("#EepTrain1", "RollingStock 1", "RollingStock 2")

    insulate("Generic train tag values can be set", function ()
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

        local tram = TrainRegistry.forName("#EepTrain1");
        tram:setValue("x", "DEST")

        it("Stored generic value is readable", function () assert.equals("DEST", tram:getValue("x")) end)
    end)
end)
