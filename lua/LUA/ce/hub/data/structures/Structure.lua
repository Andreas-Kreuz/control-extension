if AkDebugLoad then print("[#Start] Loading ce.hub.data.structures.Structure ...") end

-- Field update policies (see StructureDtoTypes.d.lua): all fields always

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
---@field valuesUpdated boolean
---@field isInitialized boolean
local Structure = {}

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

---@param name string
---@return Structure
function Structure:new(name)
    local o = { id = name, name = name }
    self.__index = self
    setmetatable(o, self)
    local _, modelType = EEPStructureGetModelType(name)
    o.modelType = modelType or 0
    o.modelTypeText = EEPStructureModelTypeText[modelType] or ""
    o:refresh()
    return o
end

function Structure:refresh()
    local _, light = EEPStructureGetLight(self.name)
    local _, smoke = EEPStructureGetSmoke(self.name)
    local _, fire = EEPStructureGetFire(self.name)
    local _, pos_x, pos_y, pos_z = EEPStructureGetPosition(self.name)
    local _, rot_x, rot_y, rot_z = EEPStructureGetRotation(self.name)
    local _, tag = EEPStructureGetTagText(self.name)

    local px = round2(pos_x)
    local py = round2(pos_y)
    local pz = round2(pos_z)
    local rx = round2(rot_x)
    local ry = round2(rot_y)
    local rz = round2(rot_z)
    local tagStr = tag or ""

    local changed = not self.isInitialized
        or light ~= self.light
        or smoke ~= self.smoke
        or fire ~= self.fire
        or px ~= self.pos_x or py ~= self.pos_y or pz ~= self.pos_z
        or rx ~= self.rot_x or ry ~= self.rot_y or rz ~= self.rot_z
        or tagStr ~= (self.tag or "")

    if changed then
        self.valuesUpdated = true
        self.isInitialized = true
        self.light = light
        self.smoke = smoke
        self.fire = fire
        self.pos_x = px
        self.pos_y = py
        self.pos_z = pz
        self.rot_x = rx
        self.rot_y = ry
        self.rot_z = rz
        self.tag = tagStr
    end
end

return Structure
