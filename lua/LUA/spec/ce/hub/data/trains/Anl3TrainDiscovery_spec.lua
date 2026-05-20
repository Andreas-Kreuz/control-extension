insulate("ce.hub.data.trains.TrainDiscovery anl3 seed", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local stubs = {}
    local originalEEPLoadData

    local function addStub(name, fn)
        stubs[#stubs + 1] = stub(_G, name, fn)
    end

    before_each(function ()
        originalEEPLoadData = _G.EEPLoadData
        rawset(_G, "EEPLoadData", _G.EEPLoadData or function () return false, nil end)

        clearModule("ce.hub.data.trains.TrainDiscovery")
        clearModule("ce.hub.data.trains.TrainRegistry")
        clearModule("ce.hub.data.trains.Train")
        clearModule("ce.hub.data.trains.TrainDiscoveryCache")
        clearModule("ce.hub.data.tracks.TrackRegistry")
        clearModule("ce.hub.data.tracks.Track")
        clearModule("ce.hub.data.rollingstock.RollingStockRegistry")
        clearModule("ce.hub.data.rollingstock.RollingStock")
        clearModule("ce.hub.options.HubOptionsRegistry")

        stubs = {}
    end)

    after_each(function ()
        for _, currentStub in ipairs(stubs) do currentStub:revert() end
        rawset(_G, "EEPLoadData", originalEEPLoadData)
        stubs = {}
    end)

    it("seeds trains and updates only parsed tracks without registration scan", function ()
        local registerCalls = 0
        local railReservedCalls = 0

        addStub("EEPRegisterRailTrack", function ()
            registerCalls = registerCalls + 1
            return false
        end)
        addStub("EEPRegisterRoadTrack", function ()
            registerCalls = registerCalls + 1
            return false
        end)
        addStub("EEPRegisterTramTrack", function ()
            registerCalls = registerCalls + 1
            return false
        end)
        addStub("EEPRegisterAuxiliaryTrack", function ()
            registerCalls = registerCalls + 1
            return false
        end)
        addStub("EEPRegisterControlTrack", function ()
            registerCalls = registerCalls + 1
            return false
        end)
        addStub("EEPIsRailTrackReserved", function (trackId)
            railReservedCalls = railReservedCalls + 1
            return true, trackId == 101, trackId == 101 and "#Train A" or nil
        end)
        addStub("EEPIsRoadTrackReserved", function () return false, false, nil end)
        addStub("EEPIsTramTrackReserved", function () return false, false, nil end)
        addStub("EEPIsAuxiliaryTrackReserved", function () return false, false, nil end)
        addStub("EEPIsControlTrackReserved", function () return false, false, nil end)
        addStub("EEPGetTrainSpeed", function () return true, 0 end)
        addStub("EEPRollingstockGetTrack", function () return true, 101, 12, 1, 1 end)

        local TrainDiscovery = require("ce.hub.data.trains.TrainDiscovery")
        local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")
        local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
        local TrackRegistry = require("ce.hub.data.tracks.TrackRegistry")

        TrainDiscovery.initFromAnl3({
            coverage = { tracks = true, trains = true, rollingStocks = true },
            tracks = {
                rail = { { id = 101, reserved = false } },
                road = {},
                tram = {},
                auxiliary = {},
                control = {}
            },
            trains = {
                { name = "#Train A", rollingStockCount = 1, trackType = "rail", onTracks = { ["101"] = 101 } }
            },
            rollingStocks = {
                {
                    name = "RS A",
                    model = "ROLLING\\A.3dm",
                    trainName = "#Train A",
                    positionInTrain = 0,
                    trackType = "rail",
                    trackId = 101,
                    trackDistance = 12,
                    trackDirection = 1,
                    trackSystem = 1
                }
            }
        })
        TrainDiscovery.runInitialDiscovery({ skipTrackInitialization = true, keepCache = true })
        TrainDiscovery.runDiscovery()

        assert.equals(0, registerCalls)
        assert.equals(1, railReservedCalls)
        assert.is_not_nil(TrainRegistry.getAll()["#Train A"])
        assert.equals("RS A", TrainRegistry.rollingStockNameInTrain("#Train A", 0))
        assert.is_not_nil(RollingStockRegistry.getAll()["RS A"])
        assert.is_true(TrackRegistry.get("rail", 101).reserved)
        assert.equals("#Train A", TrackRegistry.get("rail", 101).reservedByTrainName)
    end)
end)
