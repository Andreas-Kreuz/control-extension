if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local VersionDtoFactory = require("ce.hub.data.version.VersionDtoFactory")
local VersionRegistry = require("ce.hub.data.version.VersionRegistry")

local VersionPublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

function VersionPublisher.syncState()
    local versionInfo = VersionRegistry.get()
    if versionInfo then
        if versionInfo.needsFullSend then
            DataChangeBus.fireDataChanged(VersionDtoFactory.createFullDto(versionInfo))
            versionInfo.needsFullSend = false
            versionInfo:resetDirty()
        elseif versionInfo:hasDirtyFields() then
            local ceType, keyId, key, dto = VersionDtoFactory.createPatchDto(versionInfo, versionInfo.dirtyFields)
            if hasPayloadFields(dto) then DataChangeBus.fireDataChanged(ceType, keyId, key, dto) end
            versionInfo:resetDirty()
        end
    end
end

return VersionPublisher
