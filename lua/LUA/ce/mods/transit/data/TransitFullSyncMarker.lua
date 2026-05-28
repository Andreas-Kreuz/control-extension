if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitFullSyncMarker ...") end

local TransitFullSyncMarker = {}

function TransitFullSyncMarker.requestFullSync()
    require("ce.mods.transit.data.TransitTrainPublisher").requestFullSync()
    require("ce.mods.transit.data.TransitLinePublisher").requestFullSync()
    require("ce.mods.transit.data.TransitStationPublisher").requestFullSync()
    require("ce.mods.transit.data.TransitModuleSettingsPublisher").requestFullSync()
end

return TransitFullSyncMarker
