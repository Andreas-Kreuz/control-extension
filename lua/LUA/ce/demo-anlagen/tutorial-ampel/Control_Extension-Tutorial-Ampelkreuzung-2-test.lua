if CeDebugLoad then print("[#Start] Loading AkEepFunctions ...") end
local EepSimulator = require("ce.hub.eep.EepSimulator")

local Scheduler = require("ce.hub.scheduler.Scheduler")
local TrafficLight = require("ce.mods.road.TrafficLight")
local Intersection = require("ce.mods.road.Intersection")
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
local StorageUtility = require("ce.hub.util.StorageUtility")

clearlog()
--------------------------------------------------------------------
-- Zeigt erweiterte Informationen waehrend der Initialisierung an --
--------------------------------------------------------------------
CeStartWithDebug = false

-- Ampeln für die Straßenbahn nutzen die Lichtfunktion der einzelnen Immobilien
EEPStructureSetLight("#29_Straba Signal Halt", false)      -- rot
EEPStructureSetLight("#28_Straba Signal geradeaus", false) -- gruen
EEPStructureSetLight("#27_Straba Signal anhalten", false)  -- gelb
EEPStructureSetLight("#26_Straba Signal A", false)         -- Anforderung
EEPStructureSetLight("#32_Straba Signal Halt", false)      -- rot
EEPStructureSetLight("#30_Straba Signal geradeaus", false) -- gruen
EEPStructureSetLight("#31_Straba Signal anhalten", false)  -- gelb
EEPStructureSetLight("#33_Straba Signal A", false)         -- Anforderung

--------------------------------------------------------------------
-- Zeigt erweiterte Informationen waehrend der erste Schitte an   --
--------------------------------------------------------------------
if CeDebugLoad then
    print("[#Start] Loading ce.demo-anlagen.tutorial-ampel.Control_Extension-Tutorial-Ampelkreuzung-2-main ...")
end
require("ce.demo-anlagen.tutorial-ampel.Control_Extension-Tutorial-Ampelkreuzung-2-main")

--------------------------------------------------------------------
-- Zeige erweiterte Informationen an                              --
--------------------------------------------------------------------
Scheduler.debug = true
StorageUtility.debug = true
TrafficLight.debug = false
Intersection.debug = false
IntersectionSettings.showSignalIdOnSignal = false
IntersectionSettings.showRequestsOnSignal = true
IntersectionSettings.showPhaseOnSignal = true

--------------------------------------------------------------------
-- Erste Hilfe - normalerweise nicht notwendig                    --
--------------------------------------------------------------------
-- Intersection.resetVehicles()

-------------------------------------------------------------------
-- Intersection.debug = true
-------------------------------------------------------------------
local function run()
    EEPTime = EEPTime + 20
    EEPMain()
end

EepSimulator.simulateQueueTrainOnSignal(14, "#Zug1")
EEPSetTrainRoute("#Zug1", "Meine Route 1")

local signalLane = os
---@cast signalLane Lane
assert(true == signalLane.signalUsedForRequest)
signalLane:resetQueueFromSignal()
assert(1 == signalLane.queue:size())

for i = 1, 10 do
    print(string.format("[#Test] run nr. %s", i))
    run()
    run()
    run()
    run()
    run()
end
