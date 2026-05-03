if CeDebugLoad then print("[#Start] Loading ce.hub.data.weather.WeatherPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local WeatherDtoFactory = require("ce.hub.data.weather.WeatherDtoFactory")
local WeatherRegistry = require("ce.hub.data.weather.WeatherRegistry")

local WeatherPublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

function WeatherPublisher.syncState()
    local weather = WeatherRegistry.get()
    if not weather then return end

    if weather.needsFullSend then
        DataChangeBus.fireDataChanged(WeatherDtoFactory.createFullDto(weather))
        weather.needsFullSend = false
        weather:resetDirty()
    elseif weather:hasDirtyFields() then
        local ceType, keyId, key, dto = WeatherDtoFactory.createPatchDto(weather, weather.dirtyFields)
        if hasPayloadFields(dto) then DataChangeBus.fireDataChanged(ceType, keyId, key, dto) end
        weather:resetDirty()
    end
end

return WeatherPublisher
