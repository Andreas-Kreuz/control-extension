if CeDebugLoad then print("[#Start] Loading ce.hub.data.weather.WeatherUpdater ...") end

local Weather = require("ce.hub.data.weather.Weather")
local WeatherRegistry = require("ce.hub.data.weather.WeatherRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local WeatherUpdater = {}

function WeatherUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("weather") then return end
    WeatherRegistry.set({ weather = Weather.pullCurrent() })
end

return WeatherUpdater
