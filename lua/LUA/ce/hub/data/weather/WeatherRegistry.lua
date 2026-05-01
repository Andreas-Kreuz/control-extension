if CeDebugLoad then print("[#Start] Loading ce.hub.data.weather.WeatherRegistry ...") end

local Weather = require("ce.hub.data.weather.Weather")

local WeatherRegistry = {}

local weather = nil

local function firstEntry(entries)
    if not entries then return nil end
    return entries.weather or entries[1]
end

function WeatherRegistry.set(entries)
    local rawWeather = firstEntry(entries)
    if not rawWeather then
        weather = nil
        return
    end

    rawWeather.id = rawWeather.id or "weather"
    if weather then
        weather:update(rawWeather)
    else
        weather = Weather:new(rawWeather)
    end
end

function WeatherRegistry.get()
    return weather
end

return WeatherRegistry
