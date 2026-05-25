if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalDiscovery ...") end

local Signal = require("ce.hub.data.signals.Signal")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

---@class SignalDiscovery
---@field initFromAnl3 fun(tableOfAnl3: table|nil):nil
---@field runInitialDiscovery fun():nil
---@field runDiscovery fun():nil
local SignalDiscovery = {}

local MAX_SIGNALS = 1000

local function discoverSignals()
    local discoveredIds = {}
    for i = 1, MAX_SIGNALS do
        if Signal.exists(i) then
            discoveredIds[i] = true
            if not SignalRegistry.has(i) then SignalRegistry.add(Signal:new(i)) end
        end
    end

    for signalId in pairs(SignalRegistry.getAll()) do
        if not discoveredIds[signalId] then SignalRegistry.remove(signalId) end
    end
end

function SignalDiscovery.initFromAnl3(tableOfAnl3)
    if not tableOfAnl3 then return end
    if tableOfAnl3.coverage and not tableOfAnl3.coverage.signals then return end

    local signals = {}
    for _, entry in ipairs(tableOfAnl3.signals or {}) do
        if entry.keyId then
            local signal = Signal:new(entry.keyId)
            signal:seedTag(entry.tag or "")
            if entry.tipTxt ~= nil then signal:seedTippText(entry.tipTxt) end
            if entry.tipShow ~= nil then signal:seedTippTextVisible(entry.tipShow) end
            signals[#signals + 1] = signal
        end
    end
    SignalRegistry.replaceAll(signals)
end

function SignalDiscovery.runInitialDiscovery()
    if not HubOptionsRegistry.isAnyDiscoveryAndUpdateEnabled("signals", "waitingOnSignals") then return end
    discoverSignals()
end

function SignalDiscovery.runDiscovery()
    -- do nothing
end

return SignalDiscovery
