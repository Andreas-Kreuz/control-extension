insulate("ce.hub.data.weather.WeatherStatePublisher", function ()
    local function clearModule(name) package.loaded[name] = nil end
    local originalEEPGetSeason = _G.EEPGetSeason
    local originalEEPGetCloudsIntensity = _G.EEPGetCloudsIntensity
    local originalEEPGetCloudsMode = _G.EEPGetCloudsMode
    local originalEEPGetWindIntensity = _G.EEPGetWindIntensity
    local originalEEPGetRainIntensity = _G.EEPGetRainIntensity
    local originalEEPGetSnowIntensity = _G.EEPGetSnowIntensity
    local originalEEPGetHailIntensity = _G.EEPGetHailIntensity
    local originalEEPGetFogIntensity = _G.EEPGetFogIntensity

    before_each(function ()
        clearModule("ce.hub.data.weather.WeatherStatePublisher")
        clearModule("ce.hub.data.weather.WeatherDtoFactory")
        clearModule("ce.hub.data.weather.WeatherRegistry")
        clearModule("ce.hub.data.weather.WeatherUpdater")
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
        rawset(_G, "EEPGetSeason", originalEEPGetSeason)
        rawset(_G, "EEPGetCloudsIntensity", originalEEPGetCloudsIntensity)
        rawset(_G, "EEPGetCloudsMode", originalEEPGetCloudsMode)
        rawset(_G, "EEPGetWindIntensity", originalEEPGetWindIntensity)
        rawset(_G, "EEPGetRainIntensity", originalEEPGetRainIntensity)
        rawset(_G, "EEPGetSnowIntensity", originalEEPGetSnowIntensity)
        rawset(_G, "EEPGetHailIntensity", originalEEPGetHailIntensity)
        rawset(_G, "EEPGetFogIntensity", originalEEPGetFogIntensity)
    end)

    it("publishes global weather data as ce.hub.Weather", function ()
        local WeatherStatePublisher = require("ce.hub.data.weather.WeatherStatePublisher")
        local WeatherUpdater = require("ce.hub.data.weather.WeatherUpdater")
        local DataStore = require("ce.hub.publish.InternalDataStore")

        WeatherUpdater.runUpdate()
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
