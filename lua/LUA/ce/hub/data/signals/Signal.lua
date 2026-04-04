if AkDebugLoad then print("[#Start] Loading ce.hub.data.signals.Signal ...") end

-- Field update policies (see SignalDtoTypes.d.lua): all fields always

---@class Signal
---@field id number
---@field position number
---@field tag string
---@field waitingVehiclesCount number
---@field stopDistance number|nil
---@field itemName string|nil
---@field itemNameWithModelPath string|nil
---@field signalFunctions string[]|nil
---@field activeFunction string|nil
---@field valuesUpdated boolean
---@field isInitialized boolean
local Signal = {}

local EEPGetSignal = _G.EEPGetSignal or function() return 0 end
local EEPSignalGetTagText = _G.EEPSignalGetTagText or function() return false, nil end
local EEPGetSignalTrainsCount = _G.EEPGetSignalTrainsCount or function() return 0 end
local EEPGetSignalStopDistance = _G.EEPGetSignalStopDistance or function() return false, nil end
local EEPGetSignalItemName = _G.EEPGetSignalItemName or function() return false, nil end
local EEPGetSignalFunctions = _G.EEPGetSignalFunctions or function() return false, 0 end
local EEPGetSignalFunction = _G.EEPGetSignalFunction or function() return false, nil end

local function readFunctions(id, position)
    local functionsOk, functionCount = EEPGetSignalFunctions(id)
    if not functionsOk or not functionCount or functionCount == 0 then return nil, nil end
    local fns = {}
    local activeFunction = nil
    for selIndex = 1, functionCount do
        local ok, fn = EEPGetSignalFunction(id, selIndex)
        if ok then
            local fnValue = tostring(fn)
            fns[#fns + 1] = fnValue
            if position == fn then activeFunction = fnValue end
        end
    end
    return #fns > 0 and fns or nil, activeFunction
end

---@param id number
---@return Signal
function Signal:new(id)
    local o = { id = id }
    self.__index = self
    setmetatable(o, self)
    o:refresh()
    return o
end

function Signal:refresh()
    local position = EEPGetSignal(self.id)
    local _, tag = EEPSignalGetTagText(self.id)
    local waitingVehiclesCount = EEPGetSignalTrainsCount(self.id) or 0
    local stopDistanceOk, stopDistance = EEPGetSignalStopDistance(self.id)
    local itemNameOk, itemName = EEPGetSignalItemName(self.id, false)
    local itemNameWithModelPathOk, itemNameWithModelPath = EEPGetSignalItemName(self.id, true)
    local signalFunctions, activeFunction = readFunctions(self.id, position)
    local tagStr = tag or ""
    local stopDistanceVal = stopDistanceOk and stopDistance or nil
    local itemNameVal = itemNameOk and itemName or nil

    local changed = not self.isInitialized
        or position ~= self.position
        or tagStr ~= (self.tag or "")
        or waitingVehiclesCount ~= self.waitingVehiclesCount
        or stopDistanceVal ~= self.stopDistance
        or itemNameVal ~= self.itemName
        or activeFunction ~= self.activeFunction

    if changed then
        self.valuesUpdated = true
        self.isInitialized = true
        self.position = position
        self.tag = tagStr
        self.waitingVehiclesCount = waitingVehiclesCount
        self.stopDistance = stopDistanceVal
        self.itemName = itemNameVal
        self.itemNameWithModelPath = itemNameWithModelPathOk and itemNameWithModelPath or nil
        self.signalFunctions = signalFunctions
        self.activeFunction = activeFunction
    end
end

return Signal
