local Line = require("ce.mods.transit.Line")
local LineRegistry = {}
local allLines = {}

function LineRegistry.get(id)
    return allLines[id]
end

---Creates a line object for the given line name, the line must exist
---@param id string name of the line in EEP, e.g. "10" or "A1"
---@return Line,boolean returns the line and the status if the line was newly created
function LineRegistry.getOrCreate(id)
    assert(id, "Provide a name for the line")
    assert(type(id) == "string", "Need 'lineName' as string")
    if allLines[id] then
        return allLines[id], false
    else
        -- Initialize the line
        local line = Line:new({ nr = id })
        allLines[line.id] = line
        return line, true
    end
end

---A line appeared on the map
function LineRegistry.lineAppeared(_)
    -- is included in "LineRegistry.fireChangeLinesEvent()"
end

---A line dissappeared from the map
---@param lineName string
function LineRegistry.lineDisappeared(lineName)
    allLines[lineName] = nil
    -- DataChangeBus.fireDataRemoved("lines", "id", {id = lineName})
end

function LineRegistry.fireChangeLinesEvent()
    require("ce.mods.transit.data.TransitLinePublisher").syncLineNames()
end

return LineRegistry
