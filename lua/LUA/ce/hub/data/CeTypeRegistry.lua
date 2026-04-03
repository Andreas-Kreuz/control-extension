if AkDebugLoad then print("[#Start] Loading ce.hub.data.CeTypeRegistry ...") end

local CeTypeRegistry = {}
local registeredCeTypes = {}

local function copyDefinition(def)
    return {
        ceType = def.ceType,
        keyId = def.keyId,
        owner = def.owner,
        publisher = def.publisher
    }
end

local function assertValidDefinition(def)
    assert(type(def) == "table", "expected ceType definition")
    assert(type(def.ceType) == "string" and def.ceType ~= "", "expected ceType")
    assert(type(def.keyId) == "string" and def.keyId ~= "", "expected keyId")
    assert(type(def.owner) == "string" and def.owner ~= "", "expected owner")
end

function CeTypeRegistry.registerCeType(def)
    assertValidDefinition(def)

    local existing = registeredCeTypes[def.ceType]
    if existing then
        assert(existing.keyId == def.keyId, "ceType already registered with different keyId: " .. def.ceType)
        assert(existing.owner == def.owner, "ceType already registered with different owner: " .. def.ceType)
        return existing
    end

    local normalized = copyDefinition(def)
    registeredCeTypes[def.ceType] = normalized
    return normalized
end

function CeTypeRegistry.registerCeTypes(...)
    local registrations = {}
    for i = 1, select("#", ...) do
        registrations[i] = CeTypeRegistry.registerCeType(select(i, ...))
    end
    return registrations
end

function CeTypeRegistry.getCeTypeDefinition(ceType)
    return registeredCeTypes[ceType]
end

function CeTypeRegistry.isRegistered(ceType)
    return registeredCeTypes[ceType] ~= nil
end

function CeTypeRegistry.getAllCeTypes()
    local copy = {}
    for ceType, def in pairs(registeredCeTypes) do copy[ceType] = copyDefinition(def) end
    return copy
end

return CeTypeRegistry
