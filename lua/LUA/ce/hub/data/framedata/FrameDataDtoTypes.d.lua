---@meta

-- Field policies: all fields always

---@class FrameDataDto
---@field id string                    -- Policy: always
---@field framesPerSecond number|nil   -- Policy: always
---@field currentFrame number|nil      -- Policy: always
---@field currentRenderFrame number|nil -- Policy: always

---@class FrameDataDtoFactory
---@field createFrameDataDtoList fun(entries: table):string,string,table
