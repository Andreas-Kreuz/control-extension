if CeDebugLoad then print("[#Start] Loading ce.hub.data.contacts.ContactPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local ContactDtoFactory = require("ce.hub.data.contacts.ContactDtoFactory")
local ContactRegistry = require("ce.hub.data.contacts.ContactRegistry")
local ContactPublisher = {}

function ContactPublisher.syncState()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")

    if not HubOptionsRegistry.isPublishEnabled("contacts") then
        ContactRegistry.clearPendingChanges()
        return {}
    end

    local addedIds = ContactRegistry.getAddedIds()

    for contactId in pairs(addedIds) do
        local contact = ContactRegistry.getAll()[contactId]
        if contact then
            local isSelected = DynamicUpdateRegistry.isSelected(HubCeTypes.Contact, contactId)
            DataChangeBus.fireDataAdded(ContactDtoFactory.createFullDto(contact, isSelected))
            contact.needsFullSend = false
        end
    end

    for _, contact in pairs(ContactRegistry.getAll()) do
        local isSelected = DynamicUpdateRegistry.isSelected(HubCeTypes.Contact, contact.id)
        local needsInitialSend = DynamicUpdateRegistry.needsInitialSend(HubCeTypes.Contact, contact.id)
        if not addedIds[contact.id] and (contact.needsFullSend or needsInitialSend) then
            DataChangeBus.fireDataChanged(ContactDtoFactory.createFullDto(contact, isSelected))
            contact.needsFullSend = false
            if isSelected then DynamicUpdateRegistry.markSent(HubCeTypes.Contact, contact.id) end
        end
    end

    ContactRegistry.clearPendingChanges()
    return {}
end

return ContactPublisher
