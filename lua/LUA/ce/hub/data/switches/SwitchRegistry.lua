if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchRegistry ...") end

---@class SwitchRegistry
---@field has fun(switchId: number):boolean
---@field add fun(switch: Switch):nil
---@field replaceAll fun(switches: Switch[]):nil
---@field remove fun(switchId: number):nil
---@field get fun(switchId: number):Switch|nil
---@field getOrCreate fun(switchId: number):Switch
---@field getAll fun():table<number, Switch>
local SwitchRegistry = {}

local Switch = require("ce.hub.data.switches.Switch")

---@type table<number, Switch>
local allSwitches = {}

function SwitchRegistry.has(switchId)
    return allSwitches[switchId] ~= nil
end

function SwitchRegistry.add(switch)
    allSwitches[switch.id] = switch
end

function SwitchRegistry.replaceAll(switches)
    allSwitches = {}
    for _, switch in ipairs(switches or {}) do
        allSwitches[switch.id] = switch
    end
end

function SwitchRegistry.remove(switchId)
    allSwitches[switchId] = nil
end

function SwitchRegistry.get(switchId)
    return allSwitches[switchId]
end

function SwitchRegistry.getOrCreate(switchId)
    local switch = SwitchRegistry.get(switchId)
    if switch then return switch end

    switch = Switch:new(switchId)
    SwitchRegistry.add(switch)
    return switch
end

function SwitchRegistry.getAll()
    local copy = {}
    for switchId, switch in pairs(allSwitches) do copy[switchId] = switch end
    return copy
end

return SwitchRegistry
