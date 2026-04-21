insulate("ce.mods.transit.data.TransitTrainDtoFactory", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.mods.transit.data.TransitTrainDtoFactory")
    end)

    it("creates full transit train DTOs", function ()
        local TransitTrainDtoFactory = require("ce.mods.transit.data.TransitTrainDtoFactory")

        local ceType, keyId, key, dto = TransitTrainDtoFactory.createFullDto({
            id = "T1",
            getLine = function () return "10" end,
            getDestination = function () return "Central" end,
            getDirection = function () return "North" end,
            getNextStations = function ()
                return {
                    {
                        station = { name = "Central", type = "RoadStation" },
                        platform = "2",
                        departureInMinutes = 3
                    }
                }
            end,
        }, true)

        assert.equals("ce.mods.transit.TransitTrain", ceType)
        assert.equals("id", keyId)
        assert.equals("T1", key)
        assert.same({
                        ceType = "ce.mods.transit.TransitTrain",
                        id = "T1",
                        line = "10",
                        destination = "Central",
                        direction = "North",
                        nextStations = {
                            {
                                station = { name = "Central", platform = "2" },
                                departureInMinutes = 3
                            }
                        }
                    }, dto)
    end)

    it("uses empty next stations for unselected full transit train DTOs", function ()
        local TransitTrainDtoFactory = require("ce.mods.transit.data.TransitTrainDtoFactory")

        local _, _, _, dto = TransitTrainDtoFactory.createFullDto({
            id = "T1",
            getLine = function () return "10" end,
            getDestination = function () return "Central" end,
            getDirection = function () return "North" end,
            getNextStations = function ()
                return {
                    {
                        station = { name = "Central", type = "RoadStation" },
                        platform = "2",
                        departureInMinutes = 3
                    }
                }
            end,
        }, false)

        assert.same({}, dto.nextStations)
    end)

    it("creates patch transit train DTOs", function ()
        local TransitTrainDtoFactory = require("ce.mods.transit.data.TransitTrainDtoFactory")

        local _, _, _, dto = TransitTrainDtoFactory.createPatchDto({
            id = "T1",
            getLine = function () return "10" end,
            getDestination = function () return "Central" end,
            getDirection = function () return "North" end,
        }, { destination = true }, true)

        assert.same({
                        ceType = "ce.mods.transit.TransitTrain",
                        id = "T1",
                        destination = "Central"
                    }, dto)
    end)

    it("creates selected next station patch DTOs", function ()
        local TransitTrainDtoFactory = require("ce.mods.transit.data.TransitTrainDtoFactory")

        local _, _, _, dto = TransitTrainDtoFactory.createPatchDto({
            id = "T1",
            getNextStations = function ()
                return {
                    {
                        station = { name = "Central", type = "RoadStation" },
                        platform = "2",
                        departureInMinutes = 3
                    }
                }
            end,
        }, { nextStations = true }, true)

        assert.same({
                        ceType = "ce.mods.transit.TransitTrain",
                        id = "T1",
                        nextStations = {
                            {
                                station = { name = "Central", platform = "2" },
                                departureInMinutes = 3
                            }
                        }
                    }, dto)
    end)

    it("omits next station patch DTOs when unselected", function ()
        local TransitTrainDtoFactory = require("ce.mods.transit.data.TransitTrainDtoFactory")

        local _, _, _, dto = TransitTrainDtoFactory.createPatchDto({
            id = "T1",
            getNextStations = function ()
                return {
                    {
                        station = { name = "Central", type = "RoadStation" },
                        platform = "2",
                        departureInMinutes = 3
                    }
                }
            end,
        }, { nextStations = true }, false)

        assert.same({
                        ceType = "ce.mods.transit.TransitTrain",
                        id = "T1"
                    }, dto)
    end)
end)
