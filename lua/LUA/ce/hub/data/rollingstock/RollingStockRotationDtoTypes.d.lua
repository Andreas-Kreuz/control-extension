---@meta

---@class RollingStockRotationDto
---@field id string
---@field rotX number
---@field rotY number
---@field rotZ number

---@class RotationDtoFactory
---@field createDto fun(stock: RollingStock|table):string,string,string|number,RollingStockRotationDto
---@field createDtoList fun(stocks: table):string,string,table
---@field createRefDto fun(stockId: string):string,string,string|number,RollingStockRotationDto
