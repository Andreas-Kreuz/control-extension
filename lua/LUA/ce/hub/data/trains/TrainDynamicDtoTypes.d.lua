---@meta

-- Field policies: always | ondemand | never

---@class TrainDynamicDto
---@field id string           -- Policy: always
---@field speed number        -- Policy: ondemand
---@field targetSpeed number  -- Policy: ondemand
---@field couplingFront number -- Policy: ondemand
---@field couplingRear number  -- Policy: ondemand
---@field active boolean      -- Policy: ondemand
---@field trainyardId number|nil -- Policy: ondemand
---@field inTrainyard boolean -- Policy: ondemand

---@class TrainDynamicDtoFactory
---@field createDto fun(train: Train|table):string,string,string|number,TrainDynamicDto
---@field createRefDto fun(trainId: string):string,string,string|number,TrainDynamicDto
