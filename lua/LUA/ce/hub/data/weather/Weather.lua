if CeDebugLoad then print("[#Start] Loading ce.hub.data.weather.Weather ...") end

---@class Weather
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
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local Weather = {}

local function markDirty(weather, fieldName)
    weather.dirtyFields[fieldName] = true
end

local function updateField(weather, fieldName, value)
    local oldValue = weather[fieldName]
    weather[fieldName] = value
    if oldValue ~= value then markDirty(weather, fieldName) end
end

function Weather:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.id, "Provide an id")

    self.__index = self
    setmetatable(o, self)
    o.dirtyFields = {}
    o.needsFullSend = true
    return o
end

local function unwrapNumeric(getter)
    if type(getter) ~= "function" then return nil end

    local ok, valueA, valueB = pcall(getter)
    if not ok then return nil end
    if type(valueA) == "boolean" then
        if valueA ~= true then return nil end
        return valueB
    end
    return valueA
end

function Weather.pullCurrent()
    return {
        id = "weather",
        name = "weather",
        season = unwrapNumeric(EEPGetSeason),
        cloudsIntensity = unwrapNumeric(EEPGetCloudsIntensity),
        cloudsMode = unwrapNumeric(EEPGetCloudsMode),
        windIntensity = unwrapNumeric(EEPGetWindIntensity),
        rainIntensity = unwrapNumeric(EEPGetRainIntensity),
        snowIntensity = unwrapNumeric(EEPGetSnowIntensity),
        hailIntensity = unwrapNumeric(EEPGetHailIntensity),
        fogIntensity = unwrapNumeric(EEPGetFogIntensity)
    }
end

function Weather:update(values)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(values) == "table", "Need 'values' as table")

    updateField(self, "name", values.name)
    updateField(self, "season", values.season)
    updateField(self, "cloudsIntensity", values.cloudsIntensity)
    updateField(self, "cloudsMode", values.cloudsMode)
    updateField(self, "windIntensity", values.windIntensity)
    updateField(self, "rainIntensity", values.rainIntensity)
    updateField(self, "snowIntensity", values.snowIntensity)
    updateField(self, "hailIntensity", values.hailIntensity)
    updateField(self, "fogIntensity", values.fogIntensity)
end

function Weather:resetDirty()
    self.dirtyFields = {}
end

function Weather:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return Weather
