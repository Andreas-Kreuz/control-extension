insulate("ce.hub.data.time.TimeDtoFactory", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.time.TimeDtoFactory")
    end)

    it("projects times to detached DTO tables", function ()
        local TimeDtoFactory = require("ce.hub.data.time.TimeDtoFactory")
        local timeData = {
            id = "time",
            name = "time",
            timeComplete = 3723,
            timeH = 1,
            timeM = 2,
            timeS = 3
        }

        local room, keyId, key, timeDto = TimeDtoFactory.createTimeDto(timeData)
        local listRoom, listKeyId, timeDtos = TimeDtoFactory.createTimeDtoList({ timeData })
        timeData.timeS = 9

        assert.equals("ce.hub.Time", room)
        assert.equals("id", keyId)
        assert.equals("time", key)
        assert.same({
                        ceType = "ce.hub.Time",
                        id = "time",
                        name = "time",
                        timeComplete = 3723,
                        timeH = 1,
                        timeM = 2,
                        timeS = 3
                    }, timeDto)
        assert.equals("ce.hub.Time", listRoom)
        assert.equals("id", listKeyId)
        assert.same({ {
                        ceType = "ce.hub.Time",
                        id = "time",
                        name = "time",
                        timeComplete = 3723,
                        timeH = 1,
                        timeM = 2,
                        timeS = 3
                    } }, timeDtos)
    end)
end)
