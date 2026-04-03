---@meta

---@class TrainStaticDto
---@field id string
---@field name string
---@field route string
---@field rollingStockCount number
---@field length number
---@field line string|nil
---@field destination string|nil
---@field direction string|nil
---@field trackType string|nil
---@field movesForward boolean

---@class TrainStaticDtoFactory
---@field createDto fun(train: Train|table):string,string,string|number,TrainStaticDto
---@field createDtoList fun(trains: table):string,string,table
---@field createRefDto fun(trainId: string):string,string,string|number,TrainStaticDto
