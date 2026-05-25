if CeDebugLoad then print("[#Start] Loading ce.hub.data.switches.Switch ...") end

local DataClass = require("ce.hub.data.DataClass")

---@class Switch
---@field id number
---@field position number
---@field tag string
---@field tippText string
---@field tippTextVisible boolean
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local Switch = {}

local registeredSwitchIds = {}

function Switch:new(id)
    local o = {
        id = id,
        position = 0,
        tag = "",
        tippText = "",
        tippTextVisible = false,
        dirtyFields = {},
        needsFullSend = true
    }
    self.__index = self
    setmetatable(o, self)
    DataClass.init(o)
    return o
end

function Switch.exists(id)
    if not DataClass.isCallable(_G.EEPGetSwitch) then return false end
    return (_G.EEPGetSwitch(id) or 0) > 0
end

function Switch.registerSwitch(switchId)
    if registeredSwitchIds[switchId] then
        print(string.format("[#Switch] SWITCH %s WAS ALREADY REGISTERED", tostring(switchId)))
    end
    registeredSwitchIds[switchId] = true

    if _G.EEPRegisterSwitch then return _G.EEPRegisterSwitch(switchId) end
    return false
end

function Switch:peekPosition() return self.position end

function Switch:getPosition()
    if not DataClass.isLoaded(self, "position") then return self:pullPosition() end
    return self.position
end

function Switch:peekTag() return self.tag end

function Switch:getTag()
    if not DataClass.isLoaded(self, "tag") then return self:pullTag() end
    return self.tag
end

function Switch:replacePosition(position)
    DataClass.replaceField(self, "position", position or 0)
end

function Switch:seedPosition(position)
    self:replacePosition(position)
end

function Switch:setPosition(position)
    local value = position or 0
    if self.position == value then return true end
    local ok = true
    if _G.EEPSetSwitch then ok = _G.EEPSetSwitch(self.id, value) ~= false end
    if ok then self:replacePosition(value) end
    return ok
end

function Switch:pullPosition()
    if not DataClass.isCallable(_G.EEPGetSwitch) then return nil end
    local position = _G.EEPGetSwitch(self.id)
    if not position or position <= 0 then return nil end
    self:replacePosition(position)
    return self.position
end

function Switch:replaceTag(tag)
    DataClass.replaceField(self, "tag", tag or "")
end

function Switch:seedTag(tag)
    self:replaceTag(tag)
end

function Switch:setTag(tag)
    local value = tag or ""
    if self.tag == value then return true end
    local ok = true
    if _G.EEPSwitchSetTagText then ok = _G.EEPSwitchSetTagText(self.id, value) ~= false end
    if ok then self:replaceTag(value) end
    return ok
end

function Switch:pullTag()
    if not DataClass.isCallable(_G.EEPSwitchGetTagText) then return nil end
    local ok, tag = _G.EEPSwitchGetTagText(self.id)
    if not ok then return nil end
    self:replaceTag(tag or "")
    return self.tag
end

function Switch:peekTippText() return self.tippText end

function Switch:getTippText() return self.tippText end

function Switch:peekTippTextVisible() return self.tippTextVisible end

function Switch:getTippTextVisible() return self.tippTextVisible end

function Switch:changeInfo(text)
    local value = text or ""
    if DataClass.isLoaded(self, "tippText") and self.tippText == value then return true end

    local ok = true
    if _G.EEPChangeInfoSwitch then ok = _G.EEPChangeInfoSwitch(self.id, value) ~= false end
    if ok then
        self.tippText = value
        DataClass.markLoaded(self, "tippText")
    end
    return ok
end

function Switch:showInfo(visible)
    local value = visible == true
    if DataClass.isLoaded(self, "tippTextVisible") and self.tippTextVisible == value then return true end

    local ok = true
    if _G.EEPShowInfoSwitch then ok = _G.EEPShowInfoSwitch(self.id, value) ~= false end
    if ok then
        self.tippTextVisible = value
        DataClass.markLoaded(self, "tippTextVisible")
    end
    return ok
end

function Switch:resetDirty()
    DataClass.resetDirty(self)
end

function Switch:hasDirtyFields()
    return DataClass.hasDirtyFields(self)
end

return Switch
