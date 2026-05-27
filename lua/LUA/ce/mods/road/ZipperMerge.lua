if CeDebugLoad then print("[#Start] Loading ce.mods.road.ZipperMerge ...") end

local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local StorageUtility = require("ce.hub.util.StorageUtility")
local Queue = require("ce.hub.util.Queue")

---@class ZipperMerge
---Alternates traffic from one main lane and one merge lane into one resulting lane.
---
---Use invisible EEP signals as gatekeepers. Contact points set those signals to red when traffic
---approaches and then call trafficOnMain(...) or trafficOnMerge(...). ZipperMerge only switches
---the next selected lane signal to green; it does not switch any signal to red.
---
---Register each instance with setKpId(...) when contact points pass an identifier:
---
---local ZipperMerge = require("ce.mods.road.ZipperMerge")
---local mergeA = ZipperMerge:new("Merge A", 101, 102):setKpId("mergeA")
---
---function onTrafficOnMain(trainName, zipperKpId)
---    ZipperMerge.resolve(zipperKpId):trafficOnMain(trainName)
---end
---
---function onTrafficOnMerge(trainName, zipperKpId)
---    ZipperMerge.resolve(zipperKpId):trafficOnMerge(trainName)
---end
---
---function onResultingLaneFree(trainName, zipperKpId)
---    ZipperMerge.resolve(zipperKpId):resultingLaneFree(trainName)
---end
---
---function onZipperMergeReset(trainName, zipperKpId)
---    ZipperMerge.resolve(zipperKpId):reset()
---end
---
---The resultingLaneFree(...) contact point should be placed after the merge where the previously
---released vehicle has cleared the resulting lane. CeRoadModule.run() calls ZipperMerge.runAll()
---so all registered instances can release the next waiting lane once the resulting lane is free.
---When resultingLaneFree(...) receives a queued train name, all older entries in the released side's
---queue are cleared too. This self-corrects stale contact point counts.
---@field name string
---@field type string
---@field mainSignalId number
---@field mergeSignalId number
---@field signalPositionGreen number
---@field mainQueue Queue
---@field mergeQueue Queue
---@field resultingQueue Queue
---@field resultingLaneBlocked boolean
---@field lastGreen string|nil
---@field debug boolean class-level toggle for zipper signal tipp texts
local ZipperMerge = {}
ZipperMerge.__index = ZipperMerge
ZipperMerge.debug = false
ZipperMerge.signalPositionGreen = 1

local Side = {
    MAIN = "main",
    MERGE = "merge"
}

local ownCountTagKey = "zmc"
local ownQueueTagKey = "zmq"
local resultingCountTagKey = "zmrc"
local resultingQueueTagKey = "zmrq"
local legacyOwnWaitingTagKey = "zmw"
local lastGreenTagKey = "zml"
local resultingLaneBlockedTagKey = "zmb"
local registry = {}
local zipperMergeBySignalId = {}
local allZipperMerges = {}
local revision = 0

local function markChanged()
    revision = revision + 1
end

local function assertSignalId(signalId, name)
    assert(type(signalId) == "number", "Need '" .. name .. "' as number")
    assert(signalId > 0, "Need '" .. name .. "' > 0")
end

local function pullTagValues(signalId)
    local tag = SignalRegistry.getOrCreate(signalId):pullTag()
    return StorageUtility.parseTableFromString(tag)
end

local function isSide(value)
    return value == Side.MAIN or value == Side.MERGE
end

local function loadLastGreen(mainValues, mergeValues)
    if isSide(mainValues[lastGreenTagKey]) then return mainValues[lastGreenTagKey] end
    if isSide(mergeValues[lastGreenTagKey]) then return mergeValues[lastGreenTagKey] end
    return nil
end

local function loadResultingLaneBlocked(mainValues, mergeValues)
    return StorageUtility.toboolean(mainValues[resultingLaneBlockedTagKey]) or
        StorageUtility.toboolean(mergeValues[resultingLaneBlockedTagKey])
end

local function boolText(value)
    return value and "true" or "false"
end

local function loadCount(values)
    local count = tonumber(values[ownCountTagKey])
    if count and count > 0 then return count end
    if StorageUtility.toboolean(values[legacyOwnWaitingTagKey]) then return 1 end
    return 0
end

local function queueFromText(pipeSeparatedText, count)
    local queue = Queue:new()
    if pipeSeparatedText then
        for trainName in string.gmatch(pipeSeparatedText, "[^|]+") do queue:push(trainName) end
    end
    for i = queue:size() + 1, count, 1 do queue:push("train " .. i) end
    return queue
end

local function loadQueue(values)
    return queueFromText(values[ownQueueTagKey], loadCount(values))
end

local function loadResultingLaneQueue(mainValues, mergeValues)
    local queueText = mainValues[resultingQueueTagKey] or mergeValues[resultingQueueTagKey]
    local count = tonumber(mainValues[resultingCountTagKey]) or tonumber(mergeValues[resultingCountTagKey]) or 0
    if count <= 0 and loadResultingLaneBlocked(mainValues, mergeValues) then count = 1 end
    return queueFromText(queueText, count)
end

local function queueToText(queue)
    return table.concat(queue:elements(), "|")
end

local function sideText(value)
    return value or "none"
end

local function queueForSide(self, side)
    if side == Side.MAIN then return self.mainQueue end
    return self.mergeQueue
end

local function sideHasTraffic(self, side)
    return not queueForSide(self, side):isEmpty()
end

local function resultingLaneIsFree(self)
    return self.resultingQueue:isEmpty()
end

local function syncResultingLaneBlocked(self)
    self.resultingLaneBlocked = not resultingLaneIsFree(self)
end

local function popUntilTrain(queue, trainName)
    if queue:isEmpty() then return 0 end

    local numberOfPops = 1
    local hasTrainName = trainName and trainName ~= ""
    if hasTrainName then
        numberOfPops = nil
        for i, trainFromQueue in ipairs(queue:elements()) do
            if trainFromQueue == trainName then
                numberOfPops = i
                break
            end
        end
        numberOfPops = numberOfPops or 1
    end

    for _ = 1, numberOfPops, 1 do queue:pop() end
    return numberOfPops
end

local function queueContains(queue, trainName)
    if not trainName or trainName == "" then return false end
    for _, trainFromQueue in ipairs(queue:elements()) do
        if trainFromQueue == trainName then return true end
    end
    return false
end

local function assertQueueTrainName(trainName)
    assert(type(trainName) == "string", "Need 'trainName' as string")
    assert(not string.find(trainName, ","), trainName)
    assert(not string.find(trainName, "|"), trainName)
end

function ZipperMerge:new(name, mainSignalId, mergeSignalId)
    assert(type(name) == "string", "Need 'name' as string")
    assertSignalId(mainSignalId, "mainSignalId")
    assertSignalId(mergeSignalId, "mergeSignalId")
    assert(mainSignalId ~= mergeSignalId, "Need different main and merge signal IDs")

    local mainValues = pullTagValues(mainSignalId)
    local mergeValues = pullTagValues(mergeSignalId)
    local o = {
        name = name,
        type = "ZipperMerge",
        mainSignalId = mainSignalId,
        mergeSignalId = mergeSignalId,
        signalPositionGreen = ZipperMerge.signalPositionGreen,
        mainQueue = loadQueue(mainValues),
        mergeQueue = loadQueue(mergeValues),
        resultingQueue = loadResultingLaneQueue(mainValues, mergeValues),
        resultingLaneBlocked = false,
        lastGreen = loadLastGreen(mainValues, mergeValues),
        _kpId = nil
    }
    self.__index = self
    o = setmetatable(o, self)
    syncResultingLaneBlocked(o)

    table.insert(allZipperMerges, o)
    zipperMergeBySignalId[mainSignalId] = o
    zipperMergeBySignalId[mergeSignalId] = o
    o:saveState()
    o:run()
    return o
end

function ZipperMerge:debugTippText(signalSide)
    syncResultingLaneBlocked(self)
    local nextSide = not resultingLaneIsFree(self) and "blocked" or self:nextSideToRelease()
    local template = "ZipperMerge %s<br>Signal: %s<br>Main count: %d<br>Merge count: %d<br>" ..
        "Resulting lane count: %d<br>Resulting lane blocked: %s<br>Last green: %s<br>Next: %s<br>" ..
        "Main queue: %s<br>Merge queue: %s<br>Resulting queue: %s"
    return string.format(
        template,
        self.name,
        signalSide,
        self.mainQueue:size(),
        self.mergeQueue:size(),
        self.resultingQueue:size(),
        boolText(self.resultingLaneBlocked),
        sideText(self.lastGreen),
        sideText(nextSide),
        queueToText(self.mainQueue),
        queueToText(self.mergeQueue),
        queueToText(self.resultingQueue)
    )
end

function ZipperMerge.debugTippTextForSignalId(signalId)
    if not ZipperMerge.debug then return nil end
    local zipperMerge = zipperMergeBySignalId[signalId]
    if not zipperMerge then return nil end
    local side = signalId == zipperMerge.mainSignalId and Side.MAIN or Side.MERGE
    return zipperMerge:debugTippText(side)
end

function ZipperMerge.getRevision()
    return revision
end

function ZipperMerge:setKpId(kpId)
    assert(type(kpId) == "string", "Need 'kpId' as string")
    if registry[kpId] and registry[kpId] ~= self then
        print("[WARNING] ZipperMerge.setKpId: duplicate key '" .. kpId .. "'\n" .. debug.traceback())
    end
    self._kpId = kpId
    self.kpId = kpId
    registry[kpId] = self
    return self
end

function ZipperMerge:getKpId() return self._kpId end

function ZipperMerge:setScriptVariableName(name) return self:setKpId(name) end

function ZipperMerge.resolve(kpId)
    assert(type(kpId) == "string", "Need kpId as string, got " .. type(kpId))
    local zipperMerge = registry[kpId]
    assert(zipperMerge, "No zipper merge registered for: " .. kpId)
    return zipperMerge
end

function ZipperMerge:saveSignalState(signalId, queue)
    syncResultingLaneBlocked(self)
    local values = pullTagValues(signalId)
    values[ownCountTagKey] = tostring(queue:size())
    values[ownQueueTagKey] = queueToText(queue)
    values[resultingCountTagKey] = tostring(self.resultingQueue:size())
    values[resultingQueueTagKey] = queueToText(self.resultingQueue)
    values[legacyOwnWaitingTagKey] = nil
    values[resultingLaneBlockedTagKey] = boolText(self.resultingLaneBlocked)
    values[lastGreenTagKey] = self.lastGreen
    SignalRegistry.getOrCreate(signalId):setTag(StorageUtility.encodeTable(values))
end

function ZipperMerge:saveState()
    self:saveSignalState(self.mainSignalId, self.mainQueue)
    self:saveSignalState(self.mergeSignalId, self.mergeQueue)
    markChanged()
end

function ZipperMerge:switchSideGreen(side)
    local signalId = side == Side.MAIN and self.mainSignalId or self.mergeSignalId
    local releasedTrainName = queueForSide(self, side):firstElement()
    local signal = SignalRegistry.getOrCreate(signalId)
    signal:pullPosition()
    signal:setPosition(self.signalPositionGreen)
    self.lastGreen = side
    if releasedTrainName then self.resultingQueue:push(releasedTrainName) end
    syncResultingLaneBlocked(self)
    self:saveState()
end

function ZipperMerge:nextSideToRelease()
    local mainWaiting = sideHasTraffic(self, Side.MAIN)
    local mergeWaiting = sideHasTraffic(self, Side.MERGE)
    if mainWaiting and not mergeWaiting then return Side.MAIN end
    if mergeWaiting and not mainWaiting then return Side.MERGE end
    if not mainWaiting and not mergeWaiting then return nil end
    if self.lastGreen == Side.MAIN and mergeWaiting then return Side.MERGE end
    return Side.MAIN
end

function ZipperMerge:run()
    if not resultingLaneIsFree(self) then return self end

    local side = self:nextSideToRelease()
    if not side then return self end

    self:switchSideGreen(side)
    return self
end

function ZipperMerge:trafficOnMain(trainName)
    assertQueueTrainName(trainName)
    self.mainQueue:push(trainName)
    self:saveState()
    return self:run()
end

function ZipperMerge:trafficOnMerge(trainName)
    assertQueueTrainName(trainName)
    self.mergeQueue:push(trainName)
    self:saveState()
    return self:run()
end

function ZipperMerge:resultingLaneFree(trainName)
    assert(type(trainName) == "string", "Need 'trainName' as string")
    popUntilTrain(self.resultingQueue, trainName)
    if queueContains(self.mainQueue, trainName) then
        popUntilTrain(self.mainQueue, trainName)
    elseif queueContains(self.mergeQueue, trainName) then
        popUntilTrain(self.mergeQueue, trainName)
    end
    syncResultingLaneBlocked(self)
    self:saveState()
    return self:run()
end

function ZipperMerge:reset()
    self.mainQueue = Queue:new()
    self.mergeQueue = Queue:new()
    self.resultingQueue = Queue:new()
    syncResultingLaneBlocked(self)
    self.lastGreen = nil
    self:saveState()
    return self
end

function ZipperMerge.runAll()
    for _, zipperMerge in ipairs(allZipperMerges) do zipperMerge:run() end
end

return ZipperMerge
