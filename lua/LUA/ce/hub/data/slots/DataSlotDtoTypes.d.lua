---@meta

-- Field policies: all fields always

---@class DataSlotDto
---@field id number        -- Policy: always
---@field name string|nil  -- Policy: always
---@field data string|nil  -- Policy: always

---@class DataSlotDtoFactory
---@field createFilledDataSlotDto fun(slot: table):string,string,string|number,DataSlotDto
---@field createFilledDataSlotDtoList fun(filledSlots: table):string,string,table
---@field createEmptyDataSlotDto fun(slot: table):string,string,string|number,DataSlotDto
---@field createEmptyDataSlotDtoList fun(emptySlots: table):string,string,table
