---@meta

---@class SignalDto
---@field ceType string
---@field id number
---@field position number
---@field tag string
---@field waitingVehiclesCount number
---@field stopDistance number|nil
---@field itemName string|nil
---@field itemNameWithModelPath string|nil
---@field signalFunctions string[]|nil
---@field activeFunction string|nil

---@class WaitingOnSignalDto
---@field ceType string
---@field id string
---@field signalId number
---@field waitingPosition number
---@field vehicleName string
---@field waitingCount number

---@class SignalDtoFactory
---@field createSignalDto fun(signal: table):string,string,string|number,SignalDto
---@field createSignalDtoList fun(signals: table):string,string,table
---@field createWaitingOnSignalDto fun(waiting: table):string,string,string|number,WaitingOnSignalDto
---@field createWaitingOnSignalDtoList fun(waitingOnSignals: table):string,string,table
