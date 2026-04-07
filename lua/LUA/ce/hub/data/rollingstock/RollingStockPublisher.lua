if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockPublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local DynamicUpdateRegistry = require("ce.hub.data.DynamicUpdateRegistry")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local RollingStockDtoFactory = require("ce.hub.data.rollingstock.RollingStockDtoFactory")
local RollingStockRegistry = require("ce.hub.data.rollingstock.RollingStockRegistry")
local SyncPolicy = require("ce.hub.sync.SyncPolicy")

local RollingStockPublisher = {}

function RollingStockPublisher.syncState(options)
    local opts = options or {}
    local rsOptions = opts.ceTypes and opts.ceTypes.rollingStock or nil
    local mode = SyncPolicy.getMode(rsOptions, true)
    local fieldOptions = opts.fields or {}

    for stockId in pairs(RollingStockRegistry.getRemovedIds()) do
        DataChangeBus.fireDataRemoved(RollingStockDtoFactory.createRefDto(stockId))
    end

    for _, rs in pairs(RollingStockRegistry.getAll()) do
        local isSelected = DynamicUpdateRegistry.isSelected(HubCeTypes.RollingStock, rs.id)
        local needsInitialSend = DynamicUpdateRegistry.needsInitialSend(HubCeTypes.RollingStock, rs.id)
        local isSubscribed = mode == "all" or (mode == "selected" and isSelected)

        if rs.needsFullSend or needsInitialSend then
            DataChangeBus.fireDataChanged(RollingStockDtoFactory.createFullDto(rs, isSubscribed, fieldOptions))
            rs.needsFullSend = false
            rs:resetDirty()
            if isSelected then DynamicUpdateRegistry.markSent(HubCeTypes.RollingStock, rs.id) end
        elseif rs:hasDirtyFields() then
            if mode == "all" or (mode == "selected" and isSelected) then
                DataChangeBus.fireDataChanged(RollingStockDtoFactory.createPatchDto(rs, rs.dirtyFields, isSubscribed,
                                                                                    fieldOptions))
            end
            rs:resetDirty()
        end
    end

    RollingStockRegistry.clearPendingChanges()
    return {}
end

return RollingStockPublisher
