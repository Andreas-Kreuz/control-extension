if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitLinePublisher ...") end

local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local IncrementalListPublisher = require("ce.hub.publish.IncrementalListPublisher")
local Line = require("ce.mods.transit.Line")
local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitLineDtoFactory = require("ce.mods.transit.data.TransitLineDtoFactory")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")

local TransitLinePublisher = {}
local linePublisher = IncrementalListPublisher:new()
local lineNamePublisher = IncrementalListPublisher:new()

local function isSelectedLine(line)
    return InterestSyncRegistry.isSelected(TransitCeTypes.Line, tostring(line.id or line.nr))
end

local function isSelectedLineName(line)
    return InterestSyncRegistry.isSelected(TransitCeTypes.LineName, tostring(line.id or line.nr))
end

function TransitLinePublisher.syncLines()
    if not TransitOptionsRegistry.isPublishEnabled("lines") then return end

    linePublisher:publish(TransitLineDtoFactory.createDtoList(Line.getAll(), isSelectedLine))
end

function TransitLinePublisher.syncLineNames()
    if not TransitOptionsRegistry.isPublishEnabled("lineNames") then return end

    for _, line in pairs(Line.getAll()) do
        line.valuesUpdated = false
    end
    lineNamePublisher:publish(TransitLineDtoFactory.createLineNameDtoList(Line.getAll(), isSelectedLineName))
end

function TransitLinePublisher.syncState()
    TransitLinePublisher.syncLines()
    TransitLinePublisher.syncLineNames()
end

function TransitLinePublisher.requestFullSync()
    linePublisher:requestFullSync(TransitCeTypes.Line)
    lineNamePublisher:requestFullSync(TransitCeTypes.LineName)
end

return TransitLinePublisher
