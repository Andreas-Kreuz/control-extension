if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionRegistry ...") end

local Version = require("ce.hub.data.version.Version")

local VersionRegistry = {}

local versionInfo = nil

function VersionRegistry.set(entry)
    if not entry then
        versionInfo = nil
        return
    end

    entry.id = entry.id or "versionInfo"
    entry.name = entry.name or "versionInfo"

    if versionInfo then
        versionInfo:update(entry)
    else
        versionInfo = Version:new(entry)
    end
end

function VersionRegistry.get()
    return versionInfo
end

return VersionRegistry
