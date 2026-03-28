---@meta

---@class RollingStockTexturesDto
---@field id string
---@field surfaceTexts table<string, string>

---@class RollingStockTexturesDtoFactory
---@field createRollingStockTexturesDto fun(rollingStock: RollingStock|table):string,string,string|number,RollingStockTexturesDto
---@field createRollingStockTexturesDtoList fun(rollingStocks: table):string,string,table
---@field createRollingStockTexturesReferenceDto fun(rollingStockId: string):string,string,string|number,RollingStockTexturesDto
