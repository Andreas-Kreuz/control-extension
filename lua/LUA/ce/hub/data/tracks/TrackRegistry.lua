if CeDebugLoad then print("[#Start] Loading ce.hub.data.tracks.TrackRegistry ...") end

local TrackRegistry = {}

local trackTypes = { "auxiliary", "control", "road", "rail", "tram" }
local tracksByType = {}
local changedTrackIdsByType = {}
local initialListPendingByType = {}

for _, trackType in ipairs(trackTypes) do
    tracksByType[trackType] = {}
    changedTrackIdsByType[trackType] = {}
    initialListPendingByType[trackType] = false
end

function TrackRegistry.add(trackType, track)
    tracksByType[trackType][tostring(track.id)] = track
end

function TrackRegistry.get(trackType, trackId)
    return tracksByType[trackType][tostring(trackId)]
end

function TrackRegistry.getAll(trackType)
    local copy = {}
    for trackId, track in pairs(tracksByType[trackType]) do copy[trackId] = track end
    return copy
end

function TrackRegistry.markChanged(trackType, trackId)
    changedTrackIdsByType[trackType][tostring(trackId)] = true
end

function TrackRegistry.getChangedIds(trackType)
    local copy = {}
    for trackId in pairs(changedTrackIdsByType[trackType]) do copy[trackId] = true end
    return copy
end

function TrackRegistry.clearChanged(trackType)
    changedTrackIdsByType[trackType] = {}
end

function TrackRegistry.markInitialListPending(trackType)
    initialListPendingByType[trackType] = true
end

function TrackRegistry.isInitialListPending(trackType)
    return initialListPendingByType[trackType] == true
end

function TrackRegistry.clearInitialListPending(trackType)
    initialListPendingByType[trackType] = false
end

return TrackRegistry
