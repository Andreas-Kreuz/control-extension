---@meta

---@class TrainDynamicDto
---@field id string
---@field speed number
---@field targetSpeed number
---@field couplingFront number
---@field couplingRear number
---@field active boolean
---@field trainyardId number|nil
---@field inTrainyard boolean

---@class TrainDynamicDtoFactory
---@field createDto fun(train: Train|table):string,string,string|number,TrainDynamicDto
---@field createRefDto fun(trainId: string):string,string,string|number,TrainDynamicDto
