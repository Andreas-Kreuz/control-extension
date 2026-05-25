local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
local StructureTextureTextCache = {}

local valuesByStructure = {}

local function valuesFor(displayStructure)
    local values = valuesByStructure[displayStructure]
    if not values then
        values = {}
        valuesByStructure[displayStructure] = values
    end
    return values
end

function StructureTextureTextCache.set(displayStructure, surfaceNumber, text)
    local nextText = text or ""
    local values = valuesFor(displayStructure)
    if values[surfaceNumber] == nextText then return false end

    values[surfaceNumber] = nextText
    local structure = StructureRegistry.getOrCreate(displayStructure)
    if structure:peekTextureText(surfaceNumber) == nextText then return false end
    return structure:setTextureText(surfaceNumber, nextText)
end

function StructureTextureTextCache.reset(displayStructure)
    valuesByStructure[displayStructure] = nil
end

function StructureTextureTextCache.clear()
    valuesByStructure = {}
end

return StructureTextureTextCache
