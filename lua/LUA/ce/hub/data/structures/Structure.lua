if CeDebugLoad then print("[#Start] Loading ce.hub.data.structures.Structure ...") end

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
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
local Structure = {}

local function markDirty(structure, fieldName)
    structure.dirtyFields[fieldName] = true
end

function Structure:getPosX() return self.pos_x end

function Structure:getPosY() return self.pos_y end

function Structure:getPosZ() return self.pos_z end

function Structure:getRotX() return self.rot_x end

function Structure:getRotY() return self.rot_y end

function Structure:getRotZ() return self.rot_z end

function Structure:getModelType() return self.modelType end

function Structure:getModelTypeText() return self.modelTypeText end

function Structure:getTag() return self.tag end

function Structure:getLight() return self.light end

function Structure:getSmoke() return self.smoke end

function Structure:getFire() return self.fire end

---@param name string
---@return Structure
function Structure:new(name)
    local o = {
        id = name,
        name = name,
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
        tag = "",
        dirtyFields = {},
        needsFullSend = true
    }
    self.__index = self
    setmetatable(o, self)

    return o
end

function Structure:setPosition(posX, posY, posZ)
    if self.pos_x ~= posX then
        self.pos_x = posX
        markDirty(self, "pos_x")
    end
    if self.pos_y ~= posY then
        self.pos_y = posY
        markDirty(self, "pos_y")
    end
    if self.pos_z ~= posZ then
        self.pos_z = posZ
        markDirty(self, "pos_z")
    end
end

function Structure:setRotation(rotX, rotY, rotZ)
    if self.rot_x ~= rotX then
        self.rot_x = rotX
        markDirty(self, "rot_x")
    end
    if self.rot_y ~= rotY then
        self.rot_y = rotY
        markDirty(self, "rot_y")
    end
    if self.rot_z ~= rotZ then
        self.rot_z = rotZ
        markDirty(self, "rot_z")
    end
end

function Structure:setModelType(modelType, modelTypeText)
    if self.modelType ~= modelType then
        self.modelType = modelType
        markDirty(self, "modelType")
    end
    if self.modelTypeText ~= modelTypeText then
        self.modelTypeText = modelTypeText
        markDirty(self, "modelTypeText")
    end
end

function Structure:setTag(tag)
    local value = tag or ""
    if self.tag ~= value then
        self.tag = value
        markDirty(self, "tag")
    end
end

function Structure:setLight(light)
    local value = light == true
    if self.light ~= value then
        self.light = value
        markDirty(self, "light")
    end
end

function Structure:setSmoke(smoke)
    local value = smoke == true
    if self.smoke ~= value then
        self.smoke = value
        markDirty(self, "smoke")
    end
end

function Structure:setFire(fire)
    local value = fire == true
    if self.fire ~= value then
        self.fire = value
        markDirty(self, "fire")
    end
end

function Structure:resetDirty()
    self.dirtyFields = {}
end

function Structure:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return Structure
