if CeDebugLoad then print("[#Start] Loading ce.mods.road.IntersectionSettings ...") end
local StorageUtility = require("ce.hub.util.StorageUtility")

local IntersectionSettings = {}
IntersectionSettings.showRequestsOnSignal = false
IntersectionSettings.showPhaseOnSignal = false
IntersectionSettings.showModelInfoOnSignal = false
IntersectionSettings.showLaneNamesOnSignal = false
IntersectionSettings.showNameAndPhaseOnSignal = false
IntersectionSettings.showSignalIdOnSignal = false
IntersectionSettings.showLanesOnStructure = false
local function loadBoolean(data, key, fallback)
    if data[key] == nil then return fallback end
    return StorageUtility.toboolean(data[key])
end

local function replaceBoolean(fieldName, value)
    if IntersectionSettings[fieldName] == value then return false end
    IntersectionSettings[fieldName] = value
    return true
end

function IntersectionSettings.loadSettingsFromSlot(eepSaveId)
    StorageUtility.registerId(eepSaveId, "Intersection settings")
    IntersectionSettings.saveSlot = eepSaveId
    local data = StorageUtility.loadTable(IntersectionSettings.saveSlot, "Intersection settings")
    replaceBoolean("showRequestsOnSignal", loadBoolean(data, "reqInfo", IntersectionSettings.showRequestsOnSignal))
    replaceBoolean("showPhaseOnSignal", loadBoolean(data, "seqInfo", IntersectionSettings.showPhaseOnSignal))
    replaceBoolean("showModelInfoOnSignal", loadBoolean(data, "modelInfo",
                                                        IntersectionSettings.showModelInfoOnSignal))
    replaceBoolean("showLaneNamesOnSignal", loadBoolean(data, "laneNameInfo",
                                                        IntersectionSettings.showLaneNamesOnSignal))
    replaceBoolean("showNameAndPhaseOnSignal", loadBoolean(data, "nameSeqInfo",
                                                           IntersectionSettings.showNameAndPhaseOnSignal))
    replaceBoolean("showSignalIdOnSignal", loadBoolean(data, "sigInfo", IntersectionSettings.showSignalIdOnSignal))
    replaceBoolean("showLanesOnStructure", loadBoolean(data, "laneInfo", IntersectionSettings.showLanesOnStructure))
end

function IntersectionSettings.saveSettings()
    if IntersectionSettings.saveSlot then
        local data = {
            reqInfo = tostring(IntersectionSettings.showRequestsOnSignal),
            seqInfo = tostring(IntersectionSettings.showPhaseOnSignal),
            modelInfo = tostring(IntersectionSettings.showModelInfoOnSignal),
            laneNameInfo = tostring(IntersectionSettings.showLaneNamesOnSignal),
            nameSeqInfo = tostring(IntersectionSettings.showNameAndPhaseOnSignal),
            sigInfo = tostring(IntersectionSettings.showSignalIdOnSignal),
            laneInfo = tostring(IntersectionSettings.showLanesOnStructure)
        }
        StorageUtility.saveTable(IntersectionSettings.saveSlot, data, "Intersection settings")
    end
end

function IntersectionSettings.setShowRequestsOnSignal(value)
    assert(value == true or value == false)
    if replaceBoolean("showRequestsOnSignal", value) then IntersectionSettings.saveSettings() end
end

function IntersectionSettings.setShowModelInfoOnSignal(value)
    assert(value == true or value == false)
    if replaceBoolean("showModelInfoOnSignal", value) then IntersectionSettings.saveSettings() end
end

function IntersectionSettings.setShowLaneNamesOnSignal(value)
    assert(value == true or value == false)
    if replaceBoolean("showLaneNamesOnSignal", value) then IntersectionSettings.saveSettings() end
end

function IntersectionSettings.setShowPhaseOnSignal(value)
    assert(value == true or value == false)
    if replaceBoolean("showPhaseOnSignal", value) then IntersectionSettings.saveSettings() end
end

function IntersectionSettings.setShowNameAndPhaseOnSignal(value)
    assert(value == true or value == false)
    if replaceBoolean("showNameAndPhaseOnSignal", value) then IntersectionSettings.saveSettings() end
end

function IntersectionSettings.setShowSignalIdOnSignal(value)
    assert(value == true or value == false)
    if replaceBoolean("showSignalIdOnSignal", value) then IntersectionSettings.saveSettings() end
end

function IntersectionSettings.setShowLanesOnStructure(value)
    assert(value == true or value == false)
    if replaceBoolean("showLanesOnStructure", value) then IntersectionSettings.saveSettings() end
end

return IntersectionSettings
