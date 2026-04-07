if CeDebugLoad then print("[#Start] Loading ce.hub.data.rollingstock.TagKeys ...") end

-- TODO: Architecture and implementation plan for RollingStock tag ownership: see TODO.md in this directory.
---@class TagKeys
local TagKeys = {}

TagKeys.Train = { destination = "d", direction = "a", line = "l", route = "r", trainNumber = "n" }
TagKeys.RollingStock = { wagonNumber = "w", tag = "t", model = "m", to = "o", from = "f" }

return TagKeys
