if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalDiscovery ...") end

local Signal = require("ce.hub.data.signals.Signal")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

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

    for _, entry in ipairs(tableOfAnl3.signals or {}) do
        if entry.keyId and not SignalRegistry.has(entry.keyId) then
            SignalRegistry.add(Signal:new(entry.keyId))
        end
    end
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
