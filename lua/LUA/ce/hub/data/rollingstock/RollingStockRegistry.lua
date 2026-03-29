local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStock = require("ce.hub.data.rollingstock.RollingStock")
local StockDtoFactory = require("ce.hub.data.rollingstock.RollingStockDtoFactory")
local TexturesDtoFactory = require("ce.hub.data.rollingstock.RollingStockTexturesDtoFactory")
local RotationDtoFactory = require("ce.hub.data.rollingstock.RollingStockRotationDtoFactory")
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
    DataChangeBus.fireDataRemoved(StockDtoFactory.createRefDto(rollingStockName))
    DataChangeBus.fireDataRemoved(
        TexturesDtoFactory.createRefDto(rollingStockName))
    DataChangeBus.fireDataRemoved(
        RotationDtoFactory.createRefDto(rollingStockName))
end

function RollingStockRegistry.fireChangeRollingStockEvent(selectedCeTypes)
    local modifiedStocks = {}
    local modifiedTextures = {}
    local modifiedRotations = {}
    for _, rs in pairs(allRollingStock) do
        if isSelected(selectedCeTypes, HubCeTypes.RollingStock) and rs.valuesUpdated then
            modifiedStocks[rs.id] = rs
            rs.valuesUpdated = false
        end
        if isSelected(selectedCeTypes, HubCeTypes.RollingStockTextures) and rs.textureTextsUpdated then
            modifiedTextures[rs.id] = rs
            rs.textureTextsUpdated = false
        end
        if isSelected(selectedCeTypes, HubCeTypes.RollingStockRotation) and rs.rotationUpdated then
            modifiedRotations[rs.id] = rs
            rs.rotationUpdated = false
        end
    end
    if next(modifiedStocks) ~= nil then
        for _, stock in pairs(modifiedStocks) do
            DataChangeBus.fireDataChanged(StockDtoFactory.createDto(stock))
        end
    end
    for _, stock in pairs(modifiedTextures) do
        DataChangeBus.fireDataChanged(TexturesDtoFactory.createDto(stock))
    end
    for _, stock in pairs(modifiedRotations) do
        DataChangeBus.fireDataChanged(RotationDtoFactory.createDto(stock))
    end
end

return RollingStockRegistry
