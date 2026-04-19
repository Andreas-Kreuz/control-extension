local fmt = require("ce.hub.eep.TippTextFormatter")

-- Simple Structure - works with any model
local RoadStationTippHelper = {}

RoadStationTippHelper.getTitle = function (stationName, platform)
    assert(type(stationName) == "string", "Need 'stationName' as string")
    assert(type(platform) == "string", "Need 'platform' as string")
    local text = {
        "</j><b>", stationName, "</b>", " (Steig ", platform, ")", "<br>_____<b>min| Linie Ziel</b><br>"
    }
    return table.concat(text, "")
end

RoadStationTippHelper.getEntry = function (entry)
    assert(not entry or type(entry) == "table", "Need 'stationQueueEntries' as table not as " .. type(entry))

    local text = {}
    local minutes = "_____"
    if (entry) then
        minutes = ""
        for _ = 1, math.min(5, entry.timeInMinutes) do minutes = minutes .. "_" end
        table.insert(text, fmt.bgBlue(minutes))
        minutes = ""
        for _ = entry.timeInMinutes + 1, 5 do minutes = minutes .. "_" end
    end
    table.insert(text, minutes)
    table.insert(text, " ")
    table.insert(text, (entry and entry.timeInMinutes < 10 and entry.timeInMinutes > 0) and "  " or "")
    table.insert(text, (entry and entry.timeInMinutes > 0) and tostring(entry.timeInMinutes) or "  --")
    table.insert(text, " ")
    table.insert(text, (entry and entry.timeInMinutes > 0) and "" or "")
    table.insert(text, " | ")
    table.insert(text, (entry and string.len(entry.line) < 2) and "  " or "")
    table.insert(text, entry and entry.line or " ")
    table.insert(text, " ")
    table.insert(text, entry and entry.destination or "-----")
    table.insert(text, "<br>")
    return table.concat(text, "")
end

return RoadStationTippHelper
