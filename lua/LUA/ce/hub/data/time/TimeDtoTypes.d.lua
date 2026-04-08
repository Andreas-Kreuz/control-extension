---@meta

-- Field policies: all fields always

---@class TimeDto
---@field id string      -- Policy: always
---@field name string    -- Policy: always
---@field timeComplete number   -- Policy: always
---@field timeH number   -- Policy: always
---@field timeM number   -- Policy: always
---@field timeS number   -- Policy: always

---@class TimeDtoFactory
---@field createTimeDto fun(timeData: table):string,string,string|number,TimeDto
---@field createTimeDtoList fun(times: table):string,string,table
