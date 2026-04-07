if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local VersionDtoFactory = require("ce.hub.data.version.VersionDtoFactory")
local VersionRegistry = require("ce.hub.data.version.VersionRegistry")

local VersionPublisher = {}

function VersionPublisher.syncState()
    local versionInfo = VersionRegistry.get()
    if versionInfo then
        DataChangeBus.fireListChange(VersionDtoFactory.createVersionDtoList(versionInfo))
    end
    return {}
end

return VersionPublisher
