if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockModelRegistry ...") end

local RollingStockModelRegistry = {}
local assignedModels = {}
local nameModels = {}
local xmlModels = {}

---Assigns a certain model for the given model name and XML model path.
---@param modelName string name of the rollingstock as in EEP before the ";"
---@param xmlModel string XML model path as stored in the anl3 file
---@param model RollingStockModel model implementation for the rollingstock
function RollingStockModelRegistry.addModel(modelName, xmlModel, model)
    assert(type(modelName) == "string", "Need 'modelName' as string")
    assert(type(xmlModel) == "string", "Need 'xmlModel' as string")
    assert(type(model) == "table", "Need 'model' as table")
    nameModels[modelName] = model
    xmlModels[xmlModel] = model
end

---Assigns a certain model for the given rollingstock name (complete Name in EEP)
---@param rollingStockName string name of the rollingstock including the ";" if used in EEP
---@param model RollingStockModel model implementation for the rollingstock
function RollingStockModelRegistry.assignModel(rollingStockName, model)
    assignedModels[rollingStockName] = model
end

---Returns the model for the given rollingstock.
---@param rollingStockName string name of the rollingstock
---@param xmlModel string|nil XML model path as stored in the anl3 file
---@return RollingStockModel
function RollingStockModelRegistry.modelFor(rollingStockName, xmlModel)
    if assignedModels[rollingStockName] then return assignedModels[rollingStockName] end
    if xmlModel and xmlModels[xmlModel] then return xmlModels[xmlModel] end

    local modelName = RollingStockModelRegistry.parseModelName(rollingStockName)
    if nameModels[modelName] then return nameModels[modelName] end

    local RollingStockModel = require("ce.hub.data.rollingstock.RollingStockModel")
    return RollingStockModel:new({})
end

---Parse the name of the model by cutting all characters after the first ";"
---@param rollingStockName string name of the rollingstock
function RollingStockModelRegistry.parseModelName(rollingStockName)
    return rollingStockName:match("[^;]*")
end

return RollingStockModelRegistry
