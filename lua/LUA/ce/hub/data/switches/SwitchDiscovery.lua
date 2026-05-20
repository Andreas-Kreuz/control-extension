if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchDiscovery ...") end

local Switch = require("ce.hub.data.switches.Switch")
local SwitchRegistry = require("ce.hub.data.switches.SwitchRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

---@class SwitchDiscovery
---@field initFromAnl3 fun(tableOfAnl3: table|nil):nil
---@field runInitialDiscovery fun():nil
---@field runDiscovery fun():nil
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

function SwitchDiscovery.initFromAnl3(tableOfAnl3)
    if not tableOfAnl3 then return end
    if tableOfAnl3.coverage and not tableOfAnl3.coverage.switches then return end

    local switches = {}
    for _, entry in ipairs(tableOfAnl3.switches or {}) do
        if entry.keyId then
            local switch = Switch:new(entry.keyId)
            if entry.position then switch:setPosition(entry.position) end
            switches[#switches + 1] = switch
        end
    end
    SwitchRegistry.replaceAll(switches)
end

function SwitchDiscovery.runInitialDiscovery()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("switches") then return end
    discoverSwitches()
end

function SwitchDiscovery.runDiscovery()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("switches") then return end
    discoverSwitches()
end

return SwitchDiscovery
