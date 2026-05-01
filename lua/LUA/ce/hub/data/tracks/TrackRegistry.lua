if CeDebugLoad then print("[#Start] Loading ce.hub.data.tracks.TrackRegistry ...") end

local Track = require("ce.hub.data.tracks.Track")

---@class TrackRegistry
---@field add fun(trackType: string, track: table):nil
---@field get fun(trackType: string, trackId: string|number):Track|nil
---@field getAll fun(trackType: string):table<string, Track>
---@field markChanged fun(trackType: string, trackId: string|number):nil
---@field getChangedIds fun(trackType: string):table<string, boolean>
---@field clearChanged fun(trackType: string):nil
---@field markInitialListPending fun(trackType: string):nil
---@field isInitialListPending fun(trackType: string):boolean
---@field clearInitialListPending fun(trackType: string):nil
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
    tracksByType[trackType][tostring(track.id)] = Track:new(track)
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
    local track = TrackRegistry.get(trackType, trackId)
    if track and track.markChanged then track:markChanged() end
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
