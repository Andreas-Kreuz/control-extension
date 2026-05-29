if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitStationPublisher ...") end

local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local IncrementalListPublisher = require("ce.hub.publish.IncrementalListPublisher")
local RoadStation = require("ce.mods.transit.RoadStation")
local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")

local TransitStationPublisher = {}
local stationPublisher = IncrementalListPublisher:new()

local function isSelectedStation(station)
    return InterestSyncRegistry.isSelected(TransitCeTypes.Station, tostring(station.name))
end

function TransitStationPublisher.syncState()
    if not TransitOptionsRegistry.isPublishEnabled("stations") then return end

    stationPublisher:publish(TransitDtoFactory.createStationDtoList(RoadStation.getAll(), isSelectedStation))
end

function TransitStationPublisher.requestFullSync()
    stationPublisher:requestFullSync(TransitCeTypes.Station)
end

return TransitStationPublisher
