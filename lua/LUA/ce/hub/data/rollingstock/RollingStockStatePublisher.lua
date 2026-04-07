if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockStatePublisher ...") end
local RollingStockPublisher = require("ce.hub.data.rollingstock.RollingStockPublisher")

local RollingStockStatePublisher = {}
RollingStockStatePublisher.enabled = true
local initialized = false
RollingStockStatePublisher.name = "ce.hub.data.rollingstock.RollingStockStatePublisher"

function RollingStockStatePublisher.initialize()
    if not RollingStockStatePublisher.enabled or initialized then return end
    initialized = true
end

function RollingStockStatePublisher.syncState()
    if not RollingStockStatePublisher.enabled then return end
    if not initialized then RollingStockStatePublisher.initialize() end

    return RollingStockPublisher.syncState()
end

return RollingStockStatePublisher
