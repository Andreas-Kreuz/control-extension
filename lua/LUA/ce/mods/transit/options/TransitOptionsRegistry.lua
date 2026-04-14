if CeDebugLoad then print("[#Start] Loading ce.mods.transit.options.TransitOptionsRegistry ...") end

local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local TransitOptionDefaults = require("ce.mods.transit.options.TransitOptionDefaults")
local TableUtils = require("ce.hub.util.TableUtils")

local TransitOptionsRegistry = {}
local state = TransitOptionDefaults.create()

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

function TransitOptionsRegistry.reset()
    state = TransitOptionDefaults.create()
end

function TransitOptionsRegistry.copyTable(value)
    return TableUtils.deepcopy(value)
end

function TransitOptionsRegistry.setOptions(options)
    state = TableUtils.deepcopy(options or { ceTypes = {} })
    state.ceTypes = state.ceTypes or {}
end

function TransitOptionsRegistry.getCeTypeOptions(alias)
    local ceTypeOptions = TableUtils.deepcopy(state.ceTypes[alias] or {})
    ceTypeOptions.fieldUpdates = nil
    ceTypeOptions.fieldPublish = nil
    return ceTypeOptions
end

function TransitOptionsRegistry.getFieldUpdatePolicies(alias)
    local ceTypeOptions = state.ceTypes[alias] or {}
    return ceTypeOptions.fieldUpdates or {}
end

function TransitOptionsRegistry.getFieldPublishPolicies(alias)
    local ceTypeOptions = state.ceTypes[alias] or {}
    return ceTypeOptions.fieldPublish or {}
end

function TransitOptionsRegistry.isPublishEnabled(alias)
    return SyncPolicy.isPublishEnabled(TransitOptionsRegistry.getCeTypeOptions(alias))
end

function TransitOptionsRegistry.getAllCeTypeOptions()
    local ceTypes = {}
    for alias, options in pairs(state.ceTypes) do
        ceTypes[alias] = TableUtils.deepcopy(options)
        ceTypes[alias].fieldUpdates = nil
        ceTypes[alias].fieldPublish = nil
    end
    return ceTypes
end

function TransitOptionsRegistry.getAllOptions()
    return TableUtils.deepcopy(state)
end

function TransitOptionsRegistry.formatOptions()
    local lines = { "TransitOptionsRegistry = " }
    appendLines(lines, TransitOptionsRegistry.getAllOptions(), 0)
    return table.concat(lines, "\n")
end

function TransitOptionsRegistry.printOptions()
    local output = TransitOptionsRegistry.formatOptions()
    print(output)
    return output
end

return TransitOptionsRegistry
