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
local EEPGetSignal = _G.EEPGetSignal or function () return 0 end

local function discoverSignals()
    for i = 1, MAX_SIGNALS do
        if EEPGetSignal(i) > 0 and not SignalRegistry.has(i) then
            SignalRegistry.add(Signal:new(i))
        end
    end
end

function SignalDiscovery.initFromAnl3(tableOfAnl3)
    if not tableOfAnl3 then return end
    if tableOfAnl3.coverage and not tableOfAnl3.coverage.signals then return end

    local signals = {}
    for _, entry in ipairs(tableOfAnl3.signals or {}) do
        if entry.keyId then signals[#signals + 1] = Signal:new(entry.keyId) end
    end
    SignalRegistry.replaceAll(signals)
end

function SignalDiscovery.runInitialDiscovery()
    if not HubOptionsRegistry.isAnyDiscoveryAndUpdateEnabled("signals", "waitingOnSignals") then return end
    discoverSignals()
end

function SignalDiscovery.runDiscovery()
    if not HubOptionsRegistry.isAnyDiscoveryAndUpdateEnabled("signals", "waitingOnSignals") then return end
    discoverSignals()
end

return SignalDiscovery
