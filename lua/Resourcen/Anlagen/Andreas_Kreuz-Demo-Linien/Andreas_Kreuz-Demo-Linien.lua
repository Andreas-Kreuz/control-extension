clearlog()
require("ce.demo-anlagen.demo-linien.demo-linien-main")

-- Diese Zeile lädt den Einstiegspunkt der Lua-Bibliothek
local ControlExtension = require("ce.ControlExtension")

-- Diese Zeilen registrieren die folgenden Module
-- * Hub (immer benötigt)
-- * Intersection (für die Ampelsteuerung notwendig)
-- * Transit (für den ÖPNV notwendig)
ControlExtension.addModules(require("ce.hub.CeHubModule"),
                            require("ce.mods.road.CeRoadModule"),
                            require("ce.mods.transit.CeTransitModule"))

-- Die EEPMain Methode wird von EEP genutzt. Sie muss immer 1 zurückgeben.
function EEPMain()
    -- ControlExtension startet die Aufgaben in allen Modulen bei jedem fünften EEPMain-Aufruf
    ControlExtension.runTasks(5)
    return 1
end

-- Nutze einen Speicherslot in EEP um die Einstellungen für Kreuzungen zu laden und zu speichern
-- Intersection.loadSettingsFromSlot(1)
