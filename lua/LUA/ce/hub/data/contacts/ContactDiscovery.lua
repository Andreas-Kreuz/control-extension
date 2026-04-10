if CeDebugLoad then print("[#Start] Loading ce.hub.data.contacts.ContactDiscovery ...") end

local Contact = require("ce.hub.data.contacts.Contact")
local ContactRegistry = require("ce.hub.data.contacts.ContactRegistry")

local ContactDiscovery = {}

function ContactDiscovery.initFromAnl3(tableOfAnl3)
    if not tableOfAnl3 then return end

    for _, entry in ipairs(tableOfAnl3.contacts or {}) do
        if entry.id and not ContactRegistry.has(entry.id) then
            local contact = Contact:new(entry.id, entry.luaFn, entry.tipTxt)
            ContactRegistry.add(contact)
        end
    end
end

return ContactDiscovery
