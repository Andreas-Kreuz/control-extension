if CeDebugLoad then print("[#Start] Loading ce.hub.data.contacts.Contact ...") end

---@class Contact
---@field id number
---@field luaFn string
---@field tipTxt string|nil
---@field needsFullSend boolean
local Contact = {}

---@param id number
---@param luaFn string
---@param tipTxt string|nil
---@return Contact
function Contact:new(id, luaFn, tipTxt)
    local o = {
        id = id,
        luaFn = luaFn,
        tipTxt = tipTxt,
        needsFullSend = true
    }
    self.__index = self
    setmetatable(o, self)
    return o
end

function Contact:getLuaFn() return self.luaFn end

function Contact:getTipTxt() return self.tipTxt end

return Contact
