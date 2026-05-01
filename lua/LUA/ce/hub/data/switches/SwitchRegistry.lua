if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchRegistry ...") end

---@class SwitchRegistry
---@field has fun(switchId: number):boolean
---@field add fun(switch: Switch):nil
---@field get fun(switchId: number):Switch|nil
---@field getAll fun():table<number, Switch>
local SwitchRegistry = {}

---@type table<number, Switch>
local allSwitches = {}

function SwitchRegistry.has(switchId)
    return allSwitches[switchId] ~= nil
end

function SwitchRegistry.add(switch)
    allSwitches[switch.id] = switch
end

function SwitchRegistry.get(switchId)
    return allSwitches[switchId]
end

function SwitchRegistry.getAll()
    local copy = {}
    for switchId, switch in pairs(allSwitches) do copy[switchId] = switch end
    return copy
end

return SwitchRegistry
