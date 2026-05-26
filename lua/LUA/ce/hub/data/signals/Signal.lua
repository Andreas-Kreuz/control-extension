if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.Signal ...") end

local DataClass = require("ce.hub.data.DataClass")

---@class Signal
---@field id number
---@field position number
---@field tag string
---@field tippText string
---@field tippTextVisible boolean
---@field waitingVehiclesCount number
---@field stopDistance number|nil
---@field itemName string|nil
---@field itemNameWithModelPath string|nil
---@field signalFunctions string[]|nil
---@field activeFunction string|nil
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local Signal = {}

function Signal:new(id)
    local o = {
        id = id,
        position = 0,
        tag = "",
        tippText = "",
        tippTextVisible = false,
        waitingVehiclesCount = 0,
        stopDistance = nil,
        itemName = nil,
        itemNameWithModelPath = nil,
        signalFunctions = nil,
        activeFunction = nil,
        dirtyFields = {},
        needsFullSend = true
    }
    self.__index = self
    setmetatable(o, self)
    DataClass.init(o)
    return o
end

function Signal.exists(id)
    if not DataClass.isCallable(_G.EEPGetSignal) then return false end
    return (_G.EEPGetSignal(id) or 0) > 0
end

function Signal:peekPosition() return self.position end

function Signal:getPosition()
    if not DataClass.isLoaded(self, "position") then return self:pullPosition() end
    return self.position
end

function Signal:peekTag() return self.tag end

function Signal:getTag()
    if not DataClass.isLoaded(self, "tag") then return self:pullTag() end
    return self.tag
end

function Signal:peekWaitingVehiclesCount() return self.waitingVehiclesCount end

function Signal:getWaitingVehiclesCount()
    if not DataClass.isLoaded(self, "waitingVehiclesCount") then return self:pullWaitingVehiclesCount() end
    return self.waitingVehiclesCount
end

function Signal:peekStopDistance() return self.stopDistance end

function Signal:getStopDistance()
    if not DataClass.isLoaded(self, "stopDistance") then return self:pullStopDistance() end
    return self.stopDistance
end

function Signal:peekItemName() return self.itemName end

function Signal:getItemName()
    if not DataClass.isLoaded(self, "itemName") then self:pullItemName() end
    return self.itemName
end

function Signal:peekItemNameWithModelPath() return self.itemNameWithModelPath end

function Signal:getItemNameWithModelPath()
    if not DataClass.isLoaded(self, "itemNameWithModelPath") then self:pullItemName() end
    return self.itemNameWithModelPath
end

function Signal:peekSignalFunctions() return self.signalFunctions end

function Signal:getSignalFunctions()
    if not DataClass.isLoaded(self, "signalFunctions") then self:pullFunctions() end
    return self.signalFunctions
end

function Signal:getFunctions()
    return self:getSignalFunctions()
end

function Signal:peekActiveFunction() return self.activeFunction end

function Signal:getActiveFunction()
    if not DataClass.isLoaded(self, "activeFunction") then self:pullFunctions() end
    return self.activeFunction
end

function Signal:replacePosition(position)
    DataClass.replaceField(self, "position", position or 0)
end

function Signal:seedPosition(position)
    self:replacePosition(position)
end

function Signal:setPosition(position, callback)
    local value = position or 0
    if self.position == value then return true end
    local ok = true
    if _G.EEPSetSignal then
        if callback == false then
            ok = _G.EEPSetSignal(self.id, value) ~= false
        else
            ok = _G.EEPSetSignal(self.id, value, 1) ~= false
        end
    end
    if ok then self:replacePosition(value) end
    return ok
end

function Signal:pullPosition()
    if not DataClass.isCallable(_G.EEPGetSignal) then return nil end
    local position = _G.EEPGetSignal(self.id)
    if not position or position <= 0 then return nil end
    self:replacePosition(position)
    return self.position
end

function Signal:replaceTag(tag)
    DataClass.replaceField(self, "tag", tag or "")
end

function Signal:seedTag(tag)
    self:replaceTag(tag)
end

function Signal:setTag(tag)
    local value = tag or ""
    if self.tag == value then return true end
    local ok = true
    if _G.EEPSignalSetTagText then ok = _G.EEPSignalSetTagText(self.id, value) ~= false end
    if ok then self:replaceTag(value) end
    return ok
end

function Signal:pullTag()
    if not DataClass.isCallable(_G.EEPSignalGetTagText) then return nil end
    local ok, tag = _G.EEPSignalGetTagText(self.id)
    if not ok then return nil end
    self:replaceTag(tag or "")
    return self.tag
end

function Signal:replaceWaitingVehiclesCount(waitingVehiclesCount)
    local value = waitingVehiclesCount or 0
    DataClass.replaceField(self, "waitingVehiclesCount", value)
end

function Signal:setWaitingVehiclesCount(waitingVehiclesCount)
    self:replaceWaitingVehiclesCount(waitingVehiclesCount)
end

function Signal:pullWaitingVehiclesCount()
    if not DataClass.isCallable(_G.EEPGetSignalTrainsCount) then return nil end
    self:replaceWaitingVehiclesCount(_G.EEPGetSignalTrainsCount(self.id) or 0)
    return self.waitingVehiclesCount
end

function Signal:pullWaitingVehicleName(waitingPosition)
    if not DataClass.isCallable(_G.EEPGetSignalTrainName) then return nil end
    return _G.EEPGetSignalTrainName(self.id, waitingPosition)
end

function Signal:pullTrainNames()
    if not DataClass.isCallable(_G.EEPGetSignalTrainsCount)
        or not DataClass.isCallable(_G.EEPGetSignalTrainName) then
        return {}
    end

    local waitingCount = _G.EEPGetSignalTrainsCount(self.id) or 0
    self:replaceWaitingVehiclesCount(waitingCount)

    local trainNames = {}
    for waitingPosition = 1, waitingCount do
        local trainName = _G.EEPGetSignalTrainName(self.id, waitingPosition)
        if trainName and trainName ~= "" then trainNames[#trainNames + 1] = trainName end
    end
    return trainNames
end

function Signal:replaceStopDistance(stopDistance)
    DataClass.replaceField(self, "stopDistance", stopDistance)
end

function Signal:seedStopDistance(stopDistance)
    self:replaceStopDistance(stopDistance)
end

function Signal:setStopDistance(stopDistance)
    self:replaceStopDistance(stopDistance)
end

function Signal:pullStopDistance()
    if not DataClass.isCallable(_G.EEPGetSignalStopDistance) then return nil end
    local ok, stopDistance = _G.EEPGetSignalStopDistance(self.id)
    self:replaceStopDistance(ok and stopDistance or nil)
    return self.stopDistance
end

function Signal:replaceItemName(itemName, itemNameWithModelPath)
    DataClass.replaceField(self, "itemName", itemName)
    DataClass.replaceField(self, "itemNameWithModelPath", itemNameWithModelPath)
end

function Signal:seedItemName(itemName, itemNameWithModelPath)
    self:replaceItemName(itemName, itemNameWithModelPath)
end

function Signal:setItemName(itemName, itemNameWithModelPath)
    self:replaceItemName(itemName, itemNameWithModelPath)
end

function Signal:pullItemName()
    if not DataClass.isCallable(_G.EEPGetSignalItemName) then return nil, nil end
    local ok, itemName = _G.EEPGetSignalItemName(self.id, false)
    local okPath, itemNameWithModelPath = _G.EEPGetSignalItemName(self.id, true)
    self:replaceItemName(ok and itemName or nil, okPath and itemNameWithModelPath or nil)
    return self.itemName, self.itemNameWithModelPath
end

function Signal:replaceFunctions(signalFunctions, activeFunction)
    local currentFunctions = self.signalFunctions or {}
    local changed = #currentFunctions ~= #(signalFunctions or {})
    if not changed then
        for i = 1, #currentFunctions do
            if currentFunctions[i] ~= signalFunctions[i] then
                changed = true
                break
            end
        end
    end
    DataClass.markLoaded(self, "signalFunctions")
    if changed then
        self.signalFunctions = signalFunctions
        DataClass.markDirty(self, "signalFunctions")
    end
    DataClass.replaceField(self, "activeFunction", activeFunction)
end

function Signal:setFunctions(signalFunctions, activeFunction)
    self:replaceFunctions(signalFunctions, activeFunction)
end

function Signal:pullFunctions()
    if not DataClass.isCallable(_G.EEPGetSignalFunctions) or not DataClass.isCallable(_G.EEPGetSignalFunction) then
        return nil, nil
    end
    local functionsOk, functionCount = _G.EEPGetSignalFunctions(self.id)
    if not functionsOk or not functionCount or functionCount == 0 then
        self:replaceFunctions(nil, nil)
        return nil, nil
    end

    local fns = {}
    local activeFunction = nil
    for selIndex = 1, functionCount do
        local ok, fn = _G.EEPGetSignalFunction(self.id, selIndex)
        if ok then
            local fnValue = tostring(fn)
            fns[#fns + 1] = fnValue
            if self.position == fn then activeFunction = fnValue end
        end
    end

    self:replaceFunctions(#fns > 0 and fns or nil, activeFunction)
    return self.signalFunctions, self.activeFunction
end

function Signal:peekTippText() return self.tippText end

function Signal:getTippText() return self.tippText end

function Signal:peekTippTextVisible() return self.tippTextVisible end

function Signal:getTippTextVisible() return self.tippTextVisible end

function Signal:seedTippText(text)
    DataClass.replaceField(self, "tippText", text or "")
end

function Signal:seedTippTextVisible(visible)
    DataClass.replaceField(self, "tippTextVisible", visible == true)
end

function Signal:setTippText(text)
    return self:changeInfo(text)
end

function Signal:showTippText(visible)
    return self:showInfo(visible)
end

function Signal:changeInfo(text)
    local value = text or ""
    if DataClass.isLoaded(self, "tippText") and self.tippText == value then return true end

    local ok = true
    if _G.EEPChangeInfoSignal then ok = _G.EEPChangeInfoSignal(self.id, value) ~= false end
    if ok then
        self.tippText = value
        DataClass.markLoaded(self, "tippText")
    end
    return ok
end

function Signal:showInfo(visible)
    local value = visible == true
    if DataClass.isLoaded(self, "tippTextVisible") and self.tippTextVisible == value then return true end

    local ok = true
    if _G.EEPShowInfoSignal then ok = _G.EEPShowInfoSignal(self.id, value) ~= false end
    if ok then
        self.tippTextVisible = value
        DataClass.markLoaded(self, "tippTextVisible")
    end
    return ok
end

function Signal.setTippTextById(signalId, text)
    local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
    local signal = SignalRegistry.get(signalId)
    if signal then
        signal:changeInfo(text)
    elseif _G.EEPChangeInfoSignal then
        _G.EEPChangeInfoSignal(signalId, text or "")
    end
end

function Signal.showTippTextById(signalId, visible)
    local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
    local signal = SignalRegistry.get(signalId)
    if signal then
        signal:showInfo(visible)
    elseif _G.EEPShowInfoSignal then
        _G.EEPShowInfoSignal(signalId, visible == true)
    end
end

function Signal:resetDirty()
    DataClass.resetDirty(self)
end

function Signal:hasDirtyFields()
    return DataClass.hasDirtyFields(self)
end

return Signal
