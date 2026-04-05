if AkDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureStatePublisher ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local Structure = require("ce.hub.data.structures.Structure")
local StructureStaticDtoFactory = require("ce.hub.data.structures.StructureStaticDtoFactory")
local StructureDynamicDtoFactory = require("ce.hub.data.structures.StructureDynamicDtoFactory")
StructureStatePublisher = {}
local enabled = true
local initialized = false
StructureStatePublisher.name = "ce.hub.data.structures.StructureStatePublisher"

local MAX_STRUCTURES = 50000
local EEPStructureGetLight = _G.EEPStructureGetLight or function() return false end
local EEPStructureGetSmoke = _G.EEPStructureGetSmoke or function() return false end
local EEPStructureGetFire = _G.EEPStructureGetFire or function() return false end
local EEPStructureGetModelType = _G.EEPStructureGetModelType or function() return false end
local EEPStructureGetTagText = _G.EEPStructureGetTagText or function() return false end

---@type table<string, Structure>
local allStructures = {}

local function structureExists(name)
    if EEPStructureGetModelType(name) then return true end
    if Structure.options.fetchLight and EEPStructureGetLight(name) then return true end
    if Structure.options.fetchSmoke and EEPStructureGetSmoke(name) then return true end
    if Structure.options.fetchFire and EEPStructureGetFire(name) then return true end
    if Structure.options.fetchTag and EEPStructureGetTagText(name) then return true end
    return false
end

function StructureStatePublisher.initialize()
    if not enabled or initialized then return end

    for i = 0, MAX_STRUCTURES do
        local name = "#" .. tostring(i)
        if structureExists(name) then
            local structure = Structure:new(name)
            structure.staticValuesUpdated = false
            structure.dynamicValuesUpdated = false
            allStructures[name] = structure
            DataChangeBus.fireDataAdded(StructureStaticDtoFactory.createDto(structure))
            DataChangeBus.fireDataAdded(StructureDynamicDtoFactory.createDto(structure))
        end
    end

    initialized = true
end

function StructureStatePublisher.syncState()
    if not enabled then return end

    if not initialized then StructureStatePublisher.initialize() end

    for _, structure in pairs(allStructures) do
        structure:refresh()
        if structure.staticValuesUpdated then
            structure.staticValuesUpdated = false
            DataChangeBus.fireDataChanged(StructureStaticDtoFactory.createDto(structure))
        end
        if structure.dynamicValuesUpdated then
            structure.dynamicValuesUpdated = false
            DataChangeBus.fireDataChanged(StructureDynamicDtoFactory.createDto(structure))
        end
    end

    return {}
end

return StructureStatePublisher
