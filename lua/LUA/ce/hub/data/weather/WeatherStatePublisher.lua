if AkDebugLoad then print("[#Start] Loading ce.hub.data.weather.WeatherStatePublisher ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local WeatherDtoFactory = require("ce.hub.data.weather.WeatherDtoFactory")

WeatherStatePublisher = {}
local enabled = true
local initialized = false
WeatherStatePublisher.name = "ce.hub.data.weather.WeatherStatePublisher"

local function unwrapNumeric(getter)
    if type(getter) ~= "function" then return nil end

    local ok, valueA, valueB = pcall(getter)
    if not ok then return nil end
    if type(valueA) == "boolean" then
        if valueA ~= true then return nil end
        return valueB
    end
    return valueA
end

function WeatherStatePublisher.initialize()
    if not enabled or initialized then return end

    initialized = true
end

function WeatherStatePublisher.syncState()
    if not enabled then return end
    if not initialized then WeatherStatePublisher.initialize() end

    local weatherEntries = {
        weather = {
            id = "weather",
            name = "weather",
            season = unwrapNumeric(EEPGetSeason),
            cloudsIntensity = unwrapNumeric(EEPGetCloudsIntensity),
            cloudsMode = unwrapNumeric(EEPGetCloudsMode),
            windIntensity = unwrapNumeric(EEPGetWindIntensity),
            rainIntensity = unwrapNumeric(EEPGetRainIntensity),
            snowIntensity = unwrapNumeric(EEPGetSnowIntensity),
            hailIntensity = unwrapNumeric(EEPGetHailIntensity),
            fogIntensity = unwrapNumeric(EEPGetFogIntensity)
        }
    }

    DataChangeBus.fireListChange(WeatherDtoFactory.createWeatherDtoList(weatherEntries))
    return {}
end

return WeatherStatePublisher
