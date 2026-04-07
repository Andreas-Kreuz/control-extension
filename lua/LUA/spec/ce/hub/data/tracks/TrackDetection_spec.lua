insulate("ce.hub.data.tracks.TrackPublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.tracks.TrackPublisher")
        clearModule("ce.hub.data.tracks.TrackRegistry")
        clearModule("ce.hub.data.tracks.TrackDtoFactory")
        clearModule("ce.hub.publish.DataChangeBus")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
    end)

    it("keeps all track entries when only one track changes", function ()
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local TrackPublisher = require("ce.hub.data.tracks.TrackPublisher")
        local TrackRegistry = require("ce.hub.data.tracks.TrackRegistry")

        TrackRegistry.add("rail", { id = 1, reserved = false, reservedByTrainName = nil })
        TrackRegistry.add("rail", { id = 2, reserved = false, reservedByTrainName = nil })
        TrackRegistry.markInitialListPending("rail")
        TrackPublisher.syncState({
            ceTypes = {
                railTrack = { ceType = HubCeTypes.RailTrack, mode = "all" }
            }
        })

        assert.is_not_nil(InternalDataStore.get("ce.hub.RailTrack", "1"))
        assert.is_not_nil(InternalDataStore.get("ce.hub.RailTrack", "2"))

        local track = TrackRegistry.get("rail", 1)
        track.reserved = true
        track.reservedByTrainName = "T1"
        TrackRegistry.markChanged("rail", 1)
        TrackPublisher.syncState({
            ceTypes = {
                railTrack = { ceType = HubCeTypes.RailTrack, mode = "all" }
            }
        })

        assert.is_true(InternalDataStore.get("ce.hub.RailTrack", "1").reserved)
        assert.equals("T1", InternalDataStore.get("ce.hub.RailTrack", "1").reservedByTrainName)
        assert.is_not_nil(InternalDataStore.get("ce.hub.RailTrack", "2"))
    end)
end)
