---@meta

---@class RollingStockDynamicDto
---@field id string
---@field trackId number
---@field trackDistance number
---@field trackDirection number
---@field trackSystem number
---@field posX number
---@field posY number
---@field posZ number
---@field mileage number
---@field orientationForward boolean
---@field smoke number
---@field active boolean

---@class RollingStockDynamicDtoFactory
---@field createDto fun(stock: RollingStock|table):string,string,string|number,RollingStockDynamicDto
---@field createRefDto fun(stockId: string):string,string,string|number,RollingStockDynamicDto
