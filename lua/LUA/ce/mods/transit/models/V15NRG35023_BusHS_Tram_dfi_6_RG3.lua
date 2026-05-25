local TransitSettings = require("ce.mods.transit.TransitSettings")
local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
local RoadStationTippHelper = require("ce.hub.util.RoadStationTippHelper")
local StructureTextureTextCache = require("ce.mods.transit.models.StructureTextureTextCache")

-- V15NRG35023 - DFI digitale Fahrgastinformation für 6 Linien
BusHS_Tram_dfi_6_RG3 = {}

BusHS_Tram_dfi_6_RG3.name = "BusHS_Tram_dfi_6_RG3"

BusHS_Tram_dfi_6_RG3.initStation = function (displayStructure, stationName, platform)
    assert(type(displayStructure) == "string", "Need 'displayStructure' as string not as " .. type(displayStructure))
    assert(type(stationName) == "string", "Need 'stationName' as string")
    assert(type(platform) == "string", "Need 'platform' as string")
    StructureTextureTextCache.reset(displayStructure)
    for i = 1, 20 do StructureTextureTextCache.set(displayStructure, i, "") end
end

BusHS_Tram_dfi_6_RG3.displayEntries = function (displayStructure, stationQueueEntries, stationName, platform)
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

    -- Set the second entry
    entry = stationQueueEntries[3]
    StructureTextureTextCache.set(displayStructure, 9, entry and (entry.line .. " " .. entry.destination) or "")
    StructureTextureTextCache.set(displayStructure, 13,
                                  (entry and entry.timeInMinutes > 0) and tostring(entry.timeInMinutes) or "")
    StructureTextureTextCache.set(displayStructure, 17, (entry and entry.timeInMinutes > 0) and "min" or "")

    -- Set the second entry
    entry = stationQueueEntries[4]
    StructureTextureTextCache.set(displayStructure, 10, entry and (entry.line .. " " .. entry.destination) or "")
    StructureTextureTextCache.set(displayStructure, 14,
                                  (entry and entry.timeInMinutes > 0) and tostring(entry.timeInMinutes) or "")
    StructureTextureTextCache.set(displayStructure, 18, (entry and entry.timeInMinutes > 0) and "min" or "")

    -- Set the second entry
    entry = stationQueueEntries[5]
    StructureTextureTextCache.set(displayStructure, 11, entry and (entry.line .. " " .. entry.destination) or "")
    StructureTextureTextCache.set(displayStructure, 15,
                                  (entry and entry.timeInMinutes > 0) and tostring(entry.timeInMinutes) or "")
    StructureTextureTextCache.set(displayStructure, 19, (entry and entry.timeInMinutes > 0) and "min" or "")

    -- Set the second entry
    entry = stationQueueEntries[6]
    StructureTextureTextCache.set(displayStructure, 12, entry and (entry.line .. " " .. entry.destination) or "")
    StructureTextureTextCache.set(displayStructure, 16,
                                  (entry and entry.timeInMinutes > 0) and tostring(entry.timeInMinutes) or "")
    StructureTextureTextCache.set(displayStructure, 20, (entry and entry.timeInMinutes > 0) and "min" or "")

    local text = { RoadStationTippHelper.getTitle(stationName, platform) }
    for i = 1, 6 do
        entry = stationQueueEntries[i]
        table.insert(text, RoadStationTippHelper.getEntry(entry))
    end

    local t = table.concat(text, "")
    local structure = StructureRegistry.getOrCreate(displayStructure)
    structure:changeInfo(t)
    structure:showInfo(TransitSettings.showDepartureTippText)
end

return BusHS_Tram_dfi_6_RG3
