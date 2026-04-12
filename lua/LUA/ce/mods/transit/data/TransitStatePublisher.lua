if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitStatePublisher ...") end
local LineRegistry = require("ce.mods.transit.LineRegistry")
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitDataCollector = require("ce.mods.transit.data.TransitDataCollector")
local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")
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

    local data = TransitDataCollector.collectTransitData()

    if TransitOptionsRegistry.isPublishEnabled("stations") then
        for _, station in pairs(data.publicTransportStations) do
            local isSelected = DynamicUpdateRegistry.isSelected(TransitCeTypes.Station, station.name)
            DataChangeBus.fireDataChanged(TransitDtoFactory.createStationDto(station, isSelected))
        end
    end
    if TransitOptionsRegistry.isPublishEnabled("lines") then
        DataChangeBus.fireListChange(TransitDtoFactory.createLineDtoList(data.publicTransportLines, function (line)
            return DynamicUpdateRegistry.isSelected(TransitCeTypes.Line, tostring(line.id or line.nr))
        end))
    end
    if TransitOptionsRegistry.isPublishEnabled("moduleSettings") then
        DataChangeBus.fireListChange(TransitDtoFactory.createModuleSettingDtoList(data.publicTransportSettings,
                                                                                  function (setting)
            return DynamicUpdateRegistry.isSelected(TransitCeTypes.ModuleSetting, tostring(setting.name))
        end))
    end
    LineRegistry.fireChangeLinesEvent()

    return {}
end

return TransitStatePublisher
