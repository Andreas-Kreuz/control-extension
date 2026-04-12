if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitDataCollector ...") end
local Line = require("ce.mods.transit.Line")
local RoadStation = require("ce.mods.transit.RoadStation")
local TransitSettings = require("ce.mods.transit.TransitSettings")

local TransitDataCollector = {}

function TransitDataCollector.collectModuleSettings()
    return {
        {
            category = "Tipp-Texte fuer Anzeigetafeln",
            name = "Naechste Abfahrten",
            description = "Zeige Abfahrten fuer Bus und Tram-Linien als TippText an",
            type = "boolean",
            value = TransitSettings.showDepartureTippText,
            eepFunction = "TransitSettings.setShowDepartureTippText"
        }
    }
end

function TransitDataCollector.collectTransitData()
    return {
        publicTransportStations = RoadStation.getAll(),
        publicTransportLines = Line.getLines(),
        publicTransportSettings = TransitDataCollector.collectModuleSettings()
    }
end

return TransitDataCollector
