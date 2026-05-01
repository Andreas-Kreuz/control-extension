if CeDebugLoad then print("[#Start] Loading ce.hub.data.DtoBuilder ...") end

local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local DtoBuilder = {}

local function shouldPublishValue(fieldPolicies, fieldName, isSelected)
    if not fieldPolicies then return true end
    return SyncPolicy.shouldPublishField(fieldPolicies, fieldName, isSelected)
end

local function shouldPublishPlaceholder(fieldPolicies, fieldName, isSelected, dtoField)
    if not fieldPolicies or dtoField.placeholder == nil then return false end
    return SyncPolicy.shouldPublishPlaceholder(fieldPolicies, fieldName, isSelected)
end

local function applyField(dto, source, fieldName, dtoField, fieldPolicies, isSelected)
    local policyField = dtoField.policyField or fieldName
    if shouldPublishValue(fieldPolicies, policyField, isSelected) then
        dto[fieldName] = dtoField.getValue(source)
    elseif shouldPublishPlaceholder(fieldPolicies, policyField, isSelected, dtoField) then
        dto[fieldName] = dtoField.placeholder
    end
end

function DtoBuilder.buildFullDto(baseDto, source, dtoFields, fieldPolicies, isSelected)
    for fieldName, dtoField in pairs(dtoFields or {}) do
        applyField(baseDto, source, fieldName, dtoField, fieldPolicies, isSelected)
    end
    return baseDto
end

function DtoBuilder.buildPatchDto(baseDto, source, dirtyFields, dtoFields, fieldPolicies, isSelected)
    for fieldName in pairs(dirtyFields or {}) do
        local dtoField = dtoFields and dtoFields[fieldName]
        if dtoField then applyField(baseDto, source, fieldName, dtoField, fieldPolicies, isSelected) end
    end
    return baseDto
end

return DtoBuilder
