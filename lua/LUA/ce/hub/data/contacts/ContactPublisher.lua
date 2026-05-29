if CeDebugLoad then print("[#Start] Loading ce.hub.data.contacts.ContactPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local ContactDtoFactory = require("ce.hub.data.contacts.ContactDtoFactory")
local ContactRegistry = require("ce.hub.data.contacts.ContactRegistry")
local ContactPublisher = {}

function ContactPublisher.syncState()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")

    if not HubOptionsRegistry.isPublishEnabled("contacts") then
        ContactRegistry.clearPendingChanges()
        return
    end

    local addedIds = ContactRegistry.getAddedIds()
    local contacts = ContactRegistry.getAll()
    local hasContact = false
    local allContactsNeedFullSend = true

    for _, contact in pairs(contacts) do
        hasContact = true
        if not contact.needsFullSend then allContactsNeedFullSend = false end
    end

    if hasContact and allContactsNeedFullSend then
        DataChangeBus.fireListChange(ContactDtoFactory.createDtoList(contacts, function (contact)
            return InterestSyncRegistry.isSelected(HubCeTypes.Contact, contact.id)
        end))
        for _, contact in pairs(contacts) do contact.needsFullSend = false end
        ContactRegistry.clearPendingChanges()
        return
    end

    for contactId in pairs(addedIds) do
        local contact = contacts[contactId]
        if contact then
            local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Contact, contactId)
            DataChangeBus.fireDataAdded(ContactDtoFactory.createFullDto(contact, isSelected))
            contact.needsFullSend = false
        end
    end

    for _, contact in pairs(contacts) do
        local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Contact, contact.id)
        local needsInitialSend = InterestSyncRegistry.needsInitialSend(HubCeTypes.Contact, contact.id)
        if not addedIds[contact.id] and (contact.needsFullSend or needsInitialSend) then
            DataChangeBus.fireDataChanged(ContactDtoFactory.createFullDto(contact, isSelected))
            contact.needsFullSend = false
            if isSelected then InterestSyncRegistry.markSent(HubCeTypes.Contact, contact.id) end
        end
    end

    ContactRegistry.clearPendingChanges()
end

return ContactPublisher
