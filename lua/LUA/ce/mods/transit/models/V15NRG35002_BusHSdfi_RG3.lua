-- V15NRG35002 - Buswartehaeuser in Dioramaqualitaet mit DFI
local TransitSettings = require("ce.mods.transit.TransitSettings")
local RoadStationTippHelper = require("ce.hub.util.RoadStationTippHelper")
local StructureTextureTextCache = require("ce.mods.transit.models.StructureTextureTextCache")

local BusHSdfi_RG3 = {}

BusHSdfi_RG3.name = "BusHSdfi_RG3"

BusHSdfi_RG3.initStation = function (displayStructure, stationName, platform)
    assert(type(displayStructure) == "string", "Need 'displayStructure' as string not as " .. type(displayStructure))
    assert(type(stationName) == "string", "Need 'stationName' as string")
    assert(type(platform) == "string", "Need 'platform' as string")
    StructureTextureTextCache.reset(displayStructure)
    StructureTextureTextCache.set(displayStructure, 1, "")
    StructureTextureTextCache.set(displayStructure, 2, "")
    StructureTextureTextCache.set(displayStructure, 3, "")
    StructureTextureTextCache.set(displayStructure, 4, "")
    StructureTextureTextCache.set(displayStructure, 5, "")
    StructureTextureTextCache.set(displayStructure, 6, "")
    StructureTextureTextCache.set(displayStructure, 7, "")
end

BusHSdfi_RG3.displayEntries = function (displayStructure, stationQueueEntries, stationName, platform)
    assert(type(displayStructure) == "string", "Need 'displayStructure' as string not as " .. type(displayStructure))
    assert(type(stationQueueEntries) == "table",
           "Need 'stationQueueEntries' as table not as " .. type(stationQueueEntries))
    assert(type(stationName) == "string", "Need 'stationName' as string")
    assert(type(platform) == "string", "Need 'platform' as string")

    -- Set the first entry
    local entry = stationQueueEntries[1]
    StructureTextureTextCache.set(displayStructure, 1, entry and (entry.line .. " " .. entry.destination) or "")
    StructureTextureTextCache.set(displayStructure, 3,
                                  (entry and entry.timeInMinutes > 0) and tostring(entry.timeInMinutes) or "")
    StructureTextureTextCache.set(displayStructure, 7, (entry and entry.timeInMinutes > 0) and "min" or "")

    -- Set the second entry
    entry = stationQueueEntries[2]
    StructureTextureTextCache.set(displayStructure, 2, entry and (entry.line .. " " .. entry.destination) or "")
    StructureTextureTextCache.set(displayStructure, 4,
                                  (entry and entry.timeInMinutes > 0) and tostring(entry.timeInMinutes) or "")
    StructureTextureTextCache.set(displayStructure, 8, (entry and entry.timeInMinutes > 0) and "min" or "")

    local text = { RoadStationTippHelper.getTitle(stationName, platform) }
    for i = 1, 2 do
        entry = stationQueueEntries[i]
        table.insert(text, RoadStationTippHelper.getEntry(entry))
    end

    local t = table.concat(text, "")
    EEPChangeInfoStructure(displayStructure, t)
    EEPShowInfoStructure(displayStructure, TransitSettings.showDepartureTippText)
end

return BusHSdfi_RG3
