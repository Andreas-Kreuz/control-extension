if CeDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionRegistry ...") end

local VersionRegistry = {}

local versionInfo = nil

function VersionRegistry.set(entry)
    versionInfo = entry
end

function VersionRegistry.get()
    return versionInfo
end

return VersionRegistry
