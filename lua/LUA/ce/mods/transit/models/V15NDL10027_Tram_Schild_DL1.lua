local TransitSettings = require("ce.mods.transit.TransitSettings")
local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
local RoadStationTippHelper = require("ce.hub.util.RoadStationTippHelper")
local StructureTextureTextCache = require("ce.mods.transit.models.StructureTextureTextCache")

-- V15NDL10027 - Texturierbare Zielanzeigen für Haltestellen
local Tram_Schild_DL1 = {}

Tram_Schild_DL1.name = "Tram_Schild_DL1"

-- DL1 Model
Tram_Schild_DL1.initStation = function (displayStructure, stationName, platform)
    assert(type(displayStructure) == "string", "Need 'displayStructure' as string not as " .. type(displayStructure))
    assert(type(stationName) == "string", "Need 'stationName' as string")
    assert(type(platform) == "string", "Need 'platform' as string")

    StructureTextureTextCache.reset(displayStructure)
    StructureTextureTextCache.set(displayStructure, 21, stationName)
    StructureTextureTextCache.set(displayStructure, 24, "Steig " .. platform)
end

Tram_Schild_DL1.displayEntries = function (displayStructure, stationQueueEntries, stationName, platform)
    assert(type(displayStructure) == "string", "Need 'displayStructure' as string not as " .. type(displayStructure))
    assert(type(stationQueueEntries) == "table",
           "Need 'stationQueueEntries' as table not as " .. type(stationQueueEntries))
    assert(type(stationName) == "string", "Need 'stationName' as string")
    assert(type(platform) == "string", "Need 'platform' as string")

    local text = { RoadStationTippHelper.getTitle(stationName, platform) }

    for i = 1, 5 do
        local offset = (i - 1) * 4
        ---@type StationQueueEntry
        local entry = stationQueueEntries[i]
        StructureTextureTextCache.set(displayStructure, offset + 1, entry and entry.line or "")
        StructureTextureTextCache.set(displayStructure, offset + 2, entry and entry.destination or "")
        StructureTextureTextCache.set(displayStructure, offset + 3,
                                      (entry and entry.timeInMinutes > 0) and tostring(entry.timeInMinutes) or "")
        StructureTextureTextCache.set(displayStructure, offset + 4, (entry and entry.timeInMinutes > 0) and "min" or "")

        table.insert(text, RoadStationTippHelper.getEntry(entry))
    end

    local t = table.concat(text, "")
    local structure = StructureRegistry.getOrCreate(displayStructure)
    structure:changeInfo(t)
    structure:setLight(true)
    structure:showInfo(TransitSettings.showDepartureTippText)
end

return Tram_Schild_DL1
