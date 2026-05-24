if CeDebugLoad then print("[#Start] Loading ce.hub.data.DataClass ...") end

local DataClass = {}

function DataClass.init(instance)
    instance.dirtyFields = instance.dirtyFields or {}
    instance.loadedFields = instance.loadedFields or {}
    if instance.needsFullSend == nil then instance.needsFullSend = true end
    return instance
end

function DataClass.markLoaded(instance, fieldName)
    instance.loadedFields = instance.loadedFields or {}
    instance.loadedFields[fieldName] = true
end

function DataClass.isLoaded(instance, fieldName)
    return instance.loadedFields and instance.loadedFields[fieldName] == true
end

function DataClass.markDirty(instance, fieldName)
    instance.dirtyFields = instance.dirtyFields or {}
    instance.dirtyFields[fieldName] = true
end

function DataClass.replaceField(instance, fieldName, value)
    local oldValue = instance[fieldName]
    instance[fieldName] = value
    DataClass.markLoaded(instance, fieldName)
    if oldValue ~= value then
        DataClass.markDirty(instance, fieldName)
        return true
    end
    return false
end

function DataClass.replaceFields(instance, values)
    local changed = false
    for fieldName, value in pairs(values or {}) do
        changed = DataClass.replaceField(instance, fieldName, value) or changed
    end
    return changed
end

function DataClass.seedField(instance, fieldName, value)
    return DataClass.replaceField(instance, fieldName, value)
end

function DataClass.resetDirty(instance)
    instance.dirtyFields = {}
end

function DataClass.hasDirtyFields(instance)
    return next(instance.dirtyFields or {}) ~= nil
end

function DataClass.isCallable(value)
    if type(value) == "function" then return true end
    local metatable = type(value) == "table" and getmetatable(value) or nil
    return metatable and type(metatable.__call) == "function" or false
end

return DataClass
