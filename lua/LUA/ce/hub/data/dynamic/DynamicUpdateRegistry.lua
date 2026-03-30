if AkDebugLoad then print("[#Start] Loading ce.hub.data.dynamic.DynamicUpdateRegistry ...") end

local DynamicUpdateRegistry = {}

local selectedByCeType = {}
local pendingInitialSendByCeType = {}

local function ensureCeTypeTable(container, ceType)
    if not container[ceType] then
        container[ceType] = {}
    end
    return container[ceType]
end

function DynamicUpdateRegistry.startUpdatesFor(ceType, key)
    assert(type(ceType) == "string", "Need 'ceType' as string")
    assert(type(key) == "string", "Need 'key' as string")

    ensureCeTypeTable(selectedByCeType, ceType)[key] = true
    ensureCeTypeTable(pendingInitialSendByCeType, ceType)[key] = true
end

function DynamicUpdateRegistry.stopUpdatesFor(ceType, key)
    assert(type(ceType) == "string", "Need 'ceType' as string")
    assert(type(key) == "string", "Need 'key' as string")

    if selectedByCeType[ceType] then selectedByCeType[ceType][key] = nil end
    if pendingInitialSendByCeType[ceType] then pendingInitialSendByCeType[ceType][key] = nil end
end

function DynamicUpdateRegistry.isSelected(ceType, key)
    return selectedByCeType[ceType] and selectedByCeType[ceType][key] == true or false
end

function DynamicUpdateRegistry.needsInitialSend(ceType, key)
    return pendingInitialSendByCeType[ceType] and pendingInitialSendByCeType[ceType][key] == true or false
end

function DynamicUpdateRegistry.markSent(ceType, key)
    if pendingInitialSendByCeType[ceType] then
        pendingInitialSendByCeType[ceType][key] = nil
    end
end

function DynamicUpdateRegistry.clearAll()
    selectedByCeType = {}
    pendingInitialSendByCeType = {}
end

return DynamicUpdateRegistry
