if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local InterestSyncRegistry = require("ce.hub.data.InterestSyncRegistry")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStockDtoFactory = require("ce.hub.data.rollingstock.RollingStockDtoFactory")
local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local RollingStockPublisher = {}

local function hasPayloadFields(dto)
    for key in pairs(dto or {}) do
        if key ~= "ceType" and key ~= "id" then return true end
    end
    return false
end

function RollingStockPublisher.syncState()
    local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

    if not HubOptionsRegistry.isPublishEnabled("rollingStocks") then
        RollingStockRegistry.clearPendingChanges()
        return {}
    end

    for stockId in pairs(RollingStockRegistry.getRemovedIds()) do
        DataChangeBus.fireDataRemoved(RollingStockDtoFactory.createRefDto(stockId))
    end

    for _, rs in pairs(RollingStockRegistry.getAll()) do
        local isSelected = InterestSyncRegistry.isSelected(HubCeTypes.RollingStock, rs.id)
        local needsInitialSend = InterestSyncRegistry.needsInitialSend(HubCeTypes.RollingStock, rs.id)

        if rs.needsFullSend or needsInitialSend then
            DataChangeBus.fireDataChanged(RollingStockDtoFactory.createFullDto(rs, isSelected))
            rs.needsFullSend = false
            rs:resetDirty()
            if isSelected then InterestSyncRegistry.markSent(HubCeTypes.RollingStock, rs.id) end
        elseif rs:hasDirtyFields() then
            local ceType, keyId, key, dto = RollingStockDtoFactory.createPatchDto(rs, rs.dirtyFields, isSelected)
            if hasPayloadFields(dto) then
                DataChangeBus.fireDataChanged(ceType, keyId, key, dto)
            end
            rs:resetDirty()
        end
    end

    RollingStockRegistry.clearPendingChanges()
    return {}
end

return RollingStockPublisher
