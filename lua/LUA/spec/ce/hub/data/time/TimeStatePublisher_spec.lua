insulate("ce.hub.data.time.TimeStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local originalEEPTime = _G.EEPTime
    local originalEEPTimeH = _G.EEPTimeH
    local originalEEPTimeM = _G.EEPTimeM
    local originalEEPTimeS = _G.EEPTimeS

    before_each(function ()
        clearModule("ce.hub.data.time.TimeStatePublisher")
        clearModule("ce.hub.data.time.TimeDtoFactory")
        clearModule("ce.hub.data.time.TimePublisher")
        clearModule("ce.hub.data.time.TimeRegistry")
        clearModule("ce.hub.data.time.TimeUpdater")
        clearModule("ce.hub.data.InterestSyncRegistry")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.hub.publish.DataChangeBus")

        rawset(_G, "EEPTime", 3723)
        rawset(_G, "EEPTimeH", 1)
        rawset(_G, "EEPTimeM", 2)
        rawset(_G, "EEPTimeS", 3)
    end)

    after_each(function ()
        rawset(_G, "EEPTime", originalEEPTime)
        rawset(_G, "EEPTimeH", originalEEPTimeH)
        rawset(_G, "EEPTimeM", originalEEPTimeM)
        rawset(_G, "EEPTimeS", originalEEPTimeS)
    end)

    it("keeps time details behind interest", function ()
        local TimeStatePublisher = require("ce.hub.data.time.TimeStatePublisher")
        local TimeUpdater = require("ce.hub.data.time.TimeUpdater")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        TimeUpdater.runUpdate()
        TimeStatePublisher.syncState()

        assert.same({
                        times = {
                            ceType = "ce.hub.Time",
                            id = "times",
                            name = "",
                            timeComplete = 0,
                            timeH = 0,
                            timeM = 0,
                            timeS = 0
                        }
                    }, DataStore.getCeType("ce.hub.Time"))
    end)

    it("fires real time values for selected entries", function ()
        local HubCeTypes = require("ce.hub.data.HubCeTypes")
        local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
        local TimeStatePublisher = require("ce.hub.data.time.TimeStatePublisher")
        local TimeUpdater = require("ce.hub.data.time.TimeUpdater")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        InterestSyncRegistry.startSyncFor(HubCeTypes.Time, "times")
        TimeUpdater.runUpdate()
        TimeStatePublisher.syncState()

        assert.same({
                        times = {
                            ceType = "ce.hub.Time",
                            id = "times",
                            name = "times",
                            timeComplete = 3723,
                            timeH = 1,
                            timeM = 2,
                            timeS = 3
                        }
                    }, DataStore.getCeType("ce.hub.Time"))
    end)
end)
