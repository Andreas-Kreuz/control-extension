insulate("ce.hub.data.time.TimeStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local originalEEPTime = _G.EEPTime
    local originalEEPTimeH = _G.EEPTimeH
    local originalEEPTimeM = _G.EEPTimeM
    local originalEEPTimeS = _G.EEPTimeS
    local originalEEPGetTimeLapse = _G.EEPGetTimeLapse

    before_each(function ()
        clearModule("ce.hub.data.time.TimeStatePublisher")
        clearModule("ce.hub.data.time.TimeDtoFactory")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.hub.publish.DataChangeBus")

        _G.EEPTime = 3723
        _G.EEPTimeH = 1
        _G.EEPTimeM = 2
        _G.EEPTimeS = 3
        _G.EEPGetTimeLapse = function () return 4 end
    end)

    after_each(function ()
        _G.EEPTime = originalEEPTime
        _G.EEPTimeH = originalEEPTimeH
        _G.EEPTimeM = originalEEPTimeM
        _G.EEPTimeS = originalEEPTimeS
        _G.EEPGetTimeLapse = originalEEPGetTimeLapse
    end)

    it("fires time ceTypes with the existing wire format", function ()
        local TimeStatePublisher = require("ce.hub.data.time.TimeStatePublisher")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        TimeStatePublisher.initialize()
        TimeStatePublisher.syncState()

        assert.same({
                        times = {
                            ceType = "ce.hub.Time",
                            id = "times",
                            name = "times",
                            timeComplete = 3723,
                            timeLapse = 4,
                            timeH = 1,
                            timeM = 2,
                            timeS = 3
                        }
                    }, DataStore.getCeType("ce.hub.Time"))
    end)
end)
