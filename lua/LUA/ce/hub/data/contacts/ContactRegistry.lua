if CeDebugLoad then print("[#Start] Loading ce.hub.data.contacts.ContactRegistry ...") end

local ContactRegistry = {}

---@type table<number, Contact>
local allContacts = {}
local addedIds = {}

function ContactRegistry.has(id)
    return allContacts[id] ~= nil
end

function ContactRegistry.add(contact)
    allContacts[contact.id] = contact
    addedIds[contact.id] = true
end

function ContactRegistry.getAll()
    local copy = {}
    for id, contact in pairs(allContacts) do copy[id] = contact end
    return copy
end

function ContactRegistry.getAddedIds()
    local copy = {}
    for id in pairs(addedIds) do copy[id] = true end
    return copy
end

function ContactRegistry.clearPendingChanges()
    addedIds = {}
end

return ContactRegistry
