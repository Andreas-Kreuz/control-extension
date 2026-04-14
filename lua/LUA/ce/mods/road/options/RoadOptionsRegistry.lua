if CeDebugLoad then print("[#Start] Loading ce.mods.road.options.RoadOptionsRegistry ...") end

local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local RoadOptionDefaults = require("ce.mods.road.options.RoadOptionDefaults")
local TableUtils = require("ce.hub.util.TableUtils")

local RoadOptionsRegistry = {}
local state = RoadOptionDefaults.create()

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

function RoadOptionsRegistry.reset()
    state = RoadOptionDefaults.create()
end

function RoadOptionsRegistry.copyTable(value)
    return TableUtils.deepcopy(value)
end

function RoadOptionsRegistry.setOptions(options)
    state = TableUtils.deepcopy(options or { ceTypes = {} })
    state.ceTypes = state.ceTypes or {}
end

function RoadOptionsRegistry.getCeTypeOptions(alias)
    local ceTypeOptions = TableUtils.deepcopy(state.ceTypes[alias] or {})
    ceTypeOptions.fieldUpdates = nil
    ceTypeOptions.fieldPublish = nil
    return ceTypeOptions
end

function RoadOptionsRegistry.getFieldUpdatePolicies(alias)
    local ceTypeOptions = state.ceTypes[alias] or {}
    return ceTypeOptions.fieldUpdates or {}
end

function RoadOptionsRegistry.getFieldPublishPolicies(alias)
    local ceTypeOptions = state.ceTypes[alias] or {}
    return ceTypeOptions.fieldPublish or {}
end

function RoadOptionsRegistry.isPublishEnabled(alias)
    return SyncPolicy.isPublishEnabled(RoadOptionsRegistry.getCeTypeOptions(alias))
end

function RoadOptionsRegistry.getAllCeTypeOptions()
    local ceTypes = {}
    for alias, options in pairs(state.ceTypes) do
        ceTypes[alias] = TableUtils.deepcopy(options)
        ceTypes[alias].fieldUpdates = nil
        ceTypes[alias].fieldPublish = nil
    end
    return ceTypes
end

function RoadOptionsRegistry.getAllOptions()
    return TableUtils.deepcopy(state)
end

function RoadOptionsRegistry.formatOptions()
    local lines = { "RoadOptionsRegistry = " }
    appendLines(lines, RoadOptionsRegistry.getAllOptions(), 0)
    return table.concat(lines, "\n")
end

function RoadOptionsRegistry.printOptions()
    local output = RoadOptionsRegistry.formatOptions()
    print(output)
    return output
end

return RoadOptionsRegistry
