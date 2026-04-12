if CeDebugLoad then print("[#Start] Loading ce.hub.sync.SyncPolicy ...") end

local SyncPolicy = {}

local validFieldPolicies = {
    always = true,
    oninterest = true,
    never = true
}

function SyncPolicy.normalizeFieldPolicy(policy)
    local resolvedPolicy = policy
    if type(policy) == "table" then
        if policy.policy ~= nil then
            resolvedPolicy = policy.policy
        elseif policy.collect == false then
            resolvedPolicy = "never"
        end
    end

    resolvedPolicy = resolvedPolicy or "always"
    assert(validFieldPolicies[resolvedPolicy] == true, "Invalid field policy: " .. tostring(resolvedPolicy))
    return resolvedPolicy
end

function SyncPolicy.isDiscoveryAndUpdateEnabled(ceTypeOptions)
    if type(ceTypeOptions) ~= "table" then return true end
    return ceTypeOptions.discoveryAndUpdate ~= false
end

function SyncPolicy.isPublishEnabled(ceTypeOptions)
    if type(ceTypeOptions) ~= "table" then return true end
    if ceTypeOptions.publish ~= nil then
        return ceTypeOptions.publish == true
    end
    return ceTypeOptions.mode ~= "none"
end

function SyncPolicy.getFieldPolicy(fieldPolicies, fieldName)
    local fieldPolicy = type(fieldPolicies) == "table" and fieldPolicies[fieldName] or nil
    return SyncPolicy.normalizeFieldPolicy(fieldPolicy)
end

function SyncPolicy.shouldUpdateField(fieldPolicies, fieldName, isSelected)
    local policy = SyncPolicy.getFieldPolicy(fieldPolicies, fieldName)
    return policy == "always" or (policy == "oninterest" and isSelected == true)
end

function SyncPolicy.shouldPublishField(fieldPolicies, fieldName, isSelected)
    local policy = SyncPolicy.getFieldPolicy(fieldPolicies, fieldName)
    return policy == "always" or (policy == "oninterest" and isSelected == true)
end

function SyncPolicy.shouldPublishPlaceholder(fieldPolicies, fieldName, isSelected)
    return SyncPolicy.getFieldPolicy(fieldPolicies, fieldName) == "oninterest" and isSelected ~= true
end

return SyncPolicy
