if CeDebugLoad then print("[#Start] Loading ce.hub.data.time.TimeUpdater ...") end

local TimeRegistry = require("ce.hub.data.time.TimeRegistry")

local TimeUpdater = {}

function TimeUpdater.runUpdate()
    TimeRegistry.set({
        {
            id = "times",
            name = "times",
            timeComplete = EEPTime,
            timeLapse = EEPGetTimeLapse and EEPGetTimeLapse() or nil,
            timeH = EEPTimeH,
            timeM = EEPTimeM,
            timeS = EEPTimeS
        }
    })
end

return TimeUpdater
