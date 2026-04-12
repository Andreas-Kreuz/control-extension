---@meta

---@class ContactDto
---@field ceType string
---@field id number
---@field luaFn string
---@field tipTxt string|nil  -- oninterest: only sent when contact is selected

---@class ContactDtoFactory
---@field createFullDto fun(contact: Contact, isSelected: boolean|nil):string,string,number,ContactDto
---@field createRefDto fun(contactId: number):string,string,number,table
