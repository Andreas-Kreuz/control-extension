if AkDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureStatePublisher ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local Structure = require("ce.hub.data.structures.Structure")
local StructureDtoFactory = require("ce.hub.data.structures.StructureDtoFactory")
StructureStatePublisher = {}
local enabled = true
local initialized = false
StructureStatePublisher.name = "ce.hub.data.structures.StructureStatePublisher"

local MAX_STRUCTURES = 50000
local EEPStructureGetLight = _G.EEPStructureGetLight or function() return false end
local EEPStructureGetModelType = _G.EEPStructureGetModelType or function() return false end

---@type table<string, Structure>
local allStructures = {}

function StructureStatePublisher.initialize()
    if not enabled or initialized then return end

    for i = 0, MAX_STRUCTURES do
        local name = "#" .. tostring(i)
        local hasModelType = EEPStructureGetModelType(name)
        local hasLight = EEPStructureGetLight(name)
        if hasModelType or hasLight then
            local structure = Structure:new(name)
            structure.valuesUpdated = false
            allStructures[name] = structure
            DataChangeBus.fireDataAdded(StructureDtoFactory.createStructureDto(structure))
        end
    end

    initialized = true
end

function StructureStatePublisher.syncState()
    if not enabled then return end

    if not initialized then StructureStatePublisher.initialize() end

    for _, structure in pairs(allStructures) do
        structure:refresh()
        if structure.valuesUpdated then
            structure.valuesUpdated = false
            DataChangeBus.fireDataChanged(StructureDtoFactory.createStructureDto(structure))
        end
    end

    return {}
end

return StructureStatePublisher
