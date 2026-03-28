insulate("ce.hub.data.tracks.TrackDtoFactory", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.tracks.TrackDtoFactory")
    end)

    it("provides ceType metadata for track DTOs", function ()
        local TrackDtoFactory = require("ce.hub.data.tracks.TrackDtoFactory")

        local room, keyId, key, trackDto = TrackDtoFactory.createTrackDto("rail", { id = 5, name = "ignored" })
        local listRoom, listKeyId, trackDtos =
            TrackDtoFactory.createTrackDtoList("rail", { ["5"] = { id = 5, name = "ignored" } })

        assert.equals("ce.hub.RailTrack", room)
        assert.equals("id", keyId)
        assert.equals(5, key)
        assert.same({ ceType = "ce.hub.RailTrack", id = 5 }, trackDto)
        assert.equals("ce.hub.RailTrack", listRoom)
        assert.equals("id", listKeyId)
        assert.same({ ["5"] = { ceType = "ce.hub.RailTrack", id = 5 } }, trackDtos)
    end)
end)
