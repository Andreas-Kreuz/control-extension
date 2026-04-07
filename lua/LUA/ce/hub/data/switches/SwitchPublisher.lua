if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local SwitchDtoFactory = require("ce.hub.data.switches.SwitchDtoFactory")
local SwitchRegistry = require("ce.hub.data.switches.SwitchRegistry")

local SwitchPublisher = {}

function SwitchPublisher.syncState()
    for _, switch in pairs(SwitchRegistry.getAll()) do
        if switch.needsFullSend or switch:hasDirtyFields() then
            DataChangeBus.fireDataChanged(SwitchDtoFactory.createSwitchDto(switch))
            switch.needsFullSend = false
            switch:resetDirty()
        end
    end

    return {}
end

return SwitchPublisher
