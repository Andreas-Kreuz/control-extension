if CeDebugLoad then print("[#Start] Loading Bus ...") end

local TrainRegistry = require("ce.hub.data.trains.TrainRegistry")

-----------------------
-- Bushaltestellen
-----------------------
---@class Bus
Bus = {}

--- Oeffnet die Tueren eines Busses (Fahrzeugverband)
-- @param bus Fahrzeugverband
--
function Bus.openDoors(bus)
    assert(bus, "bus wurde nicht angegeben.")
    -- Ikarus Busse und andere?
    local train = TrainRegistry.getOrCreate(bus)
    train:setAxis("Tuer1", 100)
    if (math.random(0, 1) > 0) then train:setAxis("Tuer2", 100) end
    if (math.random(0, 1) > 0) then train:setAxis("Tuer3", 100) end
    if (math.random(0, 1) > 0) then train:setAxis("Tuer4", 100) end
end

--- Schliesst die Tueren eines Busses (Fahrzeugverband)
-- @param bus Fahrzeugverband
--
function Bus.closeDoors(bus)
    assert(bus, "bus wurde nicht angegeben.")
    -- Ikarus Busse und andere?
    local train = TrainRegistry.getOrCreate(bus)
    train:setAxis("Tuer1", 0)
    train:setAxis("Tuer2", 0)
    train:setAxis("Tuer3", 0)
    train:setAxis("Tuer4", 0)
end

--- Schaltet den Fahrer und die Fahrgaeste ein
-- @param fahrzeugverband
--
function Bus.initialisiere(fahrzeugverband)
    local train = TrainRegistry.getOrCreate(fahrzeugverband)
    train:setAxis("Fahrer", 100)
    train:setAxis("Fahrgast", 100)
end

-- luacheck: push ignore FAHRZEUG_INITIALISIERE
--- Funktion fuer den Aufruf direkt in EEP
-- @param fahrzeug wird von EEP automatisch gefuellt
--
function FAHRZEUG_INITIALISIERE(fahrzeug) Bus.initialisiere(fahrzeug) end

-- luacheck: pop
