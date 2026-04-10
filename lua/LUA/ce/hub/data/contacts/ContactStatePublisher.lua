if CeDebugLoad then print("[#Start] Loading ce.hub.data.contacts.ContactStatePublisher ...") end

local ContactPublisher = require("ce.hub.data.contacts.ContactPublisher")
local ContactStatePublisher = {}
ContactStatePublisher.enabled = true
local initialized = false
ContactStatePublisher.name = "ce.hub.data.contacts.ContactStatePublisher"
ContactStatePublisher.ceTypes = require("ce.hub.data.HubCeTypes").Contact

function ContactStatePublisher.initialize()
    if not ContactStatePublisher.enabled or initialized then return end
    initialized = true
end

function ContactStatePublisher.syncState()
    if not ContactStatePublisher.enabled then return end
    if not initialized then ContactStatePublisher.initialize() end
    return ContactPublisher.syncState()
end

return ContactStatePublisher
