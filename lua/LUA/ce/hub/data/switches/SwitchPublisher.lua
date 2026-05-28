if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local SwitchDtoFactory = require("ce.hub.data.switches.SwitchDtoFactory")
local SwitchRegistry = require("ce.hub.data.switches.SwitchRegistry")

---@class SwitchPublisher
---@field syncState fun():nil
local SwitchPublisher = {}

function SwitchPublisher.syncState()
    local switches = SwitchRegistry.getAll()
    local hasSwitch = false
    local allSwitchesNeedFullSend = true

    for _, switch in pairs(switches) do
        hasSwitch = true
        if not switch.needsFullSend then allSwitchesNeedFullSend = false end
    end

    if hasSwitch and allSwitchesNeedFullSend then
        local list = {}
        for _, switch in pairs(switches) do
            local _, _, _, dto = SwitchDtoFactory.createSwitchDto(switch)
            list[#list + 1] = dto
            switch.needsFullSend = false
            switch:resetDirty()
        end
        DataChangeBus.fireListChange(require("ce.hub.data.HubCeTypes").Switch, "id", list)
        return
    end

    for _, switch in pairs(switches) do
        if switch.needsFullSend or switch:hasDirtyFields() then
            DataChangeBus.fireDataChanged(SwitchDtoFactory.createSwitchDto(switch))
            switch.needsFullSend = false
            switch:resetDirty()
        end
    end
end

return SwitchPublisher
