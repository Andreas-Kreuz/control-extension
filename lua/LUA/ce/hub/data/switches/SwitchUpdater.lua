if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchUpdater ...") end

local SwitchRegistry = require("ce.hub.data.switches.SwitchRegistry")

local SwitchUpdater = {}

local EEPGetSwitch = _G.EEPGetSwitch or function () return 0 end
local EEPSwitchGetTagText = _G.EEPSwitchGetTagText or function () return false, nil end

function SwitchUpdater.runUpdate()
    for _, switch in pairs(SwitchRegistry.getAll()) do
        switch:setPosition(EEPGetSwitch(switch.id))
        local _, tag = EEPSwitchGetTagText(switch.id)
        switch:setTag(tag or "")
    end
end

return SwitchUpdater
