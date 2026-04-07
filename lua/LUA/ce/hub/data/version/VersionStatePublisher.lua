if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionStatePublisher ...") end
local VersionPublisher = require("ce.hub.data.version.VersionPublisher")
VersionStatePublisher = {}
VersionStatePublisher.enabled = true
local initialized = false
VersionStatePublisher.name = "ce.hub.VersionStatePublisher"

function VersionStatePublisher.initialize()
    if not VersionStatePublisher.enabled or initialized then return end
    initialized = true
end

function VersionStatePublisher.syncState()
    if not VersionStatePublisher.enabled then return end
    if not initialized then VersionStatePublisher.initialize() end
    return VersionPublisher.syncState()
end

return VersionStatePublisher
