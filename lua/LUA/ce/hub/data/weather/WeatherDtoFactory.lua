-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/weather/WeatherLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.weather.WeatherDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local WeatherDtoFactory = {}

local CE_TYPE = HubCeTypes.Weather
local KEY_ID = "id"

local function toWeatherDto(weather)
    return {
        ceType = CE_TYPE,
        id = weather.id,
        name = weather.name,
        season = weather.season,
        cloudsIntensity = weather.cloudsIntensity,
        cloudsMode = weather.cloudsMode,
        windIntensity = weather.windIntensity,
        rainIntensity = weather.rainIntensity,
        snowIntensity = weather.snowIntensity,
        hailIntensity = weather.hailIntensity,
        fogIntensity = weather.fogIntensity
    }
end

function WeatherDtoFactory.createWeatherDto(weather)
    local dto = toWeatherDto(weather)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function WeatherDtoFactory.createWeatherDtoList(weatherEntries)
    local weatherDtos = {}
    for weatherId, weather in pairs(weatherEntries) do
        local _, _, _, dto = WeatherDtoFactory.createWeatherDto(weather)
        weatherDtos[weatherId] = dto
    end
    return CE_TYPE, KEY_ID, weatherDtos
end

return WeatherDtoFactory
