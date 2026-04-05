if AkDebugLoad then print("[#Start] Loading ce.hub.data.structures.Structure ...") end

---@class Structure
---@field id string
---@field name string
---@field pos_x number
---@field pos_y number
---@field pos_z number
---@field rot_x number
---@field rot_y number
---@field rot_z number
---@field modelType number
---@field modelTypeText string
---@field tag string
---@field light boolean|nil
---@field smoke boolean|nil
---@field fire boolean|nil
---@field staticValuesUpdated boolean
---@field dynamicValuesUpdated boolean
---@field isInitialized boolean
local Structure = {}

Structure.options = {
    fetchLight = true,
    fetchSmoke = true,
    fetchFire = true,
    fetchTag = true
}

local EEPStructureGetLight = _G.EEPStructureGetLight or function() end
local EEPStructureGetSmoke = _G.EEPStructureGetSmoke or function() end
local EEPStructureGetFire = _G.EEPStructureGetFire or function() end
local EEPStructureGetPosition = _G.EEPStructureGetPosition or function() end
local EEPStructureGetRotation = _G.EEPStructureGetRotation or function() end
local EEPStructureGetModelType = _G.EEPStructureGetModelType or function() end
local EEPStructureGetTagText = _G.EEPStructureGetTagText or function() end

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

local function readStaticValues(name)
    local _, modelType = EEPStructureGetModelType(name)
    local _, pos_x, pos_y, pos_z = EEPStructureGetPosition(name)
    local _, rot_x, rot_y, rot_z = EEPStructureGetRotation(name)

    return {
        modelType = modelType or 0,
        modelTypeText = EEPStructureModelTypeText[modelType] or "",
        pos_x = round2(pos_x),
        pos_y = round2(pos_y),
        pos_z = round2(pos_z),
        rot_x = round2(rot_x),
        rot_y = round2(rot_y),
        rot_z = round2(rot_z)
    }
end

local function readDynamicValues(structure)
    local options = structure.options or Structure.options
    local tag = structure.tag or ""
    local light = structure.light
    local smoke = structure.smoke
    local fire = structure.fire

    if options.fetchTag then
        local _, fetchedTag = EEPStructureGetTagText(structure.name)
        tag = fetchedTag or ""
    end

    if options.fetchLight then
        local _, fetchedLight = EEPStructureGetLight(structure.name)
        light = fetchedLight or false
    end

    if options.fetchSmoke then
        local _, fetchedSmoke = EEPStructureGetSmoke(structure.name)
        smoke = fetchedSmoke or false
    end

    if options.fetchFire then
        local _, fetchedFire = EEPStructureGetFire(structure.name)
        fire = fetchedFire or false
    end

    return {
        tag = tag,
        light = light,
        smoke = smoke,
        fire = fire
    }
end

---@param name string
---@return Structure
function Structure:new(name)
    local o = {
        id = name,
        name = name,
        light = false,
        smoke = false,
        fire = false,
        tag = ""
    }
    self.__index = self
    setmetatable(o, self)

    local staticValues = readStaticValues(name)
    o.modelType = staticValues.modelType
    o.modelTypeText = staticValues.modelTypeText
    o.pos_x = staticValues.pos_x
    o.pos_y = staticValues.pos_y
    o.pos_z = staticValues.pos_z
    o.rot_x = staticValues.rot_x
    o.rot_y = staticValues.rot_y
    o.rot_z = staticValues.rot_z

    o:refresh()
    return o
end

function Structure:refresh()
    local dynamicValues = readDynamicValues(self)
    local staticChanged = not self.isInitialized
        or dynamicValues.tag ~= (self.tag or "")

    local dynamicChanged = not self.isInitialized
        or dynamicValues.light ~= self.light
        or dynamicValues.smoke ~= self.smoke
        or dynamicValues.fire ~= self.fire

    self.staticValuesUpdated = staticChanged
    self.dynamicValuesUpdated = dynamicChanged

    if staticChanged then
        self.tag = dynamicValues.tag
    end

    if dynamicChanged then
        self.light = dynamicValues.light
        self.smoke = dynamicValues.smoke
        self.fire = dynamicValues.fire
    end

    self.isInitialized = true
end

return Structure
