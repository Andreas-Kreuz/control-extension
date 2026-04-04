insulate("ce.hub.data.tracks.TrackDetection", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local states

    before_each(function ()
        clearModule("ce.hub.data.tracks.TrackDetection")
        clearModule("ce.hub.data.tracks.TrackDtoFactory")
        clearModule("ce.hub.publish.DataChangeBus")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")

        states = {
            [1] = { exists = true, reserved = false, trainName = nil },
            [2] = { exists = true, reserved = false, trainName = nil }
        }

        stub(_G, "EEPRegisterRailTrack", function (id)
            local entry = states[id]
            return entry and entry.exists == true or false
        end)
        stub(_G, "EEPIsRailTrackReserved", function (id, _withTrainName)
            local entry = states[id]
            if not entry or entry.exists ~= true then return false, false, nil end
            return true, entry.reserved, entry.trainName
        end)
    end)

    after_each(function ()
        _G.EEPRegisterRailTrack:revert()
        _G.EEPIsRailTrackReserved:revert()
    end)

    it("keeps all track entries when only one track changes", function ()
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InternalDataStore = require("ce.hub.publish.InternalDataStore")
        local TrackDetection = require("ce.hub.data.tracks.TrackDetection")

        local detection = TrackDetection:new("rail")
        detection:initialize({ [HubCeTypes.RailTrack] = true })

        assert.is_not_nil(InternalDataStore.get("ce.hub.RailTrack", "1"))
        assert.is_not_nil(InternalDataStore.get("ce.hub.RailTrack", "2"))

        states[1].reserved = true
        states[1].trainName = "T1"
        detection:findTrainsOnTrack({ [HubCeTypes.RailTrack] = true })

        assert.is_true(InternalDataStore.get("ce.hub.RailTrack", "1").reserved)
        assert.equals("T1", InternalDataStore.get("ce.hub.RailTrack", "1").reservedByTrainName)
        assert.is_not_nil(InternalDataStore.get("ce.hub.RailTrack", "2"))
    end)
end)
