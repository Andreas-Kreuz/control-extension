---@meta

-- Field policies: all fields always

---@class WeatherDto
---@field id string              -- Policy: always
---@field name string            -- Policy: always
---@field season number|nil      -- Policy: always
---@field cloudsIntensity number|nil -- Policy: always
---@field cloudsMode number|nil      -- Policy: always
---@field windIntensity number|nil   -- Policy: always
---@field rainIntensity number|nil   -- Policy: always
---@field snowIntensity number|nil   -- Policy: always
---@field hailIntensity number|nil   -- Policy: always
---@field fogIntensity number|nil    -- Policy: always

---@class WeatherDtoFactory
---@field createWeatherDto fun(weather: table):string,string,string|number,WeatherDto
---@field createWeatherDtoList fun(weatherEntries: table):string,string,table
