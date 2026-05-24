if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchUpdater ...") end

local SwitchRegistry = require("ce.hub.data.switches.SwitchRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

---@class SwitchUpdater
---@field runUpdate fun():nil
local SwitchUpdater = {}

function SwitchUpdater.runUpdate()
    local HubCeTypes = require("ce.hub.data.HubCeTypes")
    local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("switches") then return end
    local fieldPolicies = HubOptionsRegistry.getFieldUpdatePolicies("switches")
    for _, switch in pairs(SwitchRegistry.getAll()) do
        local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Switch, tostring(switch.id))
        if SyncPolicy.shouldUpdateField(fieldPolicies, "position", isSelected) then
            switch:pullPosition()
        end
        if SyncPolicy.shouldUpdateField(fieldPolicies, "tag", isSelected) then
            switch:pullTag()
        end
    end
end

return SwitchUpdater
