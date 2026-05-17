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

function IntersectionSettings.loadSettingsFromSlot(eepSaveId)
    StorageUtility.registerId(eepSaveId, "Intersection settings")
    IntersectionSettings.saveSlot = eepSaveId
    local data = StorageUtility.loadTable(IntersectionSettings.saveSlot, "Intersection settings")
    IntersectionSettings.showRequestsOnSignal = loadBoolean(data, "reqInfo", IntersectionSettings.showRequestsOnSignal)
    IntersectionSettings.showPhaseOnSignal = loadBoolean(data, "seqInfo", IntersectionSettings.showPhaseOnSignal)
    IntersectionSettings.showModelInfoOnSignal = loadBoolean(data, "modelInfo",
        IntersectionSettings.showModelInfoOnSignal)
    IntersectionSettings.showLaneNamesOnSignal = loadBoolean(data, "laneNameInfo",
                                                             IntersectionSettings.showLaneNamesOnSignal)
    IntersectionSettings.showNameAndPhaseOnSignal = loadBoolean(data, "nameSeqInfo",
                                                                IntersectionSettings.showNameAndPhaseOnSignal)
    IntersectionSettings.showSignalIdOnSignal = loadBoolean(data, "sigInfo", IntersectionSettings.showSignalIdOnSignal)
    IntersectionSettings.showLanesOnStructure = loadBoolean(data, "laneInfo", IntersectionSettings.showLanesOnStructure)
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
    IntersectionSettings.showRequestsOnSignal = value
    IntersectionSettings.saveSettings()
end

function IntersectionSettings.setShowModelInfoOnSignal(value)
    assert(value == true or value == false)
    IntersectionSettings.showModelInfoOnSignal = value
    IntersectionSettings.saveSettings()
end

function IntersectionSettings.setShowLaneNamesOnSignal(value)
    assert(value == true or value == false)
    IntersectionSettings.showLaneNamesOnSignal = value
    IntersectionSettings.saveSettings()
end

function IntersectionSettings.setShowPhaseOnSignal(value)
    assert(value == true or value == false)
    IntersectionSettings.showPhaseOnSignal = value
    IntersectionSettings.saveSettings()
end

function IntersectionSettings.setShowNameAndPhaseOnSignal(value)
    assert(value == true or value == false)
    IntersectionSettings.showNameAndPhaseOnSignal = value
    IntersectionSettings.saveSettings()
end

function IntersectionSettings.setShowSignalIdOnSignal(value)
    assert(value == true or value == false)
    IntersectionSettings.showSignalIdOnSignal = value
    IntersectionSettings.saveSettings()
end

function IntersectionSettings.setShowLanesOnStructure(value)
    assert(value == true or value == false)
    IntersectionSettings.showLanesOnStructure = value
    IntersectionSettings.saveSettings()
end

return IntersectionSettings
