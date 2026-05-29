if CeDebugLoad then print("[#Start] Loading ce.hub.data.time.TimePublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local TimeDtoFactory = require("ce.hub.data.time.TimeDtoFactory")
local TimeRegistry = require("ce.hub.data.time.TimeRegistry")

local TimePublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

function TimePublisher.syncState()
    local timeData = TimeRegistry.get()
    if not timeData then return end

    local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Time, tostring(timeData.id))
    local needsInitialSend = InterestSyncRegistry.needsInitialSend(HubCeTypes.Time, tostring(timeData.id))

    if timeData.needsFullSend or needsInitialSend then
        DataChangeBus.fireDataChanged(TimeDtoFactory.createFullDto(timeData, isSelected))
        timeData.needsFullSend = false
        timeData:resetDirty()
        if needsInitialSend then InterestSyncRegistry.markSent(HubCeTypes.Time, tostring(timeData.id)) end
    elseif timeData:hasDirtyFields() then
        local ceType, keyId, key, dto = TimeDtoFactory.createPatchDto(timeData, timeData.dirtyFields, isSelected)
        if hasPayloadFields(dto) then DataChangeBus.fireDataChanged(ceType, keyId, key, dto) end
        timeData:resetDirty()
    end
end

return TimePublisher
