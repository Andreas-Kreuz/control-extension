if CeDebugLoad then print("[#Start] Loading ce.hub.data.weather.WeatherStatePublisher ...") end
local WeatherPublisher = require("ce.hub.data.weather.WeatherPublisher")

WeatherStatePublisher = {}
WeatherStatePublisher.enabled = true
local initialized = false
WeatherStatePublisher.name = "ce.hub.data.weather.WeatherStatePublisher"

function WeatherStatePublisher.initialize()
    if not WeatherStatePublisher.enabled or initialized then return end

    initialized = true
end

function WeatherStatePublisher.syncState()
    if not WeatherStatePublisher.enabled then return end
    if not initialized then WeatherStatePublisher.initialize() end
    return WeatherPublisher.syncState()
end

return WeatherStatePublisher
