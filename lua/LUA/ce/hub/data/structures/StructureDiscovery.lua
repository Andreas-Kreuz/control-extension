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

local function structureExists(name)
    return Structure.exists(name)
end

local function round2(value)
    return value and tonumber(string.format("%.2f", value)) or 0
end

local function isStructureSignalHousing(structure)
    local gsbname = string.lower(tostring(structure.gsbname or "")):gsub("/", "\\")
    if string.match(gsbname, "^\\immobilien\\verkehr\\signale\\strabasigg.*ma1%.3dm$") then return true end

    local name = string.lower(tostring(structure.name or ""))
    return string.find(name, "straba signal geh", 1, true) ~= nil or
        string.find(name, "straba signal gehaeuse", 1, true) ~= nil or
        string.find(name, "tram signal casing", 1, true) ~= nil
end

local function applyTagUpdateForHousing(structure)
    if not isStructureSignalHousing(structure) then return end

    structure:pullTag()
end

local function applyStaticUpdate(structure)
    structure:pullModelType()
    structure:pullPosition()
    structure:pullRotation()
end

local function applyPositionAndRotation(structure)
    structure:pullPosition()
    structure:pullRotation()
end

local function discoverStructures()
    local discoveredIds = {}

    for i = 0, MAX_STRUCTURES do
        local name = "#" .. tostring(i)
        if structureExists(name) then
            local structure = StructureRegistry.get(name)
            discoveredIds[name] = true
            if not structure then
                structure = Structure:new(name)
                StructureRegistry.add(structure)
            end
            applyStaticUpdate(structure)
            applyTagUpdateForHousing(structure)
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
    if tableOfAnl3.coverage and not tableOfAnl3.coverage.structures then return end

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
    discoverStructures()
end

function StructureDiscovery.runDiscovery()
    -- do nothing
end

return StructureDiscovery
