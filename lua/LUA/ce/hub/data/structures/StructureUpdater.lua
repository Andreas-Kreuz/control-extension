if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureUpdater ...") end

local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local StructureUpdater = {}

local EEPStructureGetPosition = _G.EEPStructureGetPosition or function () end
local EEPStructureGetRotation = _G.EEPStructureGetRotation or function () end
local EEPStructureGetModelType = _G.EEPStructureGetModelType or function () end
local EEPStructureGetLight = _G.EEPStructureGetLight or function () end
local EEPStructureGetSmoke = _G.EEPStructureGetSmoke or function () end
local EEPStructureGetFire = _G.EEPStructureGetFire or function () end
local EEPStructureGetTagText = _G.EEPStructureGetTagText or function () end

local EEPStructureModelTypeText = {
    [16] = "Gleis/Gleisobjekt",
    [17] = "Schiene/Gleisobjekt",
    [18] = "Strasse/Gleisobjekt",
    [19] = "Sonstiges/Gleisobjekt",
    [22] = "Immobilie",
    [23] = "Landschaftselement/Fauna",
    [24] = "Landschaftselement/Flora",
    [25] = "Landschaftselement/Terra",
    [38] = "Landschaftselement/Instancing"
}

local function round2(value)
    return value and tonumber(string.format("%.2f", value)) or 0
end

local function applyStaticUpdate(structure)
    local _, modelType = EEPStructureGetModelType(structure.name)
    local _, posX, posY, posZ = EEPStructureGetPosition(structure.name)
    local _, rotX, rotY, rotZ = EEPStructureGetRotation(structure.name)

    structure:setModelType(modelType or 0, EEPStructureModelTypeText[modelType] or "")
    structure:setPosition(round2(posX), round2(posY), round2(posZ))
    structure:setRotation(round2(rotX), round2(rotY), round2(rotZ))
end

function StructureUpdater.runInitialUpdate()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("structures") then return end

    for _, structure in pairs(StructureRegistry.getAll()) do
        applyStaticUpdate(structure)
        structure:resetDirty()
    end
end

function StructureUpdater.runUpdate()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")
    local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
    local HubCeTypes = require("ce.hub.data.HubCeTypes")
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("structures") then return end

    local fields = HubOptionsRegistry.getFieldUpdatePolicies("structures")
    for _, structure in pairs(StructureRegistry.getAll()) do
        local isSelected = DynamicUpdateRegistry.isSelected(HubCeTypes.Structure,
                                                            tostring(structure.id or structure.name))
        applyStaticUpdate(structure)
        if SyncPolicy.shouldUpdateField(fields, "tag", isSelected) then
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
    end
end

return StructureUpdater
