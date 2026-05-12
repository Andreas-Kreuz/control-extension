if CeDebugLoad then print("[#Start] Loading ce.mods.transit.DepotSignalRegistry ...") end

local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
local Signal = require("ce.hub.data.signals.Signal")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local WaitingOnSignalRegistry = require("ce.hub.data.signals.WaitingOnSignalRegistry")

local DepotSignalRegistry = {}
local depotSignalIds = {}
local releasePositionsBySignalId = {}
local defaultReleasePosition = 2

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

local function ensureOptionPath(options, ...)
    local current = options
    for i = 1, select("#", ...) do
        local key = select(i, ...)
        current[key] = current[key] or {}
        current = current[key]
    end
    return current
end

local function forceHubOptions()
    local options = HubOptionsRegistry.getAllOptions()
    local trainFieldUpdates = ensureOptionPath(options, "ceTypes", "trains", "fieldUpdates")
    trainFieldUpdates.route = "always"

    local waitingFieldUpdates = ensureOptionPath(options, "ceTypes", "waitingOnSignals", "fieldUpdates")
    waitingFieldUpdates.vehicleName = "always"

    HubOptionsRegistry.setOptions(options)
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
    if #signalIds > 0 then forceHubOptions() end
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

function DepotSignalRegistry.forceHubOptions()
    if DepotSignalRegistry.hasAny() then forceHubOptions() end
end

return DepotSignalRegistry
