if CeDebugLoad then print("[#Start] Loading ce.hub.data.weather.WeatherPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local WeatherDtoFactory = require("ce.hub.data.weather.WeatherDtoFactory")
local WeatherRegistry = require("ce.hub.data.weather.WeatherRegistry")

local WeatherPublisher = {}

function WeatherPublisher.syncState()
    DataChangeBus.fireListChange(WeatherDtoFactory.createWeatherDtoList(WeatherRegistry.get() or {}))
    return {}
end

return WeatherPublisher
