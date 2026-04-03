if AkDebugLoad then print("[#Start] Loading ce.hub.data.tracks.TrackDetection ...") end

local DataChangeBus = require("ce.hub.publish.DataChangeBus")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TrackDtoFactory = require("ce.hub.data.tracks.TrackDtoFactory")
local RuntimeMetrics = require("ce.hub.data.runtime.RuntimeMetrics")
local TrackDetection = {}

local MAX_TRACKS = 50000

local registerFunctions = {
    auxiliary = EEPRegisterAuxiliaryTrack,
    control = EEPRegisterControlTrack,
    road = EEPRegisterRoadTrack,
    rail = EEPRegisterRailTrack,
    tram = EEPRegisterTramTrack
}
local reservedFunctions = {
    auxiliary = EEPIsAuxiliaryTrackReserved,
    control = EEPIsControlTrackReserved,
    road = EEPIsRoadTrackReserved,
    rail = EEPIsRailTrackReserved,
    tram = EEPIsTramTrackReserved
}
local ceTypesByTrackType = {
    auxiliary = HubCeTypes.AuxiliaryTrack,
    control = HubCeTypes.ControlTrack,
    road = HubCeTypes.RoadTrack,
    rail = HubCeTypes.RailTrack,
    tram = HubCeTypes.TramTrack
}

local function isSelected(selectedCeTypes, ceType)
    if not selectedCeTypes or next(selectedCeTypes) == nil then return true end
    return selectedCeTypes[ceType] == true
end

---store runtime
---@param identifier string
---@param time number
function TrackDetection:storeRunTime(identifier, time)
    RuntimeMetrics.storeRunTime("TrackCollector.ALL." .. identifier, time)
    RuntimeMetrics.storeRunTime("TrackCollector." .. self.trackType .. "." .. identifier, time)
end

---This will create a dictionary of train names to their location on the tracks
---@return table<string,table<string,number>>
function TrackDetection:findTrainsOnTrack(selectedCeTypes)
    ---@type table<string,table<string,number>>
    local trainsOnTrack = {}
    local changedTracks = {}
    local trackSelected = isSelected(selectedCeTypes, ceTypesByTrackType[self.trackType])

    -- Fill the list of tracks for each train by looking in every track
    for _, track in pairs(self.tracks) do
        local trackId = track.id
        -- Limitation: only the first train on a track is found
        local _, occupied, trainName = self.reservedFunction(trackId, true)
        if trackSelected then
            local reservedByTrainName = occupied and trainName or nil
            if track.reserved ~= occupied or track.reservedByTrainName ~= reservedByTrainName then
                track.reserved = occupied
                track.reservedByTrainName = reservedByTrainName
                changedTracks[tostring(trackId)] = track
            end
        end
        if occupied and trainName then
            trainsOnTrack[trainName] = trainsOnTrack[trainName] or {}
            trainsOnTrack[trainName][tostring(trackId)] = trackId
        end
    end

    if trackSelected and next(changedTracks) ~= nil then
        for _, track in pairs(changedTracks) do
            DataChangeBus.fireDataChanged(TrackDtoFactory.createTrackDto(self.trackType, track))
        end
    end

    return trainsOnTrack
end

function TrackDetection:initialize(selectedCeTypes)
    for id = 1, MAX_TRACKS do
        local exists = self.registerFunction(id)
        if exists then
            local track = {}
            track.id = id
            local _, occupied, trainName = self.reservedFunction(id, true)
            track.reserved = occupied
            track.reservedByTrainName = occupied and trainName or nil
            -- track.position = val
            self.tracks[tostring(track.id)] = track
        end
    end

    if isSelected(selectedCeTypes, ceTypesByTrackType[self.trackType]) then
        DataChangeBus.fireListChange(TrackDtoFactory.createTrackDtoList(self.trackType, self.tracks))
    end
    self:updateData()
end

function TrackDetection:updateData()
    local _ = self
    return {
        -- [self.trackType .. "-tracks"] = self.tracks,
    }
end

function TrackDetection:new(trackType)
    assert(trackType, "Bitte geben Sie den Namen \"trackType\" an.")
    assert(registerFunctions[trackType], "trackType must be one of 'auxiliary', 'control', 'road', 'rail', 'tram'")
    assert(reservedFunctions[trackType], "trackType must be one of 'auxiliary', 'control', 'road', 'rail', 'tram'")

    local o = {
        registerFunction = registerFunctions[trackType],
        reservedFunction = reservedFunctions[trackType],
        trackType = trackType,
        tracks = {}
    }

    self.__index = self
    setmetatable(o, self)
    return o
end

return TrackDetection
