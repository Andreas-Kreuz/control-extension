if AkDebugLoad then print("[#Start] Loading ce.hub.data.switches.Switch ...") end

-- Field update policies (see SwitchDtoTypes.d.lua): all fields always

---@class Switch
---@field id number
---@field position number
---@field tag string
---@field valuesUpdated boolean
---@field isInitialized boolean
local Switch = {}

local EEPGetSwitch = _G.EEPGetSwitch or function() return 0 end
local EEPSwitchGetTagText = _G.EEPSwitchGetTagText or function() return false, nil end

---@param id number
---@return Switch
function Switch:new(id)
    local o = { id = id }
    self.__index = self
    setmetatable(o, self)
    o:refresh()
    return o
end

function Switch:refresh()
    local position = EEPGetSwitch(self.id)
    local _, tag = EEPSwitchGetTagText(self.id)
    local tagStr = tag or ""

    local changed = not self.isInitialized
        or position ~= self.position
        or tagStr ~= (self.tag or "")

    if changed then
        self.valuesUpdated = true
        self.isInitialized = true
        self.position = position
        self.tag = tagStr
    end
end

return Switch
