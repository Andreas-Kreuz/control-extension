if CeDebugLoad then print("[#Start] Loading ce.hub.data.modules.ModulesStatePublisher ...") end
local ModulesPublisher = require("ce.hub.data.modules.ModulesPublisher")

---@class ModulesStatePublisher
---@field initialize fun():nil
---@field syncState fun():table
ModulesStatePublisher = {}
ModulesStatePublisher.enabled = true
local initialized = false
ModulesStatePublisher.name = "ce.hub.ModulesStatePublisher"

function ModulesStatePublisher.initialize()
    if not ModulesStatePublisher.enabled or initialized then return end
    initialized = true
end

function ModulesStatePublisher.syncState()
    if not ModulesStatePublisher.enabled then return end
    if not initialized then ModulesStatePublisher.initialize() end
    return ModulesPublisher.syncState()
end

return ModulesStatePublisher
