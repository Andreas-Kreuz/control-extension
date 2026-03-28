---@meta

---@class RollingStockRotationDto
---@field id string
---@field rotX number
---@field rotY number
---@field rotZ number

---@class RollingStockRotationDtoFactory
---@field createRollingStockRotationDto fun(rollingStock: RollingStock|table):string,string,string|number,RollingStockRotationDto
---@field createRollingStockRotationDtoList fun(rollingStocks: table):string,string,table
---@field createRollingStockRotationReferenceDto fun(rollingStockId: string):string,string,string|number,RollingStockRotationDto
