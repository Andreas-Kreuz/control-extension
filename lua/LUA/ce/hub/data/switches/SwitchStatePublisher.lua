if AkDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchStatePublisher ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local Switch = require("ce.hub.data.switches.Switch")
local SwitchDtoFactory = require("ce.hub.data.switches.SwitchDtoFactory")
SwitchStatePublisher = {}
SwitchStatePublisher.enabled = true
local initialized = false
SwitchStatePublisher.name = "ce.hub.data.switches.SwitchStatePublisher"

SwitchStatePublisher.options = {
    ceTypes = {
        switch = { ceType = "ce.hub.Switch", mode = "all" }
    }
}

local MAX_SWITCHES = 1000
local EEPGetSwitch = _G.EEPGetSwitch or function() return 0 end

---@type table<number, Switch>
local allSwitches = {}

function SwitchStatePublisher.initialize()
    if not SwitchStatePublisher.enabled or initialized then return end

    for i = 1, MAX_SWITCHES do
        if EEPGetSwitch(i) > 0 then
            allSwitches[i] = Switch:new(i)
        end
    end

    initialized = true
end

function SwitchStatePublisher.syncState()
    if not SwitchStatePublisher.enabled then return end

    if not initialized then SwitchStatePublisher.initialize() end

    for _, switch in pairs(allSwitches) do
        switch:refresh()
        if switch.valuesUpdated then
            switch.valuesUpdated = false
            DataChangeBus.fireDataChanged(SwitchDtoFactory.createSwitchDto(switch))
        end
    end

    return {}
end

return SwitchStatePublisher
