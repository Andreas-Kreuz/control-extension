if CeDebugLoad then print("[#Start] Loading ce.hub.data.weather.WeatherRegistry ...") end

local WeatherRegistry = {}

local weatherEntries = nil

function WeatherRegistry.set(entries)
    weatherEntries = entries
end

function WeatherRegistry.get()
    return weatherEntries
end

return WeatherRegistry
