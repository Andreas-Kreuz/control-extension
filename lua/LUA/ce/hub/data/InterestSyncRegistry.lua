if CeDebugLoad then print("[#Start] Loading ce.hub.data.InterestSyncRegistry ...") end

local InterestSyncRegistry = {}

local selectedByCeType = {}
local sourceSelectedByCeType = {}
local pendingInitialSendByCeType = {}

local function ensureCeTypeTable(container, ceType)
    if not container[ceType] then
        container[ceType] = {}
    end
    return container[ceType]
end

local function hasSourceInterest(ceType, key)
    return sourceSelectedByCeType[ceType] and sourceSelectedByCeType[ceType][key]
        and next(sourceSelectedByCeType[ceType][key]) ~= nil or false
end

function InterestSyncRegistry.startSyncFor(ceType, key)
    assert(type(ceType) == "string", "Need 'ceType' as string")
    assert(type(key) == "string", "Need 'key' as string")

    ensureCeTypeTable(selectedByCeType, ceType)[key] = true
    ensureCeTypeTable(pendingInitialSendByCeType, ceType)[key] = true
end

function InterestSyncRegistry.stopSyncFor(ceType, key)
    assert(type(ceType) == "string", "Need 'ceType' as string")
    assert(type(key) == "string", "Need 'key' as string")

    if selectedByCeType[ceType] then selectedByCeType[ceType][key] = nil end
    if not hasSourceInterest(ceType, key) and pendingInitialSendByCeType[ceType] then
        pendingInitialSendByCeType[ceType][key] = nil
    end
end

function InterestSyncRegistry.startSyncForSource(ceType, key, source)
    assert(type(ceType) == "string", "Need 'ceType' as string")
    assert(type(key) == "string", "Need 'key' as string")
    assert(type(source) == "string", "Need 'source' as string")

    local selectedByKey = ensureCeTypeTable(sourceSelectedByCeType, ceType)
    selectedByKey[key] = selectedByKey[key] or {}
    selectedByKey[key][source] = true
    ensureCeTypeTable(pendingInitialSendByCeType, ceType)[key] = true
end

function InterestSyncRegistry.stopSyncForSource(ceType, key, source)
    assert(type(ceType) == "string", "Need 'ceType' as string")
    assert(type(key) == "string", "Need 'key' as string")
    assert(type(source) == "string", "Need 'source' as string")

    local selectedByKey = sourceSelectedByCeType[ceType]
    if not selectedByKey or not selectedByKey[key] then return end

    selectedByKey[key][source] = nil
    if not next(selectedByKey[key]) then selectedByKey[key] = nil end
    if not InterestSyncRegistry.isSelected(ceType, key) and pendingInitialSendByCeType[ceType] then
        pendingInitialSendByCeType[ceType][key] = nil
    end
end

function InterestSyncRegistry.isSelected(ceType, key)
    if selectedByCeType[ceType] and selectedByCeType[ceType][key] == true then return true end
    return hasSourceInterest(ceType, key)
end

function InterestSyncRegistry.getSelectedKeys(ceType)
    assert(type(ceType) == "string", "Need 'ceType' as string")

    local copy = {}
    for key in pairs(selectedByCeType[ceType] or {}) do copy[key] = true end
    for key, sources in pairs(sourceSelectedByCeType[ceType] or {}) do
        if next(sources) then copy[key] = true end
    end
    return copy
end

function InterestSyncRegistry.needsInitialSend(ceType, key)
    return pendingInitialSendByCeType[ceType] and pendingInitialSendByCeType[ceType][key] == true or false
end

function InterestSyncRegistry.markSent(ceType, key)
    if pendingInitialSendByCeType[ceType] then
        pendingInitialSendByCeType[ceType][key] = nil
    end
end

function InterestSyncRegistry.clearAll()
    selectedByCeType = {}
    sourceSelectedByCeType = {}
    pendingInitialSendByCeType = {}
end

return InterestSyncRegistry
