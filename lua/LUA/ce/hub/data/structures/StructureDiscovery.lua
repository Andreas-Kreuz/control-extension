if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureDiscovery ...") end

local Structure = require("ce.hub.data.structures.Structure")
local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")

local StructureDiscovery = {}

local MAX_STRUCTURES = 50000
local EEPStructureGetModelType = _G.EEPStructureGetModelType or function () return false end

local function structureExists(name)
    local exists = EEPStructureGetModelType(name)
    return exists == true
end

local function discoverStructures()
    local discoveredIds = {}

    for i = 0, MAX_STRUCTURES do
        local name = "#" .. tostring(i)
        if structureExists(name) then
            discoveredIds[name] = true
            if not StructureRegistry.has(name) then
                local structure = Structure:new(name)
                StructureRegistry.add(structure)
            end
        end
    end

    for structureId in pairs(StructureRegistry.getAll()) do
        if not discoveredIds[structureId] then
            StructureRegistry.remove(structureId)
        end
    end
end

function StructureDiscovery.runInitialDiscovery()
    discoverStructures()
end

function StructureDiscovery.runDiscovery()
    discoverStructures()
end

return StructureDiscovery
