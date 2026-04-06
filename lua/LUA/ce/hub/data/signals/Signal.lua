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
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

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

function Signal:getTag() return self.tag end
function Signal:getStopDistance() return self.stopDistance end
function Signal:getItemName() return self.itemName end
function Signal:getItemNameWithModelPath() return self.itemNameWithModelPath end
function Signal:getSignalFunctions() return self.signalFunctions end
function Signal:getActiveFunction() return self.activeFunction end

---@param id number
---@param options table|nil
---@return Signal
function Signal:new(id, options)
    local o = { id = id }
    self.__index = self
    setmetatable(o, self)
    o:refresh(options)
    return o
end

function Signal:refresh(options)
    local opts = options or {}
    local fields = opts.fields or {}
    local position = EEPGetSignal(self.id)
    local waitingVehiclesCount = EEPGetSignalTrainsCount(self.id) or 0

    local tagStr = self.tag or ""
    local stopDistanceVal = self.stopDistance
    local itemNameVal = self.itemName
    local itemNameWithModelPath = self.itemNameWithModelPath
    local signalFunctions = self.signalFunctions
    local activeFunction = self.activeFunction

    if SyncPolicy.shouldCollect(fields.tag) then
        local _, tag = EEPSignalGetTagText(self.id)
        tagStr = tag or ""
    end
    if SyncPolicy.shouldCollect(fields.stopDistance) then
        local ok, sd = EEPGetSignalStopDistance(self.id)
        stopDistanceVal = ok and sd or nil
    end
    if SyncPolicy.shouldCollect(fields.itemName) then
        local ok, name = EEPGetSignalItemName(self.id, false)
        itemNameVal = ok and name or nil
        local okPath, namePath = EEPGetSignalItemName(self.id, true)
        itemNameWithModelPath = okPath and namePath or nil
    end
    if SyncPolicy.shouldCollect(fields.functions) then
        signalFunctions, activeFunction = readFunctions(self.id, position)
    end

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
        self.itemNameWithModelPath = itemNameWithModelPath
        self.signalFunctions = signalFunctions
        self.activeFunction = activeFunction
    end
end

return Signal
