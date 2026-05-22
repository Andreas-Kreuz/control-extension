if CeDebugLoad then print("[#Start] Loading ce.mods.road.LightStructureTrafficLight ...") end

local StorageUtility = require("ce.hub.util.StorageUtility")

---@class LightStructureTrafficLight
local LightStructureTrafficLight = {}

local knownTagKeys = {
    F0 = true,
    F1 = true,
    F2 = true,
    F3 = true,
    F4 = true,
    F5 = true,
    A = true,
    bl = true,
    r = true,
    y = true,
    g = true
}

local function normalized(value)
    return string.lower(value or "")
end

local function greenKeyForName(name)
    local value = normalized(name)
    if string.find(value, "vorfahrt beachten") then return "F5" end
    if string.find(value, "rechts") then return "F2" end
    if string.find(value, "links") then return "F3" end
    return "F1"
end

local function clearInstallerTags(values)
    for key in pairs(values) do
        if knownTagKeys[key] or string.match(key, "^p[1-5]$") then values[key] = nil end
    end
end

local function setTagValue(values, key, value)
    if type(value) == "string" and value ~= "" then values[key] = value end
end

local function setStructureTag(structureName, tagText)
    if type(structureName) == "string" and structureName ~= "" then
        EEPStructureSetTagText(structureName, tagText)
    end
end

local function updateStructureTags(redStructure, greenStructure, yellowStructure, requestStructure, housingStructure,
                                   blendStructure)
    if type(housingStructure) ~= "string" or housingStructure == "" then return end
    local _, currentTag = EEPStructureGetTagText(housingStructure)
    local values = StorageUtility.parseTableFromString(currentTag)
    clearInstallerTags(values)
    setTagValue(values, "F0", redStructure)
    setTagValue(values, greenKeyForName(greenStructure), greenStructure)
    setTagValue(values, "F4", yellowStructure)
    setTagValue(values, "A", requestStructure)
    setTagValue(values, "bl", blendStructure)
    if values.F0 then values.r = values.F0 end
    if values.F4 then values.y = values.F4 end
    if greenStructure and greenStructure ~= "" then values.g = greenStructure end
    local tagText = StorageUtility.encodeTable(values)
    setStructureTag(housingStructure, tagText)
    setStructureTag(redStructure, tagText)
    setStructureTag(greenStructure, tagText)
    setStructureTag(yellowStructure, tagText)
    setStructureTag(requestStructure, tagText)
    setStructureTag(blendStructure, tagText)
end

--- Schaltet das Licht der angegebenen Immobilien beim Schalten der Ampel auf rot, gelb, grün oder Anforderung
---@param redStructure string Immo deren Licht eingeschaltet wird, wenn die Ampel rot oder rot-gelb ist
---@param greenStructure string Immo deren Licht eingeschaltet wird, wenn die Ampel grün ist
---@param yellowStructure string Immo deren Licht eingeschaltet wird, wenn die Ampel gelb oder rot-gelb ist
---@param requestStructure string Immo deren Licht eingeschaltet wird, wenn die Ampel eine Anforderung erkennt
---@param housingStructure string|nil Gehaeuse, dessen Tag mit den Immobiliennamen befuellt wird
---@param blendStructure string|nil Blendschutz, der im Gehaeuse-Tag hinterlegt wird
--
function LightStructureTrafficLight:new(redStructure, greenStructure, yellowStructure, requestStructure,
                                        housingStructure, blendStructure)
    assert(type(redStructure) == "string", "Need 'redStructure' as string")
    assert(EEPStructureGetLight(redStructure), redStructure)
    assert(type(greenStructure) == "string", "Need 'greenStructure' as string")
    assert(EEPStructureGetLight(greenStructure), greenStructure)
    if yellowStructure then
        assert(type(yellowStructure) == "string", "Need 'yellowStructure' as string")
        assert(EEPStructureGetLight(yellowStructure), yellowStructure)
    end
    if requestStructure then
        assert(type(requestStructure) == "string",
               "Need 'requestStructure' as string not as " .. type(requestStructure))
        assert(EEPStructureGetLight(requestStructure), requestStructure)
    end
    if housingStructure then assert(type(housingStructure) == "string", "Need 'housingStructure' as string") end
    if blendStructure then assert(type(blendStructure) == "string", "Need 'blendStructure' as string") end
    updateStructureTags(redStructure, greenStructure, yellowStructure, requestStructure, housingStructure,
                        blendStructure)
    local o = {
        redStructure = redStructure,
        greenStructure = greenStructure,
        yellowStructure = yellowStructure or redStructure,
        requestStructure = requestStructure,
        housingStructure = housingStructure,
        blendStructure = blendStructure
    }
    self.__index = self
    o = setmetatable(o, self)
    return o
end

return LightStructureTrafficLight
