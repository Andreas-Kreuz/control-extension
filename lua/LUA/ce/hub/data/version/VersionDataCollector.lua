if AkDebugLoad then print("[#Start] Loading ce.hub.data.version.VersionDataCollector ...") end

local VersionInfo = require("ce.hub.data.version.VersionInfo")

local VersionDataCollector = {}

local function callOptional(fn, ...)
    if type(fn) ~= "function" then return nil end

    local ok, value = pcall(fn, ...)
    if not ok then return nil end

    return value
end

function VersionDataCollector.collectVersionInfo()
    return {
        eepVersion = string.format("%.1f", EEPVer),
        luaVersion = _VERSION,
        singleVersion = VersionInfo.getProgramVersion(),
        eepLanguage = EEPLng,
        layoutVersion = callOptional(EEPGetAnlVer),
        layoutLanguage = callOptional(EEPGetAnlLng),
        layoutName = callOptional(EEPGetAnlName),
        layoutPath = callOptional(EEPGetAnlPath)
    }
end

return VersionDataCollector
