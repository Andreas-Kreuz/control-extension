local StorageUtility = require("ce.hub.util.StorageUtility")
local RoadStation = require("ce.mods.transit.RoadStation")
if CeDebugLoad then print("[#Start] Loading ce.mods.transit.TransitSettings ...") end

local TransitSettings = {}
TransitSettings.showDepartureTippText = false
TransitSettings.saveSlot = nil

local function loadBoolean(data, key, fallback)
    if data[key] == nil then return fallback end
    return StorageUtility.toboolean(data[key])
end

function TransitSettings.loadSettingsFromSlot(eepSaveId)
    StorageUtility.registerId(eepSaveId, "Transit settings")
    TransitSettings.saveSlot = eepSaveId
    local data = StorageUtility.loadTable(TransitSettings.saveSlot, "Transit settings")
    TransitSettings.showDepartureTippText = loadBoolean(data, "depInfo", TransitSettings.showDepartureTippText)
end

function TransitSettings.saveSettings()
    if TransitSettings.saveSlot then
        local data = { ["depInfo"] = tostring(TransitSettings.showDepartureTippText) }
        StorageUtility.saveTable(TransitSettings.saveSlot, data, "Transit settings")
    else
        print("TransitSettings: No save slot defined, cannot save settings.")
    end
end

function TransitSettings.setShowDepartureTippText(value)
    assert(value == true or value == false)
    TransitSettings.showDepartureTippText = value
    TransitSettings.saveSettings()
    RoadStation.showTippText()
end

return TransitSettings
