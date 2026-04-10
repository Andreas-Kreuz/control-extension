if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureDiscovery ...") end

local Structure = require("ce.hub.data.structures.Structure")
local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local StructureDiscovery = {}

local MAX_STRUCTURES = 50000
local EEPStructureGetModelType = _G.EEPStructureGetModelType or function () return false end
local EEPStructureGetPosition = _G.EEPStructureGetPosition or function () end
local EEPStructureGetRotation = _G.EEPStructureGetRotation or function () end

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

local function structureExists(name)
    local exists = EEPStructureGetModelType(name)
    return exists == true
end

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

local function discoverStructures()
    local discoveredIds = {}

    for i = 0, MAX_STRUCTURES do
        local name = "#" .. tostring(i)
        if structureExists(name) then
            local structure = StructureRegistry.forId(name)
            discoveredIds[name] = true
            if not structure then
                structure = Structure:new(name)
                StructureRegistry.add(structure)
            end
            applyStaticUpdate(structure)
        end
    end

    for structureId in pairs(StructureRegistry.getAll()) do
        if not discoveredIds[structureId] then
            StructureRegistry.remove(structureId)
        end
    end
end

function StructureDiscovery.initFromAnl3(tableOfAnl3)
    if not tableOfAnl3 then return end

    for _, entry in ipairs(tableOfAnl3.structures or {}) do
        if entry.name and not StructureRegistry.forId(entry.name) then
            local structure = Structure:new(entry.name)
            structure:setGsbname(entry.gsbname)
            StructureRegistry.add(structure)
        end
    end
end

function StructureDiscovery.runInitialDiscovery()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("structures") then return end
    discoverStructures()
end

function StructureDiscovery.runDiscovery()
    -- do nothing
end

return StructureDiscovery
