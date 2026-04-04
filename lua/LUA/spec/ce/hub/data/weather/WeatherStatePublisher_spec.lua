insulate("ce.hub.data.weather.WeatherStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.weather.WeatherStatePublisher")
        clearModule("ce.hub.data.weather.WeatherDtoFactory")
        clearModule("ce.hub.publish.InternalDataStore")
        clearModule("ce.databridge.ServerEventBuffer")
        clearModule("ce.hub.publish.DataChangeBus")

        rawset(_G, "EEPGetSeason", function () return 2 end)
        rawset(_G, "EEPGetCloudsIntensity", function () return true, 30 end)
        rawset(_G, "EEPGetCloudsMode", function () return 1 end)
        rawset(_G, "EEPGetWindIntensity", function () return true, 40 end)
        rawset(_G, "EEPGetRainIntensity", function () return true, 50 end)
        rawset(_G, "EEPGetSnowIntensity", function () return true, 60 end)
        rawset(_G, "EEPGetHailIntensity", function () return true, 70 end)
        rawset(_G, "EEPGetFogIntensity", function () return true, 80 end)
    end)

    after_each(function ()
        rawset(_G, "EEPGetSeason", nil)
        rawset(_G, "EEPGetCloudsIntensity", nil)
        rawset(_G, "EEPGetCloudsMode", nil)
        rawset(_G, "EEPGetWindIntensity", nil)
        rawset(_G, "EEPGetRainIntensity", nil)
        rawset(_G, "EEPGetSnowIntensity", nil)
        rawset(_G, "EEPGetHailIntensity", nil)
        rawset(_G, "EEPGetFogIntensity", nil)
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
