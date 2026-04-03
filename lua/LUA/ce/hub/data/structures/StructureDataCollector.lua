if AkDebugLoad then print("[#Start] Loading ce.hub.data.structures.StructureDataCollector ...") end

local StructureDataCollector = {}

local MAX_STRUCTURES = 50000

local EEPStructureGetLight = _G.EEPStructureGetLight or function () end         -- EEP 11.1 Plug-In 1
local EEPStructureGetSmoke = _G.EEPStructureGetSmoke or function () end         -- EEP 11.1 Plug-In 1
local EEPStructureGetFire = _G.EEPStructureGetFire or function () end           -- EEP 11.1 Plug-In 1
local EEPStructureGetPosition = _G.EEPStructureGetPosition or function () end   -- EEP 14.2
local EEPStructureGetModelType = _G.EEPStructureGetModelType or function () end -- EEP 14.2
local EEPStructureGetTagText = _G.EEPStructureGetTagText or function () end     -- EEP 14.2
local EEPStructureGetRotation = _G.EEPStructureGetRotation or function () end   -- EEP 16.1

local EEPStructureModelTypeText = {
    [16] = "Gleis/Gleisobjekt",
    [17] = "Schiene/Gleisobjekt",
    [18] = "Strasse/Gleisobjekt",
    [19] = "Sonstiges/Gleisobjekt",
    [22] = "Immobilie",
    [23] = "Landschaftselement/Fauna",
    [24] = "Landschaftselement/Flora",
    [25] = "Landschaftselement/Terra",
    [38] = "Landschaftselement/Instancing"
}

local function round2(value)
    return value and tonumber(string.format("%.2f", value)) or 0
end

local function readDynamicStructureValues(name)
    local hasLight, light = EEPStructureGetLight(name)
    local hasSmoke, smoke = EEPStructureGetSmoke(name)
    local hasFire, fire = EEPStructureGetFire(name)
    local hasPosition, pos_x, pos_y, pos_z = EEPStructureGetPosition(name)
    local hasRotation, rot_x, rot_y, rot_z = EEPStructureGetRotation(name)
    local hasTag, tag = EEPStructureGetTagText(name)
    return {
        exists = hasLight or hasSmoke or hasFire or hasPosition or hasRotation or hasTag,
        light = light,
        smoke = smoke,
        fire = fire,
        pos_x = pos_x,
        pos_y = pos_y,
        pos_z = pos_z,
        rot_x = rot_x,
        rot_y = rot_y,
        rot_z = rot_z,
        tag = tag
    }
end

local function createStructure(name, values)
    local structure = {}
    structure.id = name
    structure.name = name

    local _, modelType = EEPStructureGetModelType(name)

    structure.pos_x = round2(values.pos_x)
    structure.pos_y = round2(values.pos_y)
    structure.pos_z = round2(values.pos_z)
    structure.rot_x = round2(values.rot_x)
    structure.rot_y = round2(values.rot_y)
    structure.rot_z = round2(values.rot_z)
    structure.modelType = modelType or 0
    structure.modelTypeText = EEPStructureModelTypeText[modelType] or ""
    structure.tag = values.tag or ""
    structure.light = values.light
    structure.smoke = values.smoke
    structure.fire = values.fire

    return structure
end

function StructureDataCollector.collectInitialStructures()
    local structures = {}

    for i = 0, MAX_STRUCTURES do
        local name = "#" .. tostring(i)
        local values = readDynamicStructureValues(name)
        local hasModelType = EEPStructureGetModelType(name)

        if values.exists or hasModelType then
            table.insert(structures, createStructure(name, values))
        end
    end

    return structures
end

---@param existingStructures table
function StructureDataCollector.refreshDirtyStructures(existingStructures)
    local dirtyStructures = {}

    for i = 1, #existingStructures do
        local structure = existingStructures[i]
        local values = readDynamicStructureValues(structure.name)
        local pos_x = round2(values.pos_x)
        local pos_y = round2(values.pos_y)
        local pos_z = round2(values.pos_z)
        local rot_x = round2(values.rot_x)
        local rot_y = round2(values.rot_y)
        local rot_z = round2(values.rot_z)
        local tag = values.tag or ""

        if values.light ~= structure.light or values.fire ~= structure.fire or values.smoke ~= structure.smoke or
            pos_x ~= structure.pos_x or pos_y ~= structure.pos_y or pos_z ~= structure.pos_z or
            rot_x ~= structure.rot_x or rot_y ~= structure.rot_y or rot_z ~= structure.rot_z or
            tag ~= structure.tag then
            structure.light = values.light
            structure.smoke = values.smoke
            structure.fire = values.fire
            structure.pos_x = pos_x
            structure.pos_y = pos_y
            structure.pos_z = pos_z
            structure.rot_x = rot_x
            structure.rot_y = rot_y
            structure.rot_z = rot_z
            structure.tag = tag
            table.insert(dirtyStructures, structure)
        end
    end

    return dirtyStructures
end

return StructureDataCollector
