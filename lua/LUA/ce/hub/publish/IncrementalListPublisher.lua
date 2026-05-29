if CeDebugLoad then print("[#Start] Loading ce.hub.publish.IncrementalListPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")

local IncrementalListPublisher = {}

local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, entry in pairs(value) do copy[key] = deepCopy(entry) end
    return copy
end

local function deepEquals(left, right)
    if left == right then return true end
    if type(left) ~= "table" or type(right) ~= "table" then return false end

    for key, leftValue in pairs(left) do
        if not deepEquals(leftValue, right[key]) then return false end
    end
    for key in pairs(right) do
        if left[key] == nil then return false end
    end
    return true
end

local function snapshotByKey(keyId, list)
    local snapshot = {}
    for _, dto in pairs(list or {}) do
        snapshot[dto[keyId]] = deepCopy(dto)
    end
    return snapshot
end

local function hasPayloadFields(dto, keyId)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= keyId then return true end
    end
    return false
end

local function createPatchDto(ceType, keyId, key, current, previous)
    local patch = {
        ceType = ceType,
        [keyId] = key
    }
    for fieldName, value in pairs(current or {}) do
        if fieldName ~= "ceType" and fieldName ~= keyId and not deepEquals(value, previous and previous[fieldName]) then
            patch[fieldName] = deepCopy(value)
        end
    end
    return patch
end

function IncrementalListPublisher:new()
    assert(type(self) == "table", "Call this method with ':'")

    local o = {
        snapshotsByCeType = {},
        needsFullSyncByCeType = {}
    }
    self.__index = self
    setmetatable(o, self)
    return o
end

function IncrementalListPublisher:requestFullSync(ceType)
    self.needsFullSyncByCeType[ceType] = true
end

function IncrementalListPublisher:publish(ceType, keyId, list)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(ceType) == "string", "Need 'ceType' as string")
    assert(type(keyId) == "string", "Need 'keyId' as string")
    assert(type(list) == "table", "Need 'list' as table")

    local currentSnapshot = snapshotByKey(keyId, list)
    local previousSnapshot = self.snapshotsByCeType[ceType] or {}

    if self.needsFullSyncByCeType[ceType] ~= false then
        DataChangeBus.fireListChange(ceType, keyId, list)
        self.snapshotsByCeType[ceType] = currentSnapshot
        self.needsFullSyncByCeType[ceType] = false
        return
    end

    for key in pairs(previousSnapshot) do
        if currentSnapshot[key] == nil then
            DataChangeBus.fireDataRemoved(ceType, keyId, key, {
                ceType = ceType,
                [keyId] = key
            })
        end
    end

    for key, current in pairs(currentSnapshot) do
        local previous = previousSnapshot[key]
        if previous == nil then
            DataChangeBus.fireDataAdded(ceType, keyId, key, deepCopy(current))
        else
            local patch = createPatchDto(ceType, keyId, key, current, previous)
            if hasPayloadFields(patch, keyId) then DataChangeBus.fireDataChanged(ceType, keyId, key, patch) end
        end
    end

    self.snapshotsByCeType[ceType] = currentSnapshot
end

return IncrementalListPublisher
