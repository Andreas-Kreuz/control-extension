-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/weather/WeatherLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.weather.WeatherDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local peek = DtoFieldAccess.peek
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
        getValue = peek(function (source) return source:peekName() end, "name"),
        placeholder = ""
    },
    season = {
        getValue = peek(function (source) return source:peekSeason() end, "season"),
        placeholder = 0
    },
    cloudsIntensity = {
        getValue = peek(function (source) return source:peekCloudsIntensity() end, "cloudsIntensity"),
        placeholder = 0
    },
    cloudsMode = {
        getValue = peek(function (source) return source:peekCloudsMode() end, "cloudsMode"),
        placeholder = 0
    },
    windIntensity = {
        getValue = peek(function (source) return source:peekWindIntensity() end, "windIntensity"),
        placeholder = 0
    },
    rainIntensity = {
        getValue = peek(function (source) return source:peekRainIntensity() end, "rainIntensity"),
        placeholder = 0
    },
    snowIntensity = {
        getValue = peek(function (source) return source:peekSnowIntensity() end, "snowIntensity"),
        placeholder = 0
    },
    hailIntensity = {
        getValue = peek(function (source) return source:peekHailIntensity() end, "hailIntensity"),
        placeholder = 0
    },
    fogIntensity = {
        getValue = peek(function (source) return source:peekFogIntensity() end, "fogIntensity"),
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
