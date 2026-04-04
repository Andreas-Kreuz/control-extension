local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local DynamicUpdateRegistry = require("ce.hub.data.dynamic.DynamicUpdateRegistry")
local RollingStock = require("ce.hub.data.rollingstock.RollingStock")
local RollingStockStaticDtoFactory = require("ce.hub.data.rollingstock.RollingStockStaticDtoFactory")
local RollingStockDynamicDtoFactory = require("ce.hub.data.rollingstock.RollingStockDynamicDtoFactory")
local TexturesDtoFactory = require("ce.hub.data.rollingstock.RollingStockTexturesDtoFactory")
local RotationDtoFactory = require("ce.hub.data.rollingstock.RollingStockRotationDtoFactory")
local RollingStockRegistry = {}
---@type table<string,RollingStock>
local allRollingStock = {}

local function isSelected(selectedCeTypes, ceType)
    if not selectedCeTypes or next(selectedCeTypes) == nil then return true end
    return selectedCeTypes[ceType] == true
end

function RollingStockRegistry.forName(rollingStockName)
    assert(rollingStockName, "Provide a rollingStockName")
    assert(type(rollingStockName) == "string", "Need 'rollingStockName' as string")
    if allRollingStock[rollingStockName] then
        local rs = allRollingStock[rollingStockName]
        return rs
    else
        local o = RollingStock:new({ rollingStockName = rollingStockName })
        allRollingStock[o.rollingStockName] = o
        RollingStockRegistry.rollingStockAppeared(o)
        return o
    end
end

function RollingStockRegistry.rollingStockAppeared(_)
end

function RollingStockRegistry.rollingStockDisappeared(rollingStockName)
    allRollingStock[rollingStockName] = nil
    DataChangeBus.fireDataRemoved(RollingStockStaticDtoFactory.createRefDto(rollingStockName))
    DataChangeBus.fireDataRemoved(RollingStockDynamicDtoFactory.createRefDto(rollingStockName))
    DataChangeBus.fireDataRemoved(TexturesDtoFactory.createRefDto(rollingStockName))
    DataChangeBus.fireDataRemoved(RotationDtoFactory.createRefDto(rollingStockName))
end

function RollingStockRegistry.fireChangeRollingStockEvents(selectedCeTypes)
    local modifiedStaticStocks = {}
    local modifiedDynamicStocks = {}
    local modifiedTextures = {}
    local modifiedRotations = {}
    for _, rs in pairs(allRollingStock) do
        if isSelected(selectedCeTypes, HubCeTypes.RollingStockStatic) and rs.staticValuesUpdated then
            modifiedStaticStocks[rs.id] = rs
            rs.staticValuesUpdated = false
        end
        if isSelected(selectedCeTypes, HubCeTypes.RollingStockDynamic)
                and DynamicUpdateRegistry.isSelected(HubCeTypes.RollingStockDynamic, rs.id)
                and (
                    rs.dynamicValuesUpdated
                    or DynamicUpdateRegistry.needsInitialSend(HubCeTypes.RollingStockDynamic, rs.id)
                ) then
            modifiedDynamicStocks[rs.id] = rs
            rs.dynamicValuesUpdated = false
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
    for _, stock in pairs(modifiedStaticStocks) do
        DataChangeBus.fireDataChanged(RollingStockStaticDtoFactory.createDto(stock))
    end
    for _, stock in pairs(modifiedDynamicStocks) do
        local isSubscribed = DynamicUpdateRegistry.isSelected(HubCeTypes.RollingStockDynamic, stock.id)
        DataChangeBus.fireDataChanged(RollingStockDynamicDtoFactory.createDto(stock, isSubscribed))
        if isSubscribed then DynamicUpdateRegistry.markSent(HubCeTypes.RollingStockDynamic, stock.id) end
    end
    for _, stock in pairs(modifiedTextures) do
        DataChangeBus.fireDataChanged(TexturesDtoFactory.createDto(stock))
    end
    for _, stock in pairs(modifiedRotations) do
        DataChangeBus.fireDataChanged(RotationDtoFactory.createDto(stock))
    end
end

return RollingStockRegistry
