---@meta

-- Field policies: always | ondemand | never

---@class TrainStaticDto
---@field id string           -- Policy: always
---@field name string         -- Policy: always
---@field route string        -- Policy: always
---@field rollingStockCount number -- Policy: always
---@field length number       -- Policy: always
---@field line string|nil     -- Policy: always
---@field destination string|nil -- Policy: always
---@field direction string|nil   -- Policy: always
---@field trackType string|nil   -- Policy: always
---@field movesForward boolean   -- Policy: always

---@class TrainStaticDtoFactory
---@field createDto fun(train: Train|table):string,string,string|number,TrainStaticDto
---@field createDtoList fun(trains: table):string,string,table
---@field createRefDto fun(trainId: string):string,string,string|number,TrainStaticDto
