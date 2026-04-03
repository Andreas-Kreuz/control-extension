---@meta

---@class RollingStockTexturesDto
---@field id string
---@field surfaceTexts table<string, string>

---@class TexturesDtoFactory
---@field createDto fun(stock: RollingStock|table):string,string,string|number,RollingStockTexturesDto
---@field createDtoList fun(stocks: table):string,string,table
---@field createRefDto fun(stockId: string):string,string,string|number,RollingStockTexturesDto
