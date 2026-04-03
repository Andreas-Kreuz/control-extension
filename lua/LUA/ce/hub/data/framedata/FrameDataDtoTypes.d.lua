---@meta

---@class FrameDataDto
---@field id string
---@field framesPerSecond number|nil
---@field currentFrame number|nil
---@field currentRenderFrame number|nil

---@class FrameDataDtoFactory
---@field createFrameDataDtoList fun(entries: table):string,string,table
