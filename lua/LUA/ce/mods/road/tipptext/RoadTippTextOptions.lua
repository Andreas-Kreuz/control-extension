if CeDebugLoad then print("[#Start] Loading ce.mods.road.tipptext.RoadTippTextOptions ...") end

local IntersectionSettings = require("ce.mods.road.IntersectionSettings")

local RoadTippTextOptions = {}

function RoadTippTextOptions.read()
    return {
        showRequestsOnSignal = IntersectionSettings.showRequestsOnSignal,
        showPhaseOnSignal = IntersectionSettings.showPhaseOnSignal,
        showModelInfoOnSignal = IntersectionSettings.showModelInfoOnSignal,
        showLaneNamesOnSignal = IntersectionSettings.showLaneNamesOnSignal,
        showNameAndPhaseOnSignal = IntersectionSettings.showNameAndPhaseOnSignal,
        showSignalIdOnSignal = IntersectionSettings.showSignalIdOnSignal,
        showLanesOnStructure = IntersectionSettings.showLanesOnStructure
    }
end

function RoadTippTextOptions.needsTrafficLightFacts(options)
    return options.showRequestsOnSignal or options.showPhaseOnSignal or options.showModelInfoOnSignal or
        options.showLaneNamesOnSignal or options.showNameAndPhaseOnSignal or options.showSignalIdOnSignal
end

function RoadTippTextOptions.needsLaneFacts(options)
    return options.showRequestsOnSignal or options.showLaneNamesOnSignal or options.showNameAndPhaseOnSignal
end

function RoadTippTextOptions.needsPhaseFacts(options)
    return options.showPhaseOnSignal or options.showLanesOnStructure
end

function RoadTippTextOptions.needsIntersectionFacts(options)
    return RoadTippTextOptions.needsLaneFacts(options) or RoadTippTextOptions.needsPhaseFacts(options)
end

function RoadTippTextOptions.needsRoadStateRefresh(options)
    options = options or RoadTippTextOptions.read()
    return options.showRequestsOnSignal == true
end

function RoadTippTextOptions.fingerprint(options)
    return table.concat({
        tostring(options.showRequestsOnSignal),
        tostring(options.showPhaseOnSignal),
        tostring(options.showModelInfoOnSignal),
        tostring(options.showLaneNamesOnSignal),
        tostring(options.showNameAndPhaseOnSignal),
        tostring(options.showSignalIdOnSignal),
        tostring(options.showLanesOnStructure)
    }, "|")
end

return RoadTippTextOptions
