if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureDiscovery ...") end

local Structure = require("ce.hub.data.structures.Structure")
local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

---@class StructureDiscovery
---@field initFromAnl3 fun(tableOfAnl3: table|nil):nil
---@field runInitialDiscovery fun():nil
---@field runDiscovery fun():nil
---@field wasSeededFromAnl3 fun():boolean
local StructureDiscovery = {}

local seededFromAnl3 = false

function StructureDiscovery.wasSeededFromAnl3()
    return seededFromAnl3
end

local MAX_STRUCTURES = 50000
local DISCOVERY_BATCH_SIZE = 100
local nextDiscoveryIndex = 0
local discoveredIds = {}
local discoveryComplete = false

local function readStructureModelType(name)
    return Structure.readModelType(name)
end

local function round2(value)
    return value and tonumber(string.format("%.2f", value)) or 0
end

local function applyDiscoveryUpdate(structure, modelType)
    structure:seedModelType(modelType)
    structure:pullPosition()
    structure:pullRotation()
    structure:getTag()
    structure:getLight()
    structure:getSmoke()
    structure:getFire()
end

local function applyPositionAndRotation(structure)
    structure:pullPosition()
    structure:pullRotation()
end

local function removeUndiscoveredStructures()
    for structureId in pairs(StructureRegistry.getAll()) do
        if not discoveredIds[structureId] then
            StructureRegistry.remove(structureId)
        end
    end
end

local function discoverStructureBatch()
    if discoveryComplete then return end

    local scanEnd = math.min(MAX_STRUCTURES, nextDiscoveryIndex + DISCOVERY_BATCH_SIZE - 1)
    for i = nextDiscoveryIndex, scanEnd do
        local name = "#" .. tostring(i)
        local exists, modelType = readStructureModelType(name)
        if exists then
            local structure = StructureRegistry.get(name)
            discoveredIds[name] = true
            if not structure then
                structure = Structure:new(name)
                StructureRegistry.add(structure)
            end
            applyDiscoveryUpdate(structure, modelType)
        end
    end

    if scanEnd >= MAX_STRUCTURES then
        discoveryComplete = true
        removeUndiscoveredStructures()
    else
        nextDiscoveryIndex = scanEnd + 1
    end
end

function StructureDiscovery.initFromAnl3(tableOfAnl3)
    if not tableOfAnl3 then return end
    if tableOfAnl3.coverage and not tableOfAnl3.coverage.structures then return end

    discoveredIds = {}
    nextDiscoveryIndex = 0
    discoveryComplete = true
    local structures = {}
    for _, entry in ipairs(tableOfAnl3.structures or {}) do
        local id = entry.id or entry.name
        if id then
            local existing = StructureRegistry.get(id)
            if existing then
                existing:seedGsbname(entry.gsbname)
                if entry.tag ~= nil then existing:seedTag(entry.tag) end
                if entry.tipTxt ~= nil then existing:seedTippText(entry.tipTxt) end
                if entry.tipShow ~= nil then existing:seedTippTextVisible(entry.tipShow) end
                if entry.textureTexts ~= nil then existing:seedTextureTexts(entry.textureTexts) end
                if entry.light ~= nil then existing:seedLight(entry.light) end
                if entry.smoke ~= nil then existing:seedSmoke(entry.smoke) end
                if entry.fire ~= nil then existing:seedFire(entry.fire) end
                if entry.pos_x ~= nil then
                    existing:seedPosition(round2(entry.pos_x), round2(entry.pos_y), round2(entry.pos_z))
                    existing:seedRotation(round2(entry.rot_x), round2(entry.rot_y), round2(entry.rot_z))
                end
                structures[#structures + 1] = existing
            else
                local structure = Structure:new(id, entry.name)
                structure:seedGsbname(entry.gsbname)
                structure:seedModelType(22, "Immobilie")
                if entry.tag ~= nil then structure:seedTag(entry.tag) end
                if entry.tipTxt ~= nil then structure:seedTippText(entry.tipTxt) end
                if entry.tipShow ~= nil then structure:seedTippTextVisible(entry.tipShow) end
                if entry.textureTexts ~= nil then structure:seedTextureTexts(entry.textureTexts) end
                if entry.light ~= nil then structure:seedLight(entry.light) end
                if entry.smoke ~= nil then structure:seedSmoke(entry.smoke) end
                if entry.fire ~= nil then structure:seedFire(entry.fire) end
                if entry.pos_x ~= nil then
                    structure:seedPosition(round2(entry.pos_x), round2(entry.pos_y), round2(entry.pos_z))
                    structure:seedRotation(round2(entry.rot_x), round2(entry.rot_y), round2(entry.rot_z))
                else
                    applyPositionAndRotation(structure)
                end
                structures[#structures + 1] = structure
            end
        end
    end
    StructureRegistry.replaceAll(structures)
    seededFromAnl3 = true
end

function StructureDiscovery.runInitialDiscovery()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("structures") then return end
    discoveredIds = {}
    nextDiscoveryIndex = 0
    discoveryComplete = false
    discoverStructureBatch()
end

function StructureDiscovery.runDiscovery()
    if not HubOptionsRegistry.isDiscoveryAndUpdateEnabled("structures") then return end
    discoverStructureBatch()
end

return StructureDiscovery
