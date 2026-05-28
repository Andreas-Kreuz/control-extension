if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionStatePublisher ...") end
local VersionPublisher = require("ce.hub.data.version.VersionPublisher")

---@class VersionStatePublisher
---@field name string
---@field initialize fun():nil
---@field syncState fun():nil
local VersionStatePublisher = {}
VersionStatePublisher.enabled = true
local initialized = false
VersionStatePublisher.name = "ce.hub.data.version.VersionStatePublisher"
VersionStatePublisher.ceTypes = require("ce.hub.data.HubCeTypes").EepVersion

function VersionStatePublisher.initialize()
    if not VersionStatePublisher.enabled or initialized then return end
    initialized = true
end

function VersionStatePublisher.syncState()
    if not VersionStatePublisher.enabled then return end
    if not initialized then VersionStatePublisher.initialize() end
    VersionPublisher.syncState()
end

return VersionStatePublisher
