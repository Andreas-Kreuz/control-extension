local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local DynamicUpdateRegistry = require("ce.hub.data.dynamic.DynamicUpdateRegistry")
local RollingStock = require("ce.hub.data.rollingstock.RollingStock")
local RollingStockDtoFactory = require("ce.hub.data.rollingstock.RollingStockDtoFactory")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local RollingStockRegistry = {}
---@type table<string,RollingStock>
local allRollingStock = {}

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
    DataChangeBus.fireDataRemoved(RollingStockDtoFactory.createRefDto(rollingStockName))
end

function RollingStockRegistry.fireChangeRollingStockEvents(ceTypeOptionsByAlias)
    local rsOptions = ceTypeOptionsByAlias and ceTypeOptionsByAlias["rollingStock"] or nil
    local mode = SyncPolicy.getMode(rsOptions, true)

    for _, rs in pairs(allRollingStock) do
        local isSelected = DynamicUpdateRegistry.isSelected(HubCeTypes.RollingStock, rs.id)
        local needsInitialSend = DynamicUpdateRegistry.needsInitialSend(HubCeTypes.RollingStock, rs.id)
        local isSubscribed = mode == "all" or (mode == "selected" and isSelected)

        if rs.needsFullSend or needsInitialSend then
            DataChangeBus.fireDataChanged(RollingStockDtoFactory.createFullDto(rs, isSubscribed))
            rs.needsFullSend = false
            rs:resetDirty()
            if isSelected then DynamicUpdateRegistry.markSent(HubCeTypes.RollingStock, rs.id) end
        elseif rs:hasDirtyFields() then
            local shouldSend = mode == "all"
                or (mode == "selected" and isSelected)
            if shouldSend then
                DataChangeBus.fireDataChanged(RollingStockDtoFactory.createPatchDto(rs, rs.dirtyFields, isSubscribed))
            end
            rs:resetDirty()
        end
    end
end

return RollingStockRegistry
