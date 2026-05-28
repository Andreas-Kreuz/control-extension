if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitLinePublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local Line = require("ce.mods.transit.Line")
local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitLineDtoFactory = require("ce.mods.transit.data.TransitLineDtoFactory")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")

local TransitLinePublisher = {}

local function isSelectedLine(line)
    return InterestSyncRegistry.isSelected(TransitCeTypes.Line, tostring(line.id or line.nr))
end

local function isSelectedLineName(line)
    return InterestSyncRegistry.isSelected(TransitCeTypes.LineName, tostring(line.id or line.nr))
end

function TransitLinePublisher.syncLines()
    if not TransitOptionsRegistry.isPublishEnabled("lines") then return end

    DataChangeBus.fireListChange(TransitLineDtoFactory.createDtoList(Line.getAll(), isSelectedLine))
end

function TransitLinePublisher.syncLineNames()
    if not TransitOptionsRegistry.isPublishEnabled("lineNames") then return end

    local modifiedLines = {}
    for _, line in pairs(Line.getAll()) do
        if line.valuesUpdated then
            modifiedLines[line.id] = line
            line.valuesUpdated = false
        end
    end
    DataChangeBus.fireListChange(TransitLineDtoFactory.createLineNameDtoList(modifiedLines, isSelectedLineName))
end

function TransitLinePublisher.syncState()
    TransitLinePublisher.syncLines()
    TransitLinePublisher.syncLineNames()
end

return TransitLinePublisher
