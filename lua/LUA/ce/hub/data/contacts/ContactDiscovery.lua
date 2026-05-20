if CeDebugLoad then print("[#Start] Loading ce.hub.data.contacts.ContactDiscovery ...") end

local Contact = require("ce.hub.data.contacts.Contact")
local ContactRegistry = require("ce.hub.data.contacts.ContactRegistry")

local ContactDiscovery = {}

function ContactDiscovery.initFromAnl3(tableOfAnl3)
    if not tableOfAnl3 then return end
    if tableOfAnl3.coverage and not tableOfAnl3.coverage.contacts then return end

    local contacts = {}
    for _, entry in ipairs(tableOfAnl3.contacts or {}) do
        if entry.id then contacts[#contacts + 1] = Contact:new(entry.id, entry.luaFn, entry.tipTxt) end
    end
    ContactRegistry.replaceAll(contacts)
end

return ContactDiscovery
