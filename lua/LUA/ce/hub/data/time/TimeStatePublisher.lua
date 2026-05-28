if CeDebugLoad then print("[#Start] Loading ce.hub.data.time.TimeStatePublisher ...") end
local TimePublisher = require("ce.hub.data.time.TimePublisher")

---@class TimeStatePublisher
---@field name string
---@field initialize fun():nil
---@field syncState fun():nil
local TimeStatePublisher = {}
TimeStatePublisher.enabled = true
local initialized = false
TimeStatePublisher.name = "ce.hub.data.time.TimeStatePublisher"
TimeStatePublisher.ceTypes = require("ce.hub.data.HubCeTypes").Time

function TimeStatePublisher.initialize()
    if not TimeStatePublisher.enabled or initialized then return end

    initialized = true
end

function TimeStatePublisher.syncState()
    if not TimeStatePublisher.enabled then return end

    if not initialized then TimeStatePublisher.initialize() end
    TimePublisher.syncState()
end

return TimeStatePublisher
