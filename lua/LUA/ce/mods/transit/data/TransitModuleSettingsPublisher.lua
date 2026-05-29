if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitModuleSettingsPublisher ...") end

local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local IncrementalListPublisher = require("ce.hub.publish.IncrementalListPublisher")
local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitDtoFactory = require("ce.mods.transit.data.TransitDtoFactory")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")
local TransitSettings = require("ce.mods.transit.TransitSettings")

local TransitModuleSettingsPublisher = {}
local settingsPublisher = IncrementalListPublisher:new()

local function isSelectedModuleSetting(setting)
    return InterestSyncRegistry.isSelected(TransitCeTypes.ModuleSetting, tostring(setting.name))
end

local function moduleSettings()
    return {
        {
            category = "Tipp-Texte für Anzeigetafeln",
            name = "Nächste Abfahrten",
            description = "Zeige Abfahrten für Bus und Tram-Linien als TippText an",
            type = "boolean",
            value = TransitSettings.showDepartureTippText,
            eepFunction = "TransitSettings.setShowDepartureTippText"
        }
    }
end

function TransitModuleSettingsPublisher.syncState()
    if not TransitOptionsRegistry.isPublishEnabled("moduleSettings") then return end

    settingsPublisher:publish(TransitDtoFactory.createModuleSettingDtoList(moduleSettings(),
                                                                           isSelectedModuleSetting))
end

function TransitModuleSettingsPublisher.requestFullSync()
    settingsPublisher:requestFullSync(TransitCeTypes.ModuleSetting)
end

return TransitModuleSettingsPublisher
