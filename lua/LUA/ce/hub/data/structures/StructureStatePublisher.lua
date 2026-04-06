if AkDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureStatePublisher ...") end
local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local Structure = require("ce.hub.data.structures.Structure")
local StructureDtoFactory = require("ce.hub.data.structures.StructureDtoFactory")
local DynamicUpdateRegistry = require("ce.hub.data.dynamic.DynamicUpdateRegistry")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")
StructureStatePublisher = {}
StructureStatePublisher.enabled = true
local initialized = false
StructureStatePublisher.name = "ce.hub.data.structures.StructureStatePublisher"

StructureStatePublisher.options = {
    ceTypes = {
        structure = { ceType = "ce.hub.Structure", mode = "all" }
    },
    fields = {
        light = { collect = true },
        smoke = { collect = true },
        fire = { collect = true },
        tag = { collect = true }
    }
}

local MAX_STRUCTURES = 50000
local EEPStructureGetModelType = _G.EEPStructureGetModelType or function () return false end

---@type table<string, Structure>
local allStructures = {}

local function isSubscribed(structure)
    local structureOptions = StructureStatePublisher.options.ceTypes.structure
    local mode = SyncPolicy.getMode(structureOptions, true)
    local selected = DynamicUpdateRegistry.isSelected(HubCeTypes.Structure, structure.id)
    return mode == "all" or (mode == "selected" and selected)
end

local function structureExists(name)
    local exists = EEPStructureGetModelType(name)
    return exists == true
end

function StructureStatePublisher.initialize()
    if not StructureStatePublisher.enabled or initialized then return end

    for i = 0, MAX_STRUCTURES do
        local name = "#" .. tostring(i)
        if structureExists(name) then
            local structure = Structure:new(name, StructureStatePublisher.options)
            allStructures[name] = structure
            DataChangeBus.fireDataAdded(StructureDtoFactory.createFullDto(structure, isSubscribed(structure)))
            structure:resetDirty()
        end
    end

    initialized = true
end

function StructureStatePublisher.syncState()
    if not StructureStatePublisher.enabled then return end

    if not initialized then StructureStatePublisher.initialize() end

    for _, structure in pairs(allStructures) do
        structure:refresh(StructureStatePublisher.options)
        if structure:hasDirtyFields() then
            DataChangeBus.fireDataChanged(StructureDtoFactory.createPatchDto(structure,
                                                                             structure.dirtyFields,
                                                                             isSubscribed(structure)))
            structure:resetDirty()
        end
    end

    return {}
end

return StructureStatePublisher
