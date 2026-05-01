if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalStatePublisher ...") end
local SignalPublisher = require("ce.hub.data.signals.SignalPublisher")

---@class SignalStatePublisher
---@field name string
---@field initialize fun():nil
---@field syncState fun():table
local SignalStatePublisher = {}
SignalStatePublisher.enabled = true
local initialized = false
SignalStatePublisher.name = "ce.hub.data.signals.SignalStatePublisher"
SignalStatePublisher.ceTypes = require("ce.hub.data.HubCeTypes").Signal

function SignalStatePublisher.initialize()
    if not SignalStatePublisher.enabled or initialized then return end
    initialized = true
end

function SignalStatePublisher.syncState()
    if not SignalStatePublisher.enabled then return end

    if not initialized then SignalStatePublisher.initialize() end
    return SignalPublisher.syncState()
end

return SignalStatePublisher
