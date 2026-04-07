if CeDebugLoad then print("[#Start] Loading ce.hub.data.time.TimePublisher ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local TimeDtoFactory = require("ce.hub.data.time.TimeDtoFactory")
local TimeRegistry = require("ce.hub.data.time.TimeRegistry")

local TimePublisher = {}

function TimePublisher.syncState()
    local times = TimeRegistry.get() or {}
    DataChangeBus.fireListChange(TimeDtoFactory.createTimeDtoList(times))
    return {}
end

return TimePublisher
