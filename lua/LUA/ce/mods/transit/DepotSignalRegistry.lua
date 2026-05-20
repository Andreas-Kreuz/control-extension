if CeDebugLoad then print("[#Start] Loading ce.mods.transit.DepotSignalRegistry ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local Signal = require("ce.hub.data.signals.Signal")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local WaitingOnSignalRegistry = require("ce.hub.data.signals.WaitingOnSignalRegistry")

local DepotSignalRegistry = {}
local depotSignalIds = {}
local releasePositionsBySignalId = {}
local interestedTrainBySignalId = {}
local defaultReleasePosition = 2
local INTEREST_SOURCE_PREFIX = "ce.mods.transit.DepotSignalRegistry:"

local function isReleaseFunction(signalFunction)
    local numericFunction = tonumber(signalFunction)
    return numericFunction == 1 or (numericFunction and numericFunction >= 1000)
end

local function detectReleasePosition(signalId)
    if type(_G.EEPGetSignalFunctions) ~= "function" or type(_G.EEPGetSignalFunction) ~= "function" then return nil end

    local functionsOk, functionCount = _G.EEPGetSignalFunctions(signalId)
    if not functionsOk or not functionCount or functionCount == 0 then return nil end

    for selectionIndex = 1, functionCount do
        local functionOk, signalFunction = _G.EEPGetSignalFunction(signalId, selectionIndex)
        if functionOk and isReleaseFunction(signalFunction) then return selectionIndex end
    end

    return nil
end

local function normalizeSignalId(signalId)
    local numericSignalId = tonumber(signalId)
    assert(numericSignalId, "Need 'signalId' as number")
    return numericSignalId
end

function DepotSignalRegistry.register(...)
    local signalIds = { ... }
    for i = 1, #signalIds do
        local signalId = normalizeSignalId(signalIds[i])
        depotSignalIds[signalId] = true
        releasePositionsBySignalId[signalId] = detectReleasePosition(signalId)
        WaitingOnSignalRegistry.watchSignal(signalId)
        if not SignalRegistry.has(signalId) then SignalRegistry.add(Signal:new(signalId)) end
    end
end

function DepotSignalRegistry.getAll()
    local copy = {}
    for signalId in pairs(depotSignalIds) do copy[signalId] = true end
    return copy
end

function DepotSignalRegistry.hasAny()
    return next(depotSignalIds) ~= nil
end

function DepotSignalRegistry.getReleasePosition(signalId)
    signalId = normalizeSignalId(signalId)
    if releasePositionsBySignalId[signalId] then return releasePositionsBySignalId[signalId] end

    releasePositionsBySignalId[signalId] = detectReleasePosition(signalId)
    return releasePositionsBySignalId[signalId] or defaultReleasePosition
end

function DepotSignalRegistry.updateRouteInterests()
    local waitingEntries = {}

    for signalId in pairs(depotSignalIds) do
        local waitingCount = EEPGetSignalTrainsCount(signalId) or 0
        local trainName = waitingCount > 0 and EEPGetSignalTrainName(signalId, 1) or nil
        local previousTrainName = interestedTrainBySignalId[signalId]
        local interestSource = INTEREST_SOURCE_PREFIX .. tostring(signalId)

        if previousTrainName and previousTrainName ~= trainName then
            InterestSyncRegistry.stopSyncForSource(HubCeTypes.Train, previousTrainName, interestSource)
        end

        if trainName and trainName ~= "" then
            InterestSyncRegistry.startSyncForSource(HubCeTypes.Train, trainName, interestSource)
            interestedTrainBySignalId[signalId] = trainName
            waitingEntries[#waitingEntries + 1] = {
                id = tostring(signalId) .. "-1",
                signalId = signalId,
                waitingPosition = 1,
                vehicleName = trainName,
                waitingCount = waitingCount
            }
        else
            interestedTrainBySignalId[signalId] = nil
        end
    end

    WaitingOnSignalRegistry.setForSignals(waitingEntries, depotSignalIds)
end

return DepotSignalRegistry
