if AkDebugLoad then print("[#Start] Loading ce.hub.sync.SyncPolicy ...") end

local SyncPolicy = {}

local validModes = {
    all = true,
    none = true,
    selected = true
}

function SyncPolicy.normalizeMode(mode, isDynamic)
    local resolvedMode = mode or "all"
    assert(validModes[resolvedMode] == true, "Invalid ceType sync mode: " .. tostring(mode))
    if resolvedMode == "selected" and not isDynamic then
        return "all"
    end
    return resolvedMode
end

function SyncPolicy.getMode(ceTypeOptions, isDynamic)
    if type(ceTypeOptions) ~= "table" then
        return SyncPolicy.normalizeMode(nil, isDynamic)
    end
    return SyncPolicy.normalizeMode(ceTypeOptions.mode, isDynamic)
end

function SyncPolicy.isActive(ceTypeOptions, isDynamic)
    return SyncPolicy.getMode(ceTypeOptions, isDynamic) ~= "none"
end

function SyncPolicy.isSelected(ceTypeOptions, isDynamic)
    return SyncPolicy.getMode(ceTypeOptions, isDynamic) == "selected"
end

function SyncPolicy.shouldCollect(fieldOptions)
    return not (type(fieldOptions) == "table" and fieldOptions.collect == false)
end

return SyncPolicy
