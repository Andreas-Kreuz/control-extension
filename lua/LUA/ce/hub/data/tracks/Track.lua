if CeDebugLoad then print("[#Start] Loading ce.hub.data.tracks.Track ...") end

---@class Track
---@field id number
---@field trackType string|nil
---@field reserved boolean
---@field reservedByTrainName string|nil
---@field dirtyFields table<string, boolean>
---@field needsFullSend boolean
---@field new fun(self: Track, o: table):Track
---@field setReservation fun(self: Track, reserved: boolean, reservedByTrainName: string|nil):nil
---@field markChanged fun(self: Track):nil
---@field resetDirty fun(self: Track):nil
---@field hasDirtyFields fun(self: Track):boolean
local Track = {}

local function isReservedFunction(trackType)
    if trackType == "road" then return _G.EEPIsRoadTrackReserved end
    if trackType == "rail" then return _G.EEPIsRailTrackReserved end
    if trackType == "tram" then return _G.EEPIsTramTrackReserved end
    if trackType == "control" then return _G.EEPIsControlTrackReserved end
    if trackType == "auxiliary" then return _G.EEPIsAuxiliaryTrackReserved end
    return nil
end

local function markDirty(track, fieldName)
    track.dirtyFields[fieldName] = true
end

local function updateField(track, fieldName, value)
    local oldValue = track[fieldName]
    track[fieldName] = value
    if oldValue ~= value then markDirty(track, fieldName) end
end

function Track:new(o)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(o) == "table", "Need 'o' as table")
    assert(o.id, "Provide an id")

    self.__index = self
    setmetatable(o, self)
    o.dirtyFields = {}
    o.needsFullSend = true
    return o
end

function Track.registerRoadTrack(roadId)
    if _G.EEPRegisterRoadTrack then return _G.EEPRegisterRoadTrack(roadId) end
    return false
end

function Track:setReservation(reserved, reservedByTrainName)
    assert(type(self) == "table", "Call this method with ':'")
    assert(type(reserved) == "boolean", "Need 'reserved' as boolean")

    updateField(self, "reserved", reserved)
    updateField(self, "reservedByTrainName", reservedByTrainName)
end

function Track:pullReservation()
    assert(type(self) == "table", "Call this method with ':'")
    local getter = isReservedFunction(self.trackType or "road")
    if type(getter) ~= "function" then return nil, nil end

    local ok, reserved, trainName = getter(self.id, true)
    if not ok then return nil, nil end

    self:setReservation(reserved == true, reserved and trainName or nil)
    return self.reserved, self.reservedByTrainName
end

function Track:markChanged()
    markDirty(self, "reserved")
    markDirty(self, "reservedByTrainName")
end

function Track:resetDirty()
    self.dirtyFields = {}
end

function Track:hasDirtyFields()
    return next(self.dirtyFields) ~= nil
end

return Track
