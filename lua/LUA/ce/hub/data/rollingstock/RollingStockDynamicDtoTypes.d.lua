---@meta

-- Field policies: always | ondemand | never

---@class RollingStockDynamicDto
---@field id string              -- Policy: always
---@field trackId number         -- Policy: ondemand
---@field trackDistance number   -- Policy: ondemand
---@field trackDirection number  -- Policy: ondemand
---@field trackSystem number     -- Policy: ondemand
---@field posX number            -- Policy: ondemand
---@field posY number            -- Policy: ondemand
---@field posZ number            -- Policy: ondemand
---@field mileage number         -- Policy: ondemand
---@field orientationForward boolean -- Policy: ondemand
---@field smoke number           -- Policy: ondemand
---@field active boolean         -- Policy: ondemand

---@class RollingStockDynamicDtoFactory
---@field createDto fun(stock: RollingStock|table):string,string,string|number,RollingStockDynamicDto
---@field createRefDto fun(stockId: string):string,string,string|number,RollingStockDynamicDto
