if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimeStatePublisher ...") end
local RuntimePublisher = require("ce.hub.data.runtime.RuntimePublisher")

---@class RuntimeStatePublisher
---@field name string
---@field initialize fun():nil
---@field syncState fun():nil
RuntimeStatePublisher = {}
RuntimeStatePublisher.enabled = true
local initialized = false
RuntimeStatePublisher.name = "ce.hub.data.runtime.RuntimeStatePublisher"
RuntimeStatePublisher.ceTypes = require("ce.hub.data.HubCeTypes").Runtime

function RuntimeStatePublisher.initialize()
    if not RuntimeStatePublisher.enabled or initialized then return end

    initialized = true
end

function RuntimeStatePublisher.syncState()
    if not RuntimeStatePublisher.enabled then return end
    if not initialized then RuntimeStatePublisher.initialize() end
    RuntimePublisher.syncState()
end

return RuntimeStatePublisher
