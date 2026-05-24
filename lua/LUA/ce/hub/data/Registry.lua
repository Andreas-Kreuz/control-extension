if CeDebugLoad then print("[#Start] Loading ce.hub.data.Registry ...") end

local Registry = {}

function Registry.create(options)
    options = options or {}
    local registry = {}
    local entries = {}
    local addedIds = {}
    local removedIds = {}
    local revision = 0
    local idField = options.idField or "id"

    local function markChanged()
        revision = revision + 1
    end

    local function idOf(entry)
        return entry and entry[idField]
    end

    function registry.has(id)
        return entries[id] ~= nil
    end

    function registry.add(entry)
        assert(type(entry) == "table", "Need entry as table")
        local id = idOf(entry)
        assert(id ~= nil, "Need entry id")
        if entries[id] == entry then return entry, false end
        entries[id] = entry
        addedIds[id] = true
        removedIds[id] = nil
        markChanged()
        return entry, true
    end

    function registry.replaceAll(nextEntries)
        local nextById = {}
        local nextIds = {}
        for _, entry in ipairs(nextEntries or {}) do
            local id = idOf(entry)
            if id ~= nil then
                nextById[id] = entry
                nextIds[id] = true
                if entries[id] == nil then addedIds[id] = true end
                removedIds[id] = nil
            end
        end
        for id in pairs(entries) do
            if not nextIds[id] then
                if addedIds[id] then
                    addedIds[id] = nil
                else
                    removedIds[id] = true
                end
            end
        end
        entries = nextById
        markChanged()
    end

    function registry.remove(id)
        if entries[id] == nil then return end
        entries[id] = nil
        if addedIds[id] then
            addedIds[id] = nil
        else
            removedIds[id] = true
        end
        markChanged()
    end

    function registry.get(id)
        return entries[id]
    end

    function registry.forEach(callback)
        assert(type(callback) == "function", "Need callback as function")
        for id, entry in pairs(entries) do callback(entry, id) end
    end

    function registry.getRevision()
        return revision
    end

    function registry.getAll()
        local copy = {}
        for id, entry in pairs(entries) do copy[id] = entry end
        return copy
    end

    function registry.getAddedIds()
        local copy = {}
        for id in pairs(addedIds) do copy[id] = true end
        return copy
    end

    function registry.getRemovedIds()
        local copy = {}
        for id in pairs(removedIds) do copy[id] = true end
        return copy
    end

    function registry.clearPendingChanges()
        addedIds = {}
        removedIds = {}
    end

    return registry
end

return Registry
