if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitStatePublisher ...") end
local TransitLinePublisher = require("ce.mods.transit.data.TransitLinePublisher")
local TransitModuleSettingsPublisher = require("ce.mods.transit.data.TransitModuleSettingsPublisher")
local TransitStationPublisher = require("ce.mods.transit.data.TransitStationPublisher")
local TransitTrainPublisher = require("ce.mods.transit.data.TransitTrainPublisher")

---@class TransitStatePublisher
TransitStatePublisher = {}
local enabled = true
local initialized = false
TransitStatePublisher.name = "ce.mods.transit.data.TransitStatePublisher"

function TransitStatePublisher.initialize()
    if not enabled or initialized then return end
    initialized = true
end

function TransitStatePublisher.syncState()
    if not enabled then return end
    if not initialized then TransitStatePublisher.initialize() end

    TransitTrainPublisher.syncState()
    TransitLinePublisher.syncState()
    TransitStationPublisher.syncState()
    TransitModuleSettingsPublisher.syncState()
end

return TransitStatePublisher