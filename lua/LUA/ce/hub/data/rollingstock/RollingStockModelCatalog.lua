if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.RollingStockModelCatalog ...") end

local RollingStockModelRegistry = require("ce.hub.data.rollingstock.RollingStockModelRegistry")

require("ce.hub.data.rollingstock.ModelV15NMA10013").register(RollingStockModelRegistry)
require("ce.hub.data.rollingstock.MODELV15NJS20220").register(RollingStockModelRegistry)

return RollingStockModelRegistry
