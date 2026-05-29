if CeDebugLoad then print("[#Start] Loading ce.hub.data.time.TimeUpdater ...") end

local TimeData = require("ce.hub.data.time.TimeData")
local TimeRegistry = require("ce.hub.data.time.TimeRegistry")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local TimeUpdater = {}
local FIELD_NAMES = { "name", "timeComplete", "timeH", "timeM", "timeS" }

function TimeUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("time") then return end

    local timeData = TimeRegistry.get()
    local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Time, "times")
    local fieldPolicies = HubOptionsRegistry.getFieldUpdatePolicies("time")
    local updatedFields = {}
    local shouldPull = timeData == nil
    for _, fieldName in ipairs(FIELD_NAMES) do
        if SyncPolicy.shouldUpdateField(fieldPolicies, fieldName, isSelected) then
            updatedFields[fieldName] = true
            shouldPull = true
        end
    end
    if not shouldPull then return end

    TimeRegistry.set({ TimeData.pullCurrent() }, timeData and updatedFields or nil)
end

return TimeUpdater
