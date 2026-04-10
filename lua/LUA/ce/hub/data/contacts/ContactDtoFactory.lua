if CeDebugLoad then print("[#Start] Loading ce.hub.data.contacts.ContactDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local ContactDtoFactory = {}

local CE_TYPE = HubCeTypes.Contact
local KEY_ID = "id"

local function toFullDto(contact, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("contacts")
    local dto = {
        ceType = CE_TYPE,
        id = contact.id,
    }
    if SyncPolicy.shouldPublishField(fieldPolicies, "luaFn", isSelected) then dto.luaFn = contact:getLuaFn() end
    if SyncPolicy.shouldPublishField(fieldPolicies, "tipTxt", isSelected) then dto.tipTxt = contact:getTipTxt() end
    return dto
end

function ContactDtoFactory.createFullDto(contact, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = toFullDto(contact, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function ContactDtoFactory.createRefDto(contactId)
    local dto = { ceType = CE_TYPE, id = contactId }
    return CE_TYPE, KEY_ID, contactId, dto
end

return ContactDtoFactory
