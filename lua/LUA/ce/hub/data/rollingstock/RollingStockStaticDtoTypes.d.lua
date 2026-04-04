---@meta

-- Field policies: always | ondemand | never

---@class RollingStockStaticDto
---@field id string           -- Policy: always
---@field name string         -- Policy: always
---@field trainName string    -- Policy: always
---@field positionInTrain number -- Policy: always
---@field couplingFront number -- Policy: always
---@field couplingRear number  -- Policy: always
---@field length number        -- Policy: always
---@field propelled boolean    -- Policy: always
---@field modelType number     -- Policy: always
---@field modelTypeText string -- Policy: always
---@field tag string           -- Policy: always
---@field nr string|nil        -- Policy: always
---@field trackType string|nil -- Policy: always
---@field hookStatus number    -- Policy: always
---@field hookGlueMode number  -- Policy: always

---@class RollingStockStaticDtoFactory
---@field createDto fun(stock: RollingStock|table):string,string,string|number,RollingStockStaticDto
---@field createRefDto fun(stockId: string):string,string,string|number,RollingStockStaticDto
