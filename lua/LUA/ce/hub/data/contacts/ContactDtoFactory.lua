if CeDebugLoad then print("[#Start] Loading ce.hub.data.contacts.ContactDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local peek = DtoFieldAccess.peek
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

---@class ContactDtoFactory
---@field createFullDto fun(contact: Contact, isSelected: boolean|nil):string,string,number,ContactDto
---@field createDtoList fun(contacts: table<number, Contact>, isSelectedByValue: function|nil):string,string,table
local ContactDtoFactory = {}

local CE_TYPE = HubCeTypes.Contact
local KEY_ID = "id"

-- DtoFields: class definition in ContactDtoTypes.d.lua
local dtoFields = {
    luaFn = {
        getValue = peek(function (source) return source:peekLuaFn() end, "luaFn"),
        placeholder = ""
    },
    tipTxt = {
        getValue = peek(function (source) return source:peekTipTxt() end, "tipTxt"),
        placeholder = ""
    },
}

local function buildFullDto(contact, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("contacts")
    return DtoBuilder.buildFullDto({
                                       ceType = CE_TYPE,
                                       id = contact.id
                                   }, contact, dtoFields, fieldPolicies, isSelected)
end

function ContactDtoFactory.createFullDto(contact, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = buildFullDto(contact, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function ContactDtoFactory.createDtoList(contacts, isSelectedByValue)
    local dtos = {}
    for _, contact in pairs(contacts or {}) do
        local _, _, _, dto = ContactDtoFactory.createFullDto(contact,
                                                            isSelectedByValue and isSelectedByValue(contact) or false)
        dtos[#dtos + 1] = dto
    end
    return CE_TYPE, KEY_ID, dtos
end

return ContactDtoFactory
