if CeDebugLoad then print("[#Start] Loading ce.hub.publish.InternalDataStore ...") end

local InternalDataStore = {
    ceTypes = {}
}

local function clearTable(tb)
    for key in pairs(tb) do tb[key] = nil end
end

local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, entry in pairs(value) do copy[key] = deepCopy(entry) end
    return copy
end

local function getElementKey(keyId, element)
    return tostring(element[keyId])
end

local function ensureCeType(ceType)
    if not InternalDataStore.ceTypes[ceType] then InternalDataStore.ceTypes[ceType] = {} end
    return InternalDataStore.ceTypes[ceType]
end

local function removeCeTypeIfEmpty(ceType)
    local ceTypeState = InternalDataStore.ceTypes[ceType]
    if not ceTypeState or next(ceTypeState) then return end
    InternalDataStore.ceTypes[ceType] = nil
end

local function replaceCeType(ceType, keyId, list)
    local ceTypeState = {}
    for _, element in pairs(list) do ceTypeState[getElementKey(keyId, element)] = deepCopy(element) end
    InternalDataStore.ceTypes[ceType] = ceTypeState
end

local function mergeElement(ceType, keyId, element)
    local ceTypeState = ensureCeType(ceType)
    local elementKey = getElementKey(keyId, element)
    local existingElement = ceTypeState[elementKey] or {}
    local mergedElement = deepCopy(existingElement)

    for fieldName, value in pairs(element) do mergedElement[fieldName] = deepCopy(value) end
    ceTypeState[elementKey] = mergedElement
end

function InternalDataStore.reset()
    clearTable(InternalDataStore.ceTypes)
end

function InternalDataStore.getCeType(ceType)
    return InternalDataStore.ceTypes[ceType]
end

function InternalDataStore.get(ceType, key)
    local ceTypeState = InternalDataStore.getCeType(ceType)
    if not ceTypeState then return nil end
    return ceTypeState[tostring(key)]
end

function InternalDataStore.fireEvent(event)
    if event.type == "CompleteReset" then
        InternalDataStore.reset()
        return
    end

    local payload = event.payload

    if event.type == "DataAdded" then
        ensureCeType(payload.ceType)[getElementKey(payload.keyId, payload.element)] = deepCopy(payload.element)
        return
    end

    if event.type == "DataChanged" then
        mergeElement(payload.ceType, payload.keyId, payload.element)
        return
    end

    if event.type == "DataRemoved" then
        local ceTypeState = InternalDataStore.getCeType(payload.ceType)
        if not ceTypeState then return end

        ceTypeState[getElementKey(payload.keyId, payload.element)] = nil
        removeCeTypeIfEmpty(payload.ceType)
        return
    end

    if event.type == "ListChanged" then replaceCeType(payload.ceType, payload.keyId, payload.list) end
end

return InternalDataStore
