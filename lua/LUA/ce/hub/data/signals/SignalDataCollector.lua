if AkDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalDataCollector ...") end

local SignalDataCollector = {}

local MAX_SIGNALS = 1000

local EEPGetSignal = _G.EEPGetSignal or function () end
local EEPSignalGetTagText = _G.EEPSignalGetTagText or function () end
local EEPGetSignalTrainsCount = _G.EEPGetSignalTrainsCount or function () end
local EEPGetSignalTrainName = _G.EEPGetSignalTrainName or function () end
local EEPGetSignalStopDistance = _G.EEPGetSignalStopDistance or function () return false end
local EEPGetSignalItemName = _G.EEPGetSignalItemName or function () return false end
local EEPGetSignalFunctions = _G.EEPGetSignalFunctions or function () return false end
local EEPGetSignalFunction = _G.EEPGetSignalFunction or function () return false end

function SignalDataCollector.collectInitialSignals()
    local signals = {}

    for i = 1, MAX_SIGNALS do
        local val = EEPGetSignal(i)
        if val > 0 then
            table.insert(signals, { id = i })
        end
    end

    return signals
end

function SignalDataCollector.refreshSignals(signals)
    for i = 1, #signals do
        local signal = signals[i]
        signal.position = EEPGetSignal(signal.id)
        local _, tag = EEPSignalGetTagText(signal.id)
        signal.tag = tag or ""
        local waitingVehiclesCount = EEPGetSignalTrainsCount(signal.id)
        signal.waitingVehiclesCount = waitingVehiclesCount or 0

        local stopDistanceOk, stopDistance = EEPGetSignalStopDistance(signal.id)
        signal.stopDistance = stopDistanceOk and stopDistance or nil

        local itemNameOk, itemName = EEPGetSignalItemName(signal.id, false)
        signal.itemName = itemNameOk and itemName or nil

        local itemNameWithModelPathOk, itemNameWithModelPath = EEPGetSignalItemName(signal.id, true)
        signal.itemNameWithModelPath = itemNameWithModelPathOk and itemNameWithModelPath or nil

        local functionsOk, functionCount = EEPGetSignalFunctions(signal.id)
        signal.signalFunctions = nil
        signal.activeFunction = nil
        if functionsOk and functionCount and functionCount > 0 then
            signal.signalFunctions = {}
            for selectionIndex = 1, functionCount do
                local signalFunctionOk, signalFunction = EEPGetSignalFunction(signal.id, selectionIndex)
                if signalFunctionOk then
                    local functionValue = tostring(signalFunction)
                    signal.signalFunctions[#signal.signalFunctions + 1] = functionValue
                    if signal.position == signalFunction then signal.activeFunction = functionValue end
                end
            end
            if #signal.signalFunctions == 0 then signal.signalFunctions = nil end
        end
    end
end

function SignalDataCollector.collectWaitingOnSignals(signals)
    local waitingOnSignals = {}

    for i = 1, #signals do
        local signal = signals[i]
        local waitingVehiclesCount = signal.waitingVehiclesCount

        if waitingVehiclesCount then
            for position = 1, waitingVehiclesCount do
                local vehicleName = EEPGetSignalTrainName(signal.id, position)
                table.insert(waitingOnSignals, {
                    id = signal.id .. "-" .. position,
                    signalId = signal.id,
                    waitingPosition = position,
                    vehicleName = vehicleName or "",
                    waitingCount = waitingVehiclesCount
                })
            end
        end
    end

    return waitingOnSignals
end

return SignalDataCollector
