if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchDiscovery ...") end

local Switch = require("ce.hub.data.switches.Switch")
local SwitchRegistry = require("ce.hub.data.switches.SwitchRegistry")

local SwitchDiscovery = {}

local MAX_SWITCHES = 1000
local EEPGetSwitch = _G.EEPGetSwitch or function () return 0 end

local function discoverSwitches()
    for i = 1, MAX_SWITCHES do
        if EEPGetSwitch(i) > 0 and not SwitchRegistry.has(i) then
            SwitchRegistry.add(Switch:new(i))
        end
    end
end

function SwitchDiscovery.runInitialDiscovery()
    discoverSwitches()
end

function SwitchDiscovery.runDiscovery()
    discoverSwitches()
end

return SwitchDiscovery
