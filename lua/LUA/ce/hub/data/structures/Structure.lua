if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.Structure ...") end

local DataClass = require("ce.hub.data.DataClass")
local TableUtils = require("ce.hub.util.TableUtils")

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
---@field tippText string
---@field tippTextVisible boolean
---@field axisValues table<string, number>
---@field textureTexts table<string, string>
---@field light boolean|nil
---@field smoke boolean|nil
---@field fire boolean|nil
---@field gsbname string|nil
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local Structure = {}

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

local function registryStructure(structureName)
    local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
    return StructureRegistry.get(structureName) or StructureRegistry.getByName(structureName)
end

local function toNumber(value)
    return tonumber(value)
end

local function round2(value)
    return value and tonumber(string.format("%.2f", value)) or 0
end

local function applySeedValues(structure, seedValues)
    seedValues = seedValues or {}
    if seedValues.name ~= nil then structure.name = seedValues.name end
    if seedValues.gsbname ~= nil then structure:seedGsbname(seedValues.gsbname) end
    if seedValues.modelType ~= nil or seedValues.modelTypeText ~= nil then
        structure:seedModelType(seedValues.modelType or structure.modelType,
                                seedValues.modelTypeText or structure.modelTypeText)
    end
    if seedValues.tag ~= nil then structure:seedTag(seedValues.tag) end
    if seedValues.light ~= nil then structure:seedLight(seedValues.light) end
    if seedValues.smoke ~= nil then structure:seedSmoke(seedValues.smoke) end
    if seedValues.fire ~= nil then structure:seedFire(seedValues.fire) end
    if seedValues.tippText ~= nil then structure:seedTippText(seedValues.tippText) end
    if seedValues.tippTextVisible ~= nil then structure:seedTippTextVisible(seedValues.tippTextVisible) end
    if seedValues.textureTexts ~= nil then structure:seedTextureTexts(seedValues.textureTexts) end
    if seedValues.pos_x ~= nil then
        structure:seedPosition(seedValues.pos_x, seedValues.pos_y, seedValues.pos_z)
    end
    if seedValues.rot_x ~= nil then
        structure:seedRotation(seedValues.rot_x, seedValues.rot_y, seedValues.rot_z)
    end
end

function Structure:peekPosX() return self.pos_x end

function Structure:peekName() return self.name end

function Structure:peekPosY() return self.pos_y end

function Structure:peekPosZ() return self.pos_z end

function Structure:peekPosition() return self.pos_x, self.pos_y, self.pos_z end

function Structure:getPosition()
    if not DataClass.isLoaded(self, "pos_x") or not DataClass.isLoaded(self, "pos_y")
        or not DataClass.isLoaded(self, "pos_z") then
        return self:pullPosition()
    end
    return self:peekPosition()
end

function Structure:getPosX()
    if not DataClass.isLoaded(self, "pos_x") then self:pullPosition() end
    return self.pos_x
end

function Structure:getPosY()
    if not DataClass.isLoaded(self, "pos_y") then self:pullPosition() end
    return self.pos_y
end

function Structure:getPosZ()
    if not DataClass.isLoaded(self, "pos_z") then self:pullPosition() end
    return self.pos_z
end

function Structure:peekRotX() return self.rot_x end

function Structure:peekRotY() return self.rot_y end

function Structure:peekRotZ() return self.rot_z end

function Structure:peekRotation() return self.rot_x, self.rot_y, self.rot_z end

function Structure:getRotation()
    if not DataClass.isLoaded(self, "rot_x") or not DataClass.isLoaded(self, "rot_y")
        or not DataClass.isLoaded(self, "rot_z") then
        return self:pullRotation()
    end
    return self:peekRotation()
end

function Structure:getRotX()
    if not DataClass.isLoaded(self, "rot_x") then self:pullRotation() end
    return self.rot_x
end

function Structure:getRotY()
    if not DataClass.isLoaded(self, "rot_y") then self:pullRotation() end
    return self.rot_y
end

function Structure:getRotZ()
    if not DataClass.isLoaded(self, "rot_z") then self:pullRotation() end
    return self.rot_z
end

function Structure:peekModelType() return self.modelType end

function Structure:peekModelTypeText() return self.modelTypeText end

function Structure:getModelType()
    if not DataClass.isLoaded(self, "modelType") then self:pullModelType() end
    return self.modelType
end

function Structure:getModelTypeText()
    if not DataClass.isLoaded(self, "modelTypeText") then self:pullModelType() end
    return self.modelTypeText
end

function Structure:peekTag() return self.tag end

function Structure:getTag()
    if not DataClass.isLoaded(self, "tag") then self:pullTag() end
    return self.tag
end

function Structure:peekLight() return self.light end

function Structure:getLight()
    if not DataClass.isLoaded(self, "light") then self:pullLight() end
    return self.light
end

function Structure:peekSmoke() return self.smoke end

function Structure:getSmoke()
    if not DataClass.isLoaded(self, "smoke") then self:pullSmoke() end
    return self.smoke
end

function Structure:peekFire() return self.fire end

function Structure:getFire()
    if not DataClass.isLoaded(self, "fire") then self:pullFire() end
    return self.fire
end

function Structure:peekGsbname() return self.gsbname end

function Structure:getGsbname() return self.gsbname end

function Structure:setGsbname(name)
    self:replaceGsbname(name)
end

---@param id string
---@param nameOrSeed string|table|nil
---@param seedValues table|nil
---@return Structure
function Structure:new(id, nameOrSeed, seedValues)
    local name = nameOrSeed
    if type(nameOrSeed) == "table" then name = nameOrSeed.name end
    local o = {
        id = id,
        name = name or id,
        pos_x = 0,
        pos_y = 0,
        pos_z = 0,
        rot_x = 0,
        rot_y = 0,
        rot_z = 0,
        modelType = 0,
        modelTypeText = "",
        light = false,
        smoke = false,
        fire = false,
        gsbname = nil,
        tag = "",
        tippText = "",
        tippTextVisible = false,
        axisValues = {},
        textureTexts = {},
        dirtyFields = {},
        needsFullSend = true
    }
    self.__index = self
    setmetatable(o, self)
    DataClass.init(o)
    applySeedValues(o, type(nameOrSeed) == "table" and nameOrSeed or seedValues)

    return o
end

function Structure.readModelType(name, getter)
    getter = getter or _G.EEPStructureGetModelType
    if not name or not DataClass.isCallable(getter) then return false, nil end
    return getter(name)
end

function Structure.exists(name)
    local ok = Structure.readModelType(name)
    return ok == true
end

function Structure:replacePosition(posX, posY, posZ)
    DataClass.replaceField(self, "pos_x", round2(posX))
    DataClass.replaceField(self, "pos_y", round2(posY))
    DataClass.replaceField(self, "pos_z", round2(posZ))
end

function Structure:seedPosition(posX, posY, posZ)
    self:replacePosition(posX, posY, posZ)
end

function Structure:setPosition(posX, posY, posZ)
    local x = toNumber(posX)
    local y = toNumber(posY)
    local z = toNumber(posZ)
    if not x or not y or not z then return false end
    x, y, z = round2(x), round2(y), round2(z)
    if self.pos_x == x and self.pos_y == y and self.pos_z == z then return true end

    local ok = true
    if _G.EEPStructureSetPosition then ok = _G.EEPStructureSetPosition(self.name, x, y, z) ~= false end
    if ok then self:replacePosition(x, y, z) end
    return ok
end

function Structure:pullPosition(getter)
    getter = getter or _G.EEPStructureGetPosition
    if not DataClass.isCallable(getter) then return nil, nil, nil end
    local ok, posX, posY, posZ = getter(self.name)
    if not ok then return nil, nil, nil end
    self:replacePosition(posX, posY, posZ)
    return self.pos_x, self.pos_y, self.pos_z
end

function Structure:replaceRotation(rotX, rotY, rotZ)
    DataClass.replaceField(self, "rot_x", round2(rotX))
    DataClass.replaceField(self, "rot_y", round2(rotY))
    DataClass.replaceField(self, "rot_z", round2(rotZ))
end

function Structure:seedRotation(rotX, rotY, rotZ)
    self:replaceRotation(rotX, rotY, rotZ)
end

function Structure:setRotation(rotX, rotY, rotZ)
    local x = toNumber(rotX)
    local y = toNumber(rotY)
    local z = toNumber(rotZ)
    if not x or not y or not z then return false end
    x, y, z = round2(x), round2(y), round2(z)
    if self.rot_x == x and self.rot_y == y and self.rot_z == z then return true end

    local ok = true
    if _G.EEPStructureSetRotation then ok = _G.EEPStructureSetRotation(self.name, x, y, z) ~= false end
    if ok then self:replaceRotation(x, y, z) end
    return ok
end

function Structure:pullRotation(getter)
    getter = getter or _G.EEPStructureGetRotation
    if not DataClass.isCallable(getter) then return nil, nil, nil end
    local ok, rotX, rotY, rotZ = getter(self.name)
    if not ok then return nil, nil, nil end
    self:replaceRotation(rotX, rotY, rotZ)
    return self.rot_x, self.rot_y, self.rot_z
end

function Structure:replaceModelType(modelType, modelTypeText)
    local value = tonumber(modelType) or 0
    DataClass.replaceField(self, "modelType", value)
    DataClass.replaceField(self, "modelTypeText", modelTypeText or EEPStructureModelTypeText[value] or "")
end

function Structure:seedModelType(modelType, modelTypeText)
    self:replaceModelType(modelType, modelTypeText)
end

function Structure:setModelType(modelType, modelTypeText)
    self:replaceModelType(modelType, modelTypeText)
end

function Structure:pullModelType(getter)
    getter = getter or _G.EEPStructureGetModelType
    if not DataClass.isCallable(getter) then return nil, nil end
    local ok, modelType = getter(self.name)
    if not ok then return nil, nil end
    self:replaceModelType(modelType, EEPStructureModelTypeText[modelType] or "")
    return self.modelType, self.modelTypeText
end

function Structure:replaceTag(tag)
    DataClass.replaceField(self, "tag", tag or "")
end

function Structure:seedTag(tag)
    self:replaceTag(tag)
end

function Structure:setTag(tag)
    local value = tag or ""
    if self.tag == value then return true end
    local ok = true
    if _G.EEPStructureSetTagText then ok = _G.EEPStructureSetTagText(self.name, value) ~= false end
    if ok then self:replaceTag(value) end
    return ok
end

function Structure:pullTag(getter)
    getter = getter or _G.EEPStructureGetTagText
    if not DataClass.isCallable(getter) then return nil end
    local ok, tag = getter(self.name)
    if not ok then return nil end
    self:replaceTag(tag or "")
    return self.tag
end

function Structure:peekAxis(axisName)
    return self.axisValues and self.axisValues[tostring(axisName)] or nil
end

function Structure:getAxis(axisName)
    if self:peekAxis(axisName) == nil then return self:pullAxis(axisName) end
    return self:peekAxis(axisName)
end

function Structure:replaceAxis(axisName, axisValue)
    if not axisName then return false end
    self.axisValues = self.axisValues or {}
    local key = tostring(axisName)
    local value = tonumber(axisValue)
    local oldValue = self.axisValues[key]
    self.axisValues[key] = value
    DataClass.markLoaded(self, "axisValues")
    if oldValue ~= value then
        DataClass.markDirty(self, "axisValues")
        return true
    end
    return false
end

function Structure:setAxis(axisName, axisValue)
    if not axisName then return false end
    local value = tonumber(axisValue)
    if not value then return false end
    if self:peekAxis(axisName) == value then return true end

    local ok = true
    if _G.EEPStructureSetAxis then ok = _G.EEPStructureSetAxis(self.name, axisName, value) ~= false end
    if ok then self:replaceAxis(axisName, value) end
    return ok
end

function Structure:pullAxis(axisName)
    if not axisName or not DataClass.isCallable(_G.EEPStructureGetAxis) then return nil end
    local ok, axisValue = _G.EEPStructureGetAxis(self.name, axisName)
    if not ok then return nil end
    self:replaceAxis(axisName, axisValue)
    return self:peekAxis(axisName)
end

function Structure:peekAxisByNumber(axisNumber)
    return self:peekAxis(tostring(axisNumber))
end

function Structure:getAxisByNumber(axisNumber)
    if self:peekAxisByNumber(axisNumber) == nil then return self:pullAxisByNumber(axisNumber) end
    return self:peekAxisByNumber(axisNumber)
end

function Structure:setAxisByNumber(axisNumber, axisValue)
    local number = tonumber(axisNumber)
    local value = tonumber(axisValue)
    if not number or not value then return false end
    if self:peekAxisByNumber(number) == value then return true end

    local ok = true
    if _G.EEPStructureSetAxisByNumber then ok = _G.EEPStructureSetAxisByNumber(self.name, number, value) ~= false end
    if ok then self:replaceAxis(tostring(number), value) end
    return ok
end

function Structure:pullAxisByNumber(axisNumber)
    local number = tonumber(axisNumber)
    if not number or not DataClass.isCallable(_G.EEPStructureGetAxisByNumber) then return nil end
    local ok, axisValue = _G.EEPStructureGetAxisByNumber(self.name, number)
    if not ok then return nil end
    self:replaceAxis(tostring(number), axisValue)
    return self:peekAxisByNumber(number)
end

function Structure:peekTextureText(surfaceNumber)
    return self.textureTexts and self.textureTexts[tostring(surfaceNumber)] or nil
end

function Structure:replaceTextureTexts(textureTexts)
    local nextTextureTexts = {}
    for surfaceNumber, textureText in pairs(textureTexts or {}) do
        nextTextureTexts[tostring(surfaceNumber)] = textureText or ""
    end
    local oldTextureTexts = self.textureTexts or {}
    self.textureTexts = nextTextureTexts
    DataClass.markLoaded(self, "textureTexts")
    if not TableUtils.sameDictEntries(oldTextureTexts, nextTextureTexts) then
        DataClass.markDirty(self, "textureTexts")
    end
end

function Structure:seedTextureTexts(textureTexts)
    self:replaceTextureTexts(textureTexts)
end

function Structure:pullTextureText(surfaceNumber)
    local surface = tonumber(surfaceNumber)
    if not surface or not DataClass.isCallable(_G.EEPStructureGetTextureText) then return nil end
    local ok, textureText = _G.EEPStructureGetTextureText(self.name, surface)
    if not ok then return nil end

    self.textureTexts = self.textureTexts or {}
    self.textureTexts[tostring(surface)] = textureText or ""
    DataClass.markLoaded(self, "textureTexts")
    return self.textureTexts[tostring(surface)]
end

function Structure:getTextureText(surfaceNumber)
    local surface = tonumber(surfaceNumber)
    if not surface then return nil end
    local value = self:peekTextureText(surface)
    if value ~= nil then return value end
    return self:pullTextureText(surface)
end

function Structure:setTextureText(surfaceNumber, text)
    local surface = tonumber(surfaceNumber)
    if not surface then return false end
    local value = text or ""
    local cachedValue = self:peekTextureText(surface)
    if cachedValue == value then return true end

    local ok = true
    if _G.EEPStructureSetTextureText then ok = _G.EEPStructureSetTextureText(self.name, surface, value) ~= false end
    if ok then
        self.textureTexts = self.textureTexts or {}
        self.textureTexts[tostring(surface)] = value
        DataClass.markLoaded(self, "textureTexts")
        DataClass.markDirty(self, "textureTexts")
    end
    return ok
end

function Structure:resetTextureTexts()
    self.textureTexts = {}
    if self.loadedFields then self.loadedFields.textureTexts = nil end
end

function Structure:replaceLight(light)
    DataClass.replaceField(self, "light", light == true)
end

function Structure:seedLight(light)
    self:replaceLight(light)
end

function Structure:setLight(light)
    local value = light == true
    if self.light == value then return true end
    local ok = true
    if _G.EEPStructureSetLight then ok = _G.EEPStructureSetLight(self.name, value) ~= false end
    if ok then self:replaceLight(value) end
    return ok
end

function Structure:pullLight(getter)
    getter = getter or _G.EEPStructureGetLight
    if not DataClass.isCallable(getter) then return nil end
    local ok, light = getter(self.name)
    if not ok then return nil end
    self:replaceLight(light == true)
    return self.light
end

function Structure:replaceSmoke(smoke)
    DataClass.replaceField(self, "smoke", smoke == true)
end

function Structure:seedSmoke(smoke)
    self:replaceSmoke(smoke)
end

function Structure:setSmoke(smoke)
    local value = smoke == true
    if self.smoke == value then return true end
    local ok = true
    if _G.EEPStructureSetSmoke then ok = _G.EEPStructureSetSmoke(self.name, value) ~= false end
    if ok then self:replaceSmoke(value) end
    return ok
end

function Structure:pullSmoke(getter)
    getter = getter or _G.EEPStructureGetSmoke
    if not DataClass.isCallable(getter) then return nil end
    local ok, smoke = getter(self.name)
    if not ok then return nil end
    self:replaceSmoke(smoke == true)
    return self.smoke
end

function Structure:replaceFire(fire)
    DataClass.replaceField(self, "fire", fire == true)
end

function Structure:seedFire(fire)
    self:replaceFire(fire)
end

function Structure:setFire(fire)
    local value = fire == true
    if self.fire == value then return true end
    local ok = true
    if _G.EEPStructureSetFire then ok = _G.EEPStructureSetFire(self.name, value) ~= false end
    if ok then self:replaceFire(value) end
    return ok
end

function Structure:pullFire(getter)
    getter = getter or _G.EEPStructureGetFire
    if not DataClass.isCallable(getter) then return nil end
    local ok, fire = getter(self.name)
    if not ok then return nil end
    self:replaceFire(fire == true)
    return self.fire
end

function Structure:replaceGsbname(name)
    DataClass.replaceField(self, "gsbname", name)
end

function Structure:seedGsbname(name)
    self:replaceGsbname(name)
end

function Structure:peekTippText() return self.tippText end

function Structure:getTippText() return self.tippText end

function Structure:peekTippTextVisible() return self.tippTextVisible end

function Structure:getTippTextVisible() return self.tippTextVisible end

function Structure:replaceTippText(text)
    DataClass.replaceField(self, "tippText", text or "")
end

function Structure:seedTippText(text)
    self:replaceTippText(text)
end

function Structure:replaceTippTextVisible(visible)
    DataClass.replaceField(self, "tippTextVisible", visible == true)
end

function Structure:seedTippTextVisible(visible)
    self:replaceTippTextVisible(visible)
end

function Structure:setTippText(text)
    return self:changeInfo(text)
end

function Structure:showTippText(visible)
    return self:showInfo(visible)
end

function Structure:changeInfo(text)
    local value = text or ""
    if DataClass.isLoaded(self, "tippText") and self.tippText == value then return true end

    local ok = true
    if _G.EEPChangeInfoStructure then ok = _G.EEPChangeInfoStructure(self.name, value) ~= false end
    if ok then
        self.tippText = value
        DataClass.markLoaded(self, "tippText")
    end
    return ok
end

function Structure:showInfo(visible)
    local value = visible == true
    if DataClass.isLoaded(self, "tippTextVisible") and self.tippTextVisible == value then return true end

    local ok = true
    if _G.EEPShowInfoStructure then ok = _G.EEPShowInfoStructure(self.name, value) ~= false end
    if ok then
        self.tippTextVisible = value
        DataClass.markLoaded(self, "tippTextVisible")
    end
    return ok
end

function Structure:resetDirty()
    DataClass.resetDirty(self)
end

function Structure:hasDirtyFields()
    return DataClass.hasDirtyFields(self)
end

function Structure.setPositionByName(structureName, posX, posY, posZ)
    local x = toNumber(posX)
    local y = toNumber(posY)
    local z = toNumber(posZ)
    if not structureName or not x or not y or not z then return false end

    local structure = registryStructure(structureName)
    if structure and structure:peekPosX() == x and structure:peekPosY() == y and structure:peekPosZ() == z then
        return true
    end

    local ok = true
    if _G.EEPStructureSetPosition then ok = _G.EEPStructureSetPosition(structureName, x, y, z) ~= false end
    if ok and structure then structure:replacePosition(x, y, z) end
    return ok
end

function Structure.setRotationByName(structureName, rotX, rotY, rotZ)
    local x = toNumber(rotX)
    local y = toNumber(rotY)
    local z = toNumber(rotZ)
    if not structureName or not x or not y or not z then return false end

    local structure = registryStructure(structureName)
    if structure and structure:peekRotX() == x and structure:peekRotY() == y and structure:peekRotZ() == z then
        return true
    end

    local ok = true
    if _G.EEPStructureSetRotation then ok = _G.EEPStructureSetRotation(structureName, x, y, z) ~= false end
    if ok and structure then structure:replaceRotation(x, y, z) end
    return ok
end

function Structure.setLightByName(structureName, light)
    if not structureName then return false end
    local value = light == true

    local structure = registryStructure(structureName)
    if structure and structure:peekLight() == value then return true end

    local ok = true
    if _G.EEPStructureSetLight then ok = _G.EEPStructureSetLight(structureName, value) ~= false end
    if ok and structure then structure:replaceLight(value) end
    return ok
end

function Structure.setTagByName(structureName, tagText)
    if not structureName then return false end
    local value = tagText or ""

    local structure = registryStructure(structureName)
    if structure and structure:peekTag() == value then return true end

    local ok = true
    if _G.EEPStructureSetTagText then ok = _G.EEPStructureSetTagText(structureName, value) ~= false end
    if ok and structure then structure:replaceTag(value) end
    return ok
end

function Structure.setTippTextByName(structureName, text)
    if not structureName then return end
    local structure = registryStructure(structureName)
    if structure then
        structure:changeInfo(text)
    elseif _G.EEPChangeInfoStructure then
        _G.EEPChangeInfoStructure(structureName, text or "")
    end
end

function Structure.showTippTextByName(structureName, visible)
    if not structureName then return end
    local structure = registryStructure(structureName)
    if structure then
        structure:showInfo(visible)
    elseif _G.EEPShowInfoStructure then
        _G.EEPShowInfoStructure(structureName, visible == true)
    end
end

return Structure
