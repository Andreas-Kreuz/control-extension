if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitStatePublisher ...") end
local TransitLinePublisher = require("ce.mods.transit.data.TransitLinePublisher")
local TransitModuleSettingsPublisher = require("ce.mods.transit.data.TransitModuleSettingsPublisher")
local TransitStationPublisher = require("ce.mods.transit.data.TransitStationPublisher")
local TransitTrainPublisher = require("ce.mods.transit.data.TransitTrainPublisher")
local TransitFullSyncMarker = require("ce.mods.transit.data.TransitFullSyncMarker")

---@class TransitStatePublisher
local TransitStatePublisher = {}
TransitStatePublisher.enabled = true
local initialized = false
TransitStatePublisher.name = "ce.mods.transit.data.TransitStatePublisher"
TransitStatePublisher.ceTypes =
    require("ce.mods.transit.data.TransitCeTypes").TransitTrain .. "," ..
    require("ce.mods.transit.data.TransitCeTypes").Line .. "," ..
    require("ce.mods.transit.data.TransitCeTypes").LineName .. "," ..
    require("ce.mods.transit.data.TransitCeTypes").Station .. "," ..
    require("ce.mods.transit.data.TransitCeTypes").ModuleSetting

function TransitStatePublisher.initialize()
    if not TransitStatePublisher.enabled or initialized then return end
    initialized = true
end

function TransitStatePublisher.syncState()
    if not TransitStatePublisher.enabled then return end
    if not initialized then TransitStatePublisher.initialize() end

    TransitTrainPublisher.syncState()
    TransitLinePublisher.syncState()
    TransitStationPublisher.syncState()
    TransitModuleSettingsPublisher.syncState()
end

function TransitStatePublisher.requestFullSync()
    TransitFullSyncMarker.requestFullSync()
end

return TransitStatePublisher
