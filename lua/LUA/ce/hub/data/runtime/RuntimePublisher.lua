if CeDebugLoad then print("[#Start] Loading ce.hub.data.runtime.RuntimePublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local RuntimeDtoFactory = require("ce.hub.data.runtime.RuntimeDtoFactory")
local RuntimeRegistry = require("ce.hub.data.runtime.RuntimeRegistry")

local RuntimePublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

function RuntimePublisher.syncState()
    local runtimeEntries = RuntimeRegistry.get()
    for runtimeId in pairs(RuntimeRegistry.getRemovedIds()) do
        DataChangeBus.fireDataRemoved(RuntimeDtoFactory.createRemovalDto(runtimeId))
    end
    RuntimeRegistry.clearRemoved()

    for _, runtimeEntry in pairs(runtimeEntries or {}) do
        if runtimeEntry.needsFullSend then
            DataChangeBus.fireDataChanged(RuntimeDtoFactory.createFullDto(runtimeEntry))
            runtimeEntry.needsFullSend = false
            runtimeEntry:resetDirty()
        elseif runtimeEntry:hasDirtyFields() then
            local ceType, keyId, key, dto = RuntimeDtoFactory.createPatchDto(runtimeEntry, runtimeEntry.dirtyFields)
            if hasPayloadFields(dto) then DataChangeBus.fireDataChanged(ceType, keyId, key, dto) end
            runtimeEntry:resetDirty()
        end
    end
end

return RuntimePublisher
