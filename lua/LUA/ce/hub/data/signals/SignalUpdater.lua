if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalUpdater ...") end

local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local SignalUpdater = {}

local EEPGetSignal = _G.EEPGetSignal or function () return 0 end
local EEPSignalGetTagText = _G.EEPSignalGetTagText or function () return false, nil end
local EEPGetSignalTrainsCount = _G.EEPGetSignalTrainsCount or function () return 0 end
local EEPGetSignalStopDistance = _G.EEPGetSignalStopDistance or function () return false, nil end
local EEPGetSignalItemName = _G.EEPGetSignalItemName or function () return false, nil end
local EEPGetSignalFunctions = _G.EEPGetSignalFunctions or function () return false, 0 end
local EEPGetSignalFunction = _G.EEPGetSignalFunction or function () return false, nil end

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

function SignalUpdater.runUpdate()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")
    if not HubOptionsRegistry.isAnyDiscoveryAndUpdateEnabled("signals", "waitingOnSignals") then return end
    local fields = HubOptionsRegistry.getFieldUpdatePolicies("signals")

    for _, signal in pairs(SignalRegistry.getAll()) do
        local isSelected = DynamicUpdateRegistry.isSelected(HubCeTypes.Signal, tostring(signal.id))
        local position = EEPGetSignal(signal.id)
        signal:setPosition(position)
        signal:setWaitingVehiclesCount(EEPGetSignalTrainsCount(signal.id) or 0)

        if SyncPolicy.shouldUpdateField(fields, "tag", isSelected) then
            local _, tag = EEPSignalGetTagText(signal.id)
            signal:setTag(tag or "")
        end
        if SyncPolicy.shouldUpdateField(fields, "stopDistance", isSelected) then
            local ok, stopDistance = EEPGetSignalStopDistance(signal.id)
            signal:setStopDistance(ok and stopDistance or nil)
        end
        if SyncPolicy.shouldUpdateField(fields, "itemName", isSelected) then
            local ok, itemName = EEPGetSignalItemName(signal.id, false)
            local okPath, itemNameWithModelPath = EEPGetSignalItemName(signal.id, true)
            signal:setItemName(ok and itemName or nil, okPath and itemNameWithModelPath or nil)
        end
        if SyncPolicy.shouldUpdateField(fields, "functions", isSelected) then
            local signalFunctions, activeFunction = readFunctions(signal.id, position)
            signal:setFunctions(signalFunctions, activeFunction)
        end
    end
end

return SignalUpdater
