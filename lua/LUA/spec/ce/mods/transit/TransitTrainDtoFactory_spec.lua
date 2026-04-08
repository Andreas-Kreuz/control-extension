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
        })

        assert.equals("ce.mods.transit.TransitTrain", ceType)
        assert.equals("id", keyId)
        assert.equals("T1", key)
        assert.same({
                        ceType = "ce.mods.transit.TransitTrain",
                        id = "T1",
                        line = "10",
                        destination = "Central",
                        direction = "North"
                    }, dto)
    end)

    it("creates patch transit train DTOs", function ()
        local TransitTrainDtoFactory = require("ce.mods.transit.data.TransitTrainDtoFactory")

        local _, _, _, dto = TransitTrainDtoFactory.createPatchDto({
            id = "T1",
            getLine = function () return "10" end,
            getDestination = function () return "Central" end,
            getDirection = function () return "North" end,
        }, { destination = true })

        assert.same({
                        ceType = "ce.mods.transit.TransitTrain",
                        id = "T1",
                        destination = "Central"
                    }, dto)
    end)
end)
