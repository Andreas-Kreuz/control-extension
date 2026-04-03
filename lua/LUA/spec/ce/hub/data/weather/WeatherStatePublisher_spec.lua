insulate("ce.hub.data.weather.WeatherStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    local originals = {}

    before_each(function ()
        clearModule("ce.hub.data.weather.WeatherStatePublisher")
        clearModule("ce.hub.data.weather.WeatherDtoFactory")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.hub.publish.DataChangeBus")

        originals.EEPGetSeason = _G.EEPGetSeason
        originals.EEPGetCloudsIntensity = _G.EEPGetCloudsIntensity
        originals.EEPGetCloudsMode = _G.EEPGetCloudsMode
        originals.EEPGetWindIntensity = _G.EEPGetWindIntensity
        originals.EEPGetRainIntensity = _G.EEPGetRainIntensity
        originals.EEPGetSnowIntensity = _G.EEPGetSnowIntensity
        originals.EEPGetHailIntensity = _G.EEPGetHailIntensity
        originals.EEPGetFogIntensity = _G.EEPGetFogIntensity

        _G.EEPGetSeason = function () return 2 end
        _G.EEPGetCloudsIntensity = function () return true, 30 end
        _G.EEPGetCloudsMode = function () return 1 end
        _G.EEPGetWindIntensity = function () return true, 40 end
        _G.EEPGetRainIntensity = function () return true, 50 end
        _G.EEPGetSnowIntensity = function () return true, 60 end
        _G.EEPGetHailIntensity = function () return true, 70 end
        _G.EEPGetFogIntensity = function () return true, 80 end
    end)

    after_each(function ()
        for key, value in pairs(originals) do rawset(_G, key, value) end
    end)

    it("publishes global weather data as ce.hub.Weather", function ()
        local WeatherStatePublisher = require("ce.hub.data.weather.WeatherStatePublisher")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        WeatherStatePublisher.initialize()
        WeatherStatePublisher.syncState()

        assert.same({
                        weather = {
                            ceType = "ce.hub.Weather",
                            id = "weather",
                            name = "weather",
                            season = 2,
                            cloudsIntensity = 30,
                            cloudsMode = 1,
                            windIntensity = 40,
                            rainIntensity = 50,
                            snowIntensity = 60,
                            hailIntensity = 70,
                            fogIntensity = 80
                        }
                    }, DataStore.getCeType("ce.hub.Weather"))
    end)
end)
