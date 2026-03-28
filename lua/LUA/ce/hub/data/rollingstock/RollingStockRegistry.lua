local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStock = require("ce.hub.data.rollingstock.RollingStock")
local RollingStockDtoFactory = require("ce.hub.data.rollingstock.RollingStockDtoFactory")
local RollingStockTexturesDtoFactory = require("ce.hub.data.rollingstock.RollingStockTexturesDtoFactory")
local RollingStockRotationDtoFactory = require("ce.hub.data.rollingstock.RollingStockRotationDtoFactory")
local RollingStockRegistry = {}
---@type table<string,RollingStock>
local allRollingStock = {}

local function isSelected(selectedCeTypes, ceType)
    if not selectedCeTypes or next(selectedCeTypes) == nil then return true end
    return selectedCeTypes[ceType] == true
end

---Creates a train object for the given train name, the train must exist
---@param rollingStockName string name of the train in EEP, e.g. "#Train 1"
---@return RollingStock
function RollingStockRegistry.forName(rollingStockName)
    assert(rollingStockName, "Provide a rollingStockName")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    if allRollingStock[rollingStockName] then
        ---@type RollingStock
        local rs = allRollingStock[rollingStockName]
        return rs
    else
        ---@diagnostic disable-next-line: missing-fields
        local o = RollingStock:new({ rollingStockName = rollingStockName })
        allRollingStock[o.rollingStockName] = o
        RollingStockRegistry.rollingStockAppeared(o)
        return o
    end
end

---A train appeared on the map
function RollingStockRegistry.rollingStockAppeared(_)
    -- is included in "TrainRegistry.fireChangeTrainsEvent()"
    -- DataChangeBus.fireDataChanged("rolling-stocks", "id", rollingStock:toJsonStatic())
end

---A train dissappeared from the map
---@param rollingStockName string
function RollingStockRegistry.rollingStockDisappeared(rollingStockName)
    allRollingStock[rollingStockName] = nil
    DataChangeBus.fireDataRemoved(RollingStockDtoFactory.createRollingStockReferenceDto(rollingStockName))
    DataChangeBus.fireDataRemoved(
        RollingStockTexturesDtoFactory.createRollingStockTexturesReferenceDto(rollingStockName))
    DataChangeBus.fireDataRemoved(
        RollingStockRotationDtoFactory.createRollingStockRotationReferenceDto(rollingStockName))
end

function RollingStockRegistry.fireChangeRollingStockEvent(selectedCeTypes)
    local modifiedRollingStock = {}
    local modifiedRollingStockTextures = {}
    local modifiedRollingStockRotation = {}
    for _, rs in pairs(allRollingStock) do
        if isSelected(selectedCeTypes, HubCeTypes.RollingStock) and rs.valuesUpdated then
            modifiedRollingStock[rs.id] = rs
            rs.valuesUpdated = false
        end
        if isSelected(selectedCeTypes, HubCeTypes.RollingStockTextures) and rs.textureTextsUpdated then
            modifiedRollingStockTextures[rs.id] = rs
            rs.textureTextsUpdated = false
        end
        if isSelected(selectedCeTypes, HubCeTypes.RollingStockRotation) and rs.rotationUpdated then
            modifiedRollingStockRotation[rs.id] = rs
            rs.rotationUpdated = false
        end
    end
    if next(modifiedRollingStock) ~= nil then
        for _, rollingStock in pairs(modifiedRollingStock) do
            DataChangeBus.fireDataChanged(RollingStockDtoFactory.createRollingStockDto(rollingStock))
        end
    end
    for _, rollingStock in pairs(modifiedRollingStockTextures) do
        DataChangeBus.fireDataChanged(RollingStockTexturesDtoFactory.createRollingStockTexturesDto(rollingStock))
    end
    for _, rollingStock in pairs(modifiedRollingStockRotation) do
        DataChangeBus.fireDataChanged(RollingStockRotationDtoFactory.createRollingStockRotationDto(rollingStock))
    end
end

return RollingStockRegistry
