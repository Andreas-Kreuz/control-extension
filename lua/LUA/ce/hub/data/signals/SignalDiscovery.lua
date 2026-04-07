if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalDiscovery ...") end

local Signal = require("ce.hub.data.signals.Signal")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")

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

function SignalDiscovery.runInitialDiscovery()
    discoverSignals()
end

function SignalDiscovery.runDiscovery()
    discoverSignals()
end

return SignalDiscovery
