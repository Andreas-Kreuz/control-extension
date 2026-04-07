if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchUpdater ...") end

local SwitchRegistry = require("ce.hub.data.switches.SwitchRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local SwitchUpdater = {}

local EEPGetSwitch = _G.EEPGetSwitch or function () return 0 end
local EEPSwitchGetTagText = _G.EEPSwitchGetTagText or function () return false, nil end

function SwitchUpdater.runUpdate()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("switches") then return end
    for _, switch in pairs(SwitchRegistry.getAll()) do
        switch:setPosition(EEPGetSwitch(switch.id))
        local _, tag = EEPSwitchGetTagText(switch.id)
        switch:setTag(tag or "")
    end
end

return SwitchUpdater
