if CeDebugLoad then print("[#Start] Loading ce.hub.data.weather.WeatherUpdater ...") end

local WeatherRegistry = require("ce.hub.data.weather.WeatherRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local WeatherUpdater = {}

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

function WeatherUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("weather") then return end
    WeatherRegistry.set({
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
    })
end

return WeatherUpdater
