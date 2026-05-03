-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/weather/WeatherLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.weather.WeatherDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local HubCeTypes = require("ce.hub.data.HubCeTypes")

---@class WeatherDtoFactory
---@field createFullDto fun(weather: table):string,string,string|number,WeatherDto
---@field createPatchDto fun(weather: table, dirtyFields: table<string, boolean>):string,string,string|number,WeatherDto
---@field createWeatherDtoList fun(weatherEntries: table):string,string,table
local WeatherDtoFactory = {}

local CE_TYPE = HubCeTypes.Weather
local KEY_ID = "id"

-- DtoFields: class definition in WeatherDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = function (weather) return weather.name end,
        placeholder = ""
    },
    season = {
        getValue = function (weather) return weather.season end,
        placeholder = 0
    },
    cloudsIntensity = {
        getValue = function (weather) return weather.cloudsIntensity end,
        placeholder = 0
    },
    cloudsMode = {
        getValue = function (weather) return weather.cloudsMode end,
        placeholder = 0
    },
    windIntensity = {
        getValue = function (weather) return weather.windIntensity end,
        placeholder = 0
    },
    rainIntensity = {
        getValue = function (weather) return weather.rainIntensity end,
        placeholder = 0
    },
    snowIntensity = {
        getValue = function (weather) return weather.snowIntensity end,
        placeholder = 0
    },
    hailIntensity = {
        getValue = function (weather) return weather.hailIntensity end,
        placeholder = 0
    },
    fogIntensity = {
        getValue = function (weather) return weather.fogIntensity end,
        placeholder = 0
    },
}

local function buildWeatherDto(weather)
    return DtoBuilder.buildFullDto({
                                       ceType = CE_TYPE,
                                       id = weather.id
                                   }, weather, dtoFields)
end

local function buildWeatherPatchDto(weather, dirtyFields)
    return DtoBuilder.buildPatchDto({
                                        ceType = CE_TYPE,
                                        id = weather.id
                                    }, weather, dirtyFields, dtoFields)
end

function WeatherDtoFactory.createFullDto(weather)
    local dto = buildWeatherDto(weather)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function WeatherDtoFactory.createPatchDto(weather, dirtyFields)
    local dto = buildWeatherPatchDto(weather, dirtyFields)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function WeatherDtoFactory.createWeatherDtoList(weatherEntries)
    local weatherDtos = {}
    for weatherId, weather in pairs(weatherEntries) do
        local _, _, _, dto = WeatherDtoFactory.createFullDto(weather)
        weatherDtos[weatherId] = dto
    end
    return CE_TYPE, KEY_ID, weatherDtos
end

return WeatherDtoFactory
