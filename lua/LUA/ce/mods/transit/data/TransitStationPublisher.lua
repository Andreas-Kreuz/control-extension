if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitStationPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local RoadStation = require("ce.mods.transit.RoadStation")
local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")

local TransitStationPublisher = {}

function TransitStationPublisher.syncState()
    if not TransitOptionsRegistry.isPublishEnabled("stations") then return end

    for _, station in pairs(RoadStation.getAll()) do
        local isSelected = InterestSyncRegistry.isSelected(TransitCeTypes.Station, station.name)
        DataChangeBus.fireDataChanged(TransitDtoFactory.createStationDto(station, isSelected))
    end
end

return TransitStationPublisher