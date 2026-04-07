-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/structures/StructureLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local StructureDtoFactory = {}

local CE_TYPE = HubCeTypes.Structure
local KEY_ID = "id"
local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local placeHolders = {
    light = false,
    smoke = false,
    fire = false,
}

local function toFullDto(structure, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("structures")
    local dto = {
        ceType = CE_TYPE,
        id = structure.id,
        name = structure.name,
        pos_x = structure.pos_x,
        pos_y = structure.pos_y,
        pos_z = structure.pos_z,
        rot_x = structure.rot_x,
        rot_y = structure.rot_y,
        rot_z = structure.rot_z,
        modelType = structure.modelType,
        modelTypeText = structure.modelTypeText,
    }
    if SyncPolicy.shouldPublishField(fieldPolicies, "tag", isSelected) then dto.tag = structure:getTag() end
    if SyncPolicy.shouldPublishField(fieldPolicies, "light", isSelected) then
        dto.light = structure:getLight()
    elseif SyncPolicy.shouldPublishPlaceholder(fieldPolicies, "light", isSelected) then
        dto.light = placeHolders.light
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "smoke", isSelected) then
        dto.smoke = structure:getSmoke()
    elseif SyncPolicy.shouldPublishPlaceholder(fieldPolicies, "smoke", isSelected) then
        dto.smoke = placeHolders.smoke
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "fire", isSelected) then
        dto.fire = structure:getFire()
    elseif SyncPolicy.shouldPublishPlaceholder(fieldPolicies, "fire", isSelected) then
        dto.fire = placeHolders.fire
    end
    return dto
end

local fieldGetters = {
    tag = function (s) return s:getTag() end,
    light = function (s) return s:getLight() end,
    smoke = function (s) return s:getSmoke() end,
    fire = function (s) return s:getFire() end,
}

local function toPatchDto(structure, dirtyFields, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("structures")
    local dto = {
        ceType = CE_TYPE,
        id = structure.id,
    }
    for field in pairs(dirtyFields) do
        local getter = fieldGetters[field]
        if getter and SyncPolicy.shouldPublishField(fieldPolicies, field, isSelected) then
            dto[field] = getter(structure)
        elseif getter and placeHolders[field] ~= nil and SyncPolicy.shouldPublishPlaceholder(fieldPolicies, field,
                                                                                             isSelected) then
            dto[field] = placeHolders[field]
        end
    end
    return dto
end

function StructureDtoFactory.createFullDto(structure, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = toFullDto(structure, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function StructureDtoFactory.createPatchDto(structure, dirtyFields, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = toPatchDto(structure, dirtyFields, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function StructureDtoFactory.createRefDto(structureId)
    local dto = { ceType = CE_TYPE, id = structureId }
    return CE_TYPE, KEY_ID, structureId, dto
end

return StructureDtoFactory
