if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureUpdater ...") end

local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

---@class StructureUpdater
---@field runInitialUpdate fun(options: table|nil):nil
---@field runUpdate fun(options: table|nil):nil
local StructureUpdater = {}

local EEPStructureGetLight = _G.EEPStructureGetLight or function () end
local EEPStructureGetSmoke = _G.EEPStructureGetSmoke or function () end
local EEPStructureGetFire = _G.EEPStructureGetFire or function () end
local EEPStructureGetTagText = _G.EEPStructureGetTagText or function () end
local EEPStructureGetPosition = _G.EEPStructureGetPosition or function () end
local EEPStructureGetRotation = _G.EEPStructureGetRotation or function () end
local updateCycle = 0
local PERIODIC_UPDATE_INTERVAL = 10

local function round2(value)
    return value and tonumber(string.format("%.2f", value)) or 0
end

local function isStructureSignalHousing(structure)
    local gsbname = string.lower(tostring(structure.gsbname or "")):gsub("/", "\\")
    return string.match(gsbname, "^\\immobilien\\verkehr\\signale\\strabasigg.*ma1%.3dm$") ~= nil
end

local function shouldUpdateTag(structure, fields, isSelected)
    -- Ampelaufsteller needs fresh tags for traffic light housings.
    return SyncPolicy.shouldUpdateField(fields, "tag", isSelected) or isStructureSignalHousing(structure)
end

local function updateStructureFields(structure, fields, isSelected)
    if shouldUpdateTag(structure, fields, isSelected) then
        local _, tag = EEPStructureGetTagText(structure.name)
        structure:setTag(tag or "")
    end
    if SyncPolicy.shouldUpdateField(fields, "light", isSelected) then
        local _, light = EEPStructureGetLight(structure.name)
        structure:setLight(light == true)
    end
    if SyncPolicy.shouldUpdateField(fields, "smoke", isSelected) then
        local _, smoke = EEPStructureGetSmoke(structure.name)
        structure:setSmoke(smoke == true)
    end
    if SyncPolicy.shouldUpdateField(fields, "fire", isSelected) then
        local _, fire = EEPStructureGetFire(structure.name)
        structure:setFire(fire == true)
    end
    if SyncPolicy.shouldUpdateField(fields, "pos_x", isSelected) or
        SyncPolicy.shouldUpdateField(fields, "pos_y", isSelected) or
        SyncPolicy.shouldUpdateField(fields, "pos_z", isSelected) then
        local hasPosition, posX, posY, posZ = EEPStructureGetPosition(structure.name)
        if hasPosition then structure:setPosition(round2(posX), round2(posY), round2(posZ)) end
    end
    if SyncPolicy.shouldUpdateField(fields, "rot_x", isSelected) or
        SyncPolicy.shouldUpdateField(fields, "rot_y", isSelected) or
        SyncPolicy.shouldUpdateField(fields, "rot_z", isSelected) then
        local hasRotation, rotX, rotY, rotZ = EEPStructureGetRotation(structure.name)
        if hasRotation then structure:setRotation(round2(rotX), round2(rotY), round2(rotZ)) end
    end
end

function StructureUpdater.runInitialUpdate()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("structures") then return end

    local StructureDiscovery = require("ce.hub.data.structures.StructureDiscovery")
    if StructureDiscovery.wasSeededFromAnl3() then
        for _, structure in pairs(StructureRegistry.getAll()) do
            structure:resetDirty()
        end
        return
    end

    for _, structure in pairs(StructureRegistry.getAll()) do
        updateStructureFields(structure, {}, true)
        structure:resetDirty()
    end
end

function StructureUpdater.runUpdate()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("structures") then return end

    updateCycle = updateCycle + 1
    local isPeriodicUpdate = updateCycle % PERIODIC_UPDATE_INTERVAL == 0
    local fields = HubOptionsRegistry.getFieldUpdatePolicies("structures")
    for _, structure in pairs(StructureRegistry.getAll()) do
        local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.Structure,
                                                           tostring(structure.id or structure.name))
        updateStructureFields(structure, fields, isSelected or isPeriodicUpdate)
    end
end

return StructureUpdater
