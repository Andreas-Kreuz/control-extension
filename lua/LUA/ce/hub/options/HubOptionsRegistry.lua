if CeDebugLoad then print("[#Start] Loading ce.hub.options.HubOptionsRegistry ...") end

local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local HubOptionDefaults = require("ce.hub.options.HubOptionDefaults")
local TableUtils = require("ce.hub.util.TableUtils")

local HubOptionsRegistry = {}
local state = HubOptionDefaults.create()

local function sortedKeys(tb)
    local keys = {}
    for key in pairs(tb or {}) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function (left, right) return tostring(left) < tostring(right) end)
    return keys
end

local function appendLines(lines, value, indent)
    local prefix = string.rep(" ", indent)
    if type(value) ~= "table" then
        if type(value) == "string" then
            lines[#lines + 1] = prefix .. string.format("%q", value)
        else
            lines[#lines + 1] = prefix .. tostring(value)
        end
        return
    end

    lines[#lines + 1] = prefix .. "{"
    for _, key in ipairs(sortedKeys(value)) do
        local entry = value[key]
        local entryPrefix = string.rep(" ", indent + 4) .. tostring(key) .. " = "
        if type(entry) == "table" then
            lines[#lines + 1] = entryPrefix
            appendLines(lines, entry, indent + 8)
        elseif type(entry) == "string" then
            lines[#lines + 1] = entryPrefix .. string.format("%q", entry)
        else
            lines[#lines + 1] = entryPrefix .. tostring(entry)
        end
    end
    lines[#lines + 1] = prefix .. "}"
end

function HubOptionsRegistry.reset()
    state = HubOptionDefaults.create()
end

function HubOptionsRegistry.copyTable(value)
    return TableUtils.deepcopy(value)
end

function HubOptionsRegistry.setOptions(options)
    state = TableUtils.deepcopy(options or { ceTypes = {} })
    state.ceTypes = state.ceTypes or {}
end

function HubOptionsRegistry.getCeTypeOptions(alias)
    local ceTypeOptions = TableUtils.deepcopy(state.ceTypes[alias] or {})
    ceTypeOptions.fieldUpdates = nil
    ceTypeOptions.fieldPublish = nil
    return ceTypeOptions
end

function HubOptionsRegistry.getFieldUpdatePolicies(alias)
    local ceTypeOptions = state.ceTypes[alias] or {}
    return ceTypeOptions.fieldUpdates or {}
end

function HubOptionsRegistry.getFieldPublishPolicies(alias)
    local ceTypeOptions = state.ceTypes[alias] or {}
    return ceTypeOptions.fieldPublish or {}
end

function HubOptionsRegistry.isDiscoveryAndUpdateEnabled(alias)
    return SyncPolicy.isDiscoveryAndUpdateEnabled(HubOptionsRegistry.getCeTypeOptions(alias))
end

function HubOptionsRegistry.isAnyDiscoveryAndUpdateEnabled(...)
    for i = 1, select("#", ...) do
        if HubOptionsRegistry.isDiscoveryAndUpdateEnabled(select(i, ...)) then return true end
    end
    return false
end

function HubOptionsRegistry.isPublishEnabled(alias)
    return SyncPolicy.isPublishEnabled(HubOptionsRegistry.getCeTypeOptions(alias))
end

function HubOptionsRegistry.isCeTypePublishEnabled(ceType)
    for alias, ceTypeOptions in pairs(state.ceTypes) do
        if ceTypeOptions.ceType == ceType then
            return HubOptionsRegistry.isPublishEnabled(alias)
        end
    end
    return true
end

function HubOptionsRegistry.getAllCeTypeOptions()
    local ceTypes = {}
    for alias, options in pairs(state.ceTypes) do
        ceTypes[alias] = TableUtils.deepcopy(options)
        ceTypes[alias].fieldUpdates = nil
        ceTypes[alias].fieldPublish = nil
    end
    return ceTypes
end

function HubOptionsRegistry.getAllOptions()
    return TableUtils.deepcopy(state)
end

function HubOptionsRegistry.formatOptions()
    local lines = { "HubOptionsRegistry = " }
    appendLines(lines, HubOptionsRegistry.getAllOptions(), 0)
    return table.concat(lines, "\n")
end

function HubOptionsRegistry.printOptions()
    local output = HubOptionsRegistry.formatOptions()
    print(output)
    return output
end

return HubOptionsRegistry
