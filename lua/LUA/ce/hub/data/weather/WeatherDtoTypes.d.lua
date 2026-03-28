---@meta

---@class WeatherDto
---@field id string
---@field name string
---@field season number|nil
---@field cloudsIntensity number|nil
---@field cloudsMode number|nil
---@field windIntensity number|nil
---@field rainIntensity number|nil
---@field snowIntensity number|nil
---@field hailIntensity number|nil
---@field fogIntensity number|nil

---@class WeatherDtoFactory
---@field createWeatherDto fun(weather: table):string,string,string|number,WeatherDto
---@field createWeatherDtoList fun(weatherEntries: table):string,string,table
