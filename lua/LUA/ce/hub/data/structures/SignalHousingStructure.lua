if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.SignalHousingStructure ...") end

local SignalHousingStructure = {}

function SignalHousingStructure.isSignalHousing(structure)
    local gsbname = string.lower(tostring(structure and structure:peekGsbname() or "")):gsub("/", "\\")
    return string.match(gsbname, "^\\immobilien\\verkehr\\signale\\strabasigg.*ma1%.3dm$") ~= nil
end

return SignalHousingStructure
