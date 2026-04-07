---@meta

---@class Track
---@field id number
---@field reserved boolean
---@field reservedByTrainName string|nil

---@class TrackRegistry
---@field add fun(trackType: string, track: Track):nil
---@field get fun(trackType: string, trackId: string|number):Track|nil
---@field getAll fun(trackType: string):table<string, Track>
---@field markChanged fun(trackType: string, trackId: string|number):nil
---@field getChangedIds fun(trackType: string):table<string, boolean>
---@field clearChanged fun(trackType: string):nil
---@field markInitialListPending fun(trackType: string):nil
---@field isInitialListPending fun(trackType: string):boolean
---@field clearInitialListPending fun(trackType: string):nil

---@class TrackPublisher
---@field syncState fun(options: table|nil):table
