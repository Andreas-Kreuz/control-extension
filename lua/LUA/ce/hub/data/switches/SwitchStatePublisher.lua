if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.SwitchStatePublisher ...") end
local SwitchPublisher = require("ce.hub.data.switches.SwitchPublisher")
SwitchStatePublisher = {}
SwitchStatePublisher.enabled = true
local initialized = false
SwitchStatePublisher.name = "ce.hub.data.switches.SwitchStatePublisher"

SwitchStatePublisher.options = {
    ceTypes = {
        switches = { ceType = "ce.hub.Switch", mode = "all" }
    }
}

function SwitchStatePublisher.initialize()
    if not SwitchStatePublisher.enabled or initialized then return end
    initialized = true
end

function SwitchStatePublisher.syncState()
    if not SwitchStatePublisher.enabled then return end

    if not initialized then SwitchStatePublisher.initialize() end
    return SwitchPublisher.syncState()
end

return SwitchStatePublisher
