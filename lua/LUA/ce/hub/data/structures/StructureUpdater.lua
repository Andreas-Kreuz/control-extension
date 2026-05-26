if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureUpdater ...") end

local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

---@class StructureUpdater
---@field runInitialUpdate fun(options: table|nil):nil
---@field runUpdate fun(options: table|nil):nil
local StructureUpdater = {}

local updateCycle = 0
local PERIODIC_UPDATE_INTERVAL = 10
local housingStructureCache = {
    revision = -1,
    ids = {}
}
local dynamicFieldNames = {
    "tag",
    "light",
    "smoke",
    "fire",
    "pos_x",
    "pos_y",
    "pos_z",
    "rot_x",
    "rot_y",
    "rot_z"
}

local function isStructureSignalHousing(structure)
    local gsbname = string.lower(tostring(structure:peekGsbname() or "")):gsub("/", "\\")
    return string.match(gsbname, "^\\immobilien\\verkehr\\signale\\strabasigg.*ma1%.3dm$") ~= nil
end

local function shouldUpdateTag(fields, isSelected)
    return SyncPolicy.shouldUpdateField(fields, "tag", isSelected)
end

local function hasAlwaysFieldPolicy(fields)
    for _, fieldName in ipairs(dynamicFieldNames) do
        if SyncPolicy.getFieldPolicy(fields, fieldName) == "always" then return true end
    end
    return false
end

local function refreshHousingStructureCache()
    local revision = StructureRegistry.getRevision()
    if housingStructureCache.revision == revision then return end

    local structureIds = {}
    StructureRegistry.forEach(function (structure, structureId)
        if isStructureSignalHousing(structure) then structureIds[#structureIds + 1] = structureId end
    end)
    housingStructureCache.ids = structureIds
    housingStructureCache.revision = revision
end

local function updateStructureFields(structure, fields, isSelected)
    if shouldUpdateTag(fields, isSelected) then
        structure:pullTag()
    end
    if SyncPolicy.shouldUpdateField(fields, "light", isSelected) then
        structure:pullLight()
    end
    if SyncPolicy.shouldUpdateField(fields, "smoke", isSelected) then
        structure:pullSmoke()
    end
    if SyncPolicy.shouldUpdateField(fields, "fire", isSelected) then
        structure:pullFire()
    end
    if SyncPolicy.shouldUpdateField(fields, "pos_x", isSelected) or
        SyncPolicy.shouldUpdateField(fields, "pos_y", isSelected) or
        SyncPolicy.shouldUpdateField(fields, "pos_z", isSelected) then
        structure:pullPosition()
    end
    if SyncPolicy.shouldUpdateField(fields, "rot_x", isSelected) or
        SyncPolicy.shouldUpdateField(fields, "rot_y", isSelected) or
        SyncPolicy.shouldUpdateField(fields, "rot_z", isSelected) then
        structure:pullRotation()
    end
end

local function loadInitialStructureFields()
    StructureRegistry.forEach(function (structure)
        structure:getTag()
        structure:getLight()
        structure:getSmoke()
        structure:getFire()
        structure:getPosition()
        structure:getRotation()
    end)
end

local function updateAllStructuresByInterest(fields, InterestSyncRegistry, HubCeTypes)
    local updatedStructureIds = {}
    StructureRegistry.forEach(function (structure)
        local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Structure,
                                                           tostring(structure.id or structure.name))
        updateStructureFields(structure, fields, isSelected)
        if isSelected then updatedStructureIds[structure.id] = true end
    end)
    return updatedStructureIds
end

local function updateSelectedStructures(fields, InterestSyncRegistry, HubCeTypes)
    local updatedStructureIds = {}
    for structureId in pairs(InterestSyncRegistry.getSelectedKeys(HubCeTypes.Structure)) do
        local structure = StructureRegistry.get(structureId) or StructureRegistry.getByName(structureId)
        if structure then
            updateStructureFields(structure, fields, true)
            updatedStructureIds[structure.id] = true
        end
    end
    return updatedStructureIds
end

local function updatePeriodicHousingStructures(updatedStructureIds)
    refreshHousingStructureCache()
    for _, structureId in ipairs(housingStructureCache.ids) do
        if not updatedStructureIds[structureId] then
            local structure = StructureRegistry.get(structureId)
            if structure then
                local oldPosX, oldPosY, oldPosZ = structure:peekPosition()
                structure:pullTag()
                local posX, posY, posZ = structure:pullPosition()
                if posX ~= nil and
                    (oldPosX ~= posX or oldPosY ~= posY or oldPosZ ~= posZ) then
                    structure:pullRotation()
                end
            end
        end
    end
end

local function resetAllStructures()
    StructureRegistry.forEach(function (structure)
        structure:resetDirty()
    end)
end

function StructureUpdater.runInitialUpdate()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    if HubOptionsRegistry.isDiscoveryAndUpdateEnabled("structures") then
        local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")
        if StructureDiscovery.wasSeededFromAnl3() then
            resetAllStructures()
        else
            loadInitialStructureFields()
            resetAllStructures()
        end
    end
end

function StructureUpdater.runUpdate()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")
    if HubOptionsRegistry.isDiscoveryAndUpdateEnabled("structures") then
        updateCycle = updateCycle + 1
        local isPeriodicUpdate = updateCycle % PERIODIC_UPDATE_INTERVAL == 0
        local fields = HubOptionsRegistry.getFieldUpdatePolicies("structures")
        local updatedStructureIds
        if hasAlwaysFieldPolicy(fields) then
            updatedStructureIds = updateAllStructuresByInterest(fields, InterestSyncRegistry, HubCeTypes)
        else
            updatedStructureIds = updateSelectedStructures(fields, InterestSyncRegistry, HubCeTypes)
        end
        if isPeriodicUpdate then updatePeriodicHousingStructures(updatedStructureIds) end
    end
end

return StructureUpdater
