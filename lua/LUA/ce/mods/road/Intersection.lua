if CeDebugLoad then print("[#Start] Loading ce.mods.road.Intersection ...") end

local Task = require("ce.hub.scheduler.Task")
local Scheduler = require("ce.hub.scheduler.Scheduler")
local TrafficPhase = require("ce.mods.road.TrafficPhase")
local SignalGroup = require("ce.mods.road.SignalGroup")
local Lane = require("ce.mods.road.Lane")
local PedestrianCrossing = require("ce.mods.road.PedestrianCrossing")
local SignalIndication = require("ce.mods.road.SignalIndication")
local StorageUtility = require("ce.hub.util.StorageUtility")

local allIntersections = {}
local Intersection = {}
Intersection.debug = CeStartWithDebug or false
Intersection.allIntersections = {}

function Intersection.getAll()
    local copy = {}
    for name, intersection in pairs(allIntersections) do copy[name] = intersection end
    return copy
end

function Intersection.switchManuallyTo(intersectionName, phaseName)
    if Intersection.debug then
        print(string.format("[#Intersection] switchManuallyTo: %s/%s", intersectionName, phaseName))
    end
    local intersection = Intersection.allIntersections[intersectionName]
    if intersection then intersection:setManualPhase(phaseName) end
end

function Intersection.switchAutomatically(intersectionName)
    if Intersection.debug then print(string.format("[#Intersection] switchAutomatically: %s", intersectionName)) end
    local intersection = Intersection.allIntersections[intersectionName]
    if intersection then intersection:setAutomaticPhaseSelection() end
end

function Intersection.getType() return "Intersection" end

function Intersection:getName() return self.name end

function Intersection:getEepSaveId() return self.eepSaveId end

function Intersection:getScriptVariableName() return self._scriptVariableName end

function Intersection:getPhases() return self.phases end

function Intersection:getCurrentPhase() return self.currentPhase end

function Intersection:getCurrentPhaseStartedAt() return self.currentPhaseStartedAt end

function Intersection:getLanes() return self.lanes end

function Intersection:getTippStructure() return self.tippStructure end

function Intersection:getNextPhase() return self.nextPhase end

function Intersection:getManualPhase() return self.manualPhase end

function Intersection:onSwitchedToPhase(currentPhase)
    for _, lane in pairs(self.lanes) do
        if currentPhase:getLanes()[lane] then
            lane:resetWaitCount()
        else
            lane:incrementWaitCount()
        end
    end
    self.currentPhase = currentPhase
    self.currentPhaseStartedAt = EEPTime or 0
end

function Intersection:calculateNextPhase()
    local nextPhase
    if self.manualPhase then
        nextPhase = self.manualPhase
    elseif self.switchInStrictOrder == true then
        local nextIndex = 1
        for i, phase in ipairs(self.phases) do
            if self.currentPhase == phase then nextIndex = i == #self.phases and 1 or i + 1 end
        end
        nextPhase = self.phases[nextIndex]
    else
        local sortedTable = {}
        for _, phase in ipairs(self.phases) do table.insert(sortedTable, phase) end
        table.sort(sortedTable, TrafficPhase.phasePriorityComparator)
        nextPhase = sortedTable[1]
    end
    return nextPhase
end

function Intersection:setManualPhase(phaseName)
    for _, phase in ipairs(self.phases) do
        if phase.name == phaseName then
            self.manualPhase = phase
            print(string.format("[#Intersection] Manuell geschaltet auf: %s (%s')", phase.name, self.name))
            self:setGreenTimeFinished(true)
        end
    end
end

function Intersection:setAutomaticPhaseSelection()
    self.manualPhase = nil
    self:setGreenTimeFinished(true)
    print(string.format("[#Intersection] Automatikmodus aktiviert. (%s')", self.name))
end

function Intersection:setSwitchInStrictOrder(value)
    assert(value == true or value == false, "Use Intersection:setSwitchInStrictOrder(true|false)")
    self.switchInStrictOrder = value
    return self
end

function Intersection:getGreenTimeSeconds() return self.greenTimeSeconds end

function Intersection:setGreenTimeFinished(greenTimeFinished) self.greenTimeFinished = greenTimeFinished end

function Intersection:isGreenTimeFinished() return self.greenTimeFinished end

function Intersection:setGreenReached(greenReached) self.greenReached = greenReached end

function Intersection:isGreenReached() return self.greenReached end

function Intersection:setTippStructure(tippStructure)
    if self.tippStructure == tippStructure then return self end
    self.tippStructure = tippStructure
    return self
end

function Intersection:getStaticCams() return self.staticCams end

function Intersection:addStaticCams(...)
    for _, cameraName in ipairs({ ... }) do
        table.insert(self.staticCams, cameraName)
    end
    return self
end

function Intersection:addStaticCam(cameraName) return self:addStaticCams(cameraName) end

function Intersection.resetVehicles()
    for _, intersection in pairs(allIntersections) do
        print(string.format("[#Intersection] SETZE ZURUECK: %s", intersection.name))
        if intersection.lanes then for _, lane in pairs(intersection.lanes) do lane:resetVehicles() end end
    end
end

local function save(intersection)
    if intersection.eepSaveId ~= -1 then
        StorageUtility.saveTable(intersection.eepSaveId, {
                                     scriptVariableName = intersection._scriptVariableName or ""
                                 }, "Intersection " .. intersection.name)
    end
end

local function load(intersection)
    if intersection.eepSaveId ~= -1 then
        local data = StorageUtility.loadTable(intersection.eepSaveId, "Intersection " .. intersection.name)
        if not intersection._scriptVariableName or intersection._scriptVariableName == "" then
            intersection._scriptVariableName = data["scriptVariableName"]
        end
    end
end

function Intersection:new(name, greenTimeSeconds)
    local o = {
        name = name,
        currentPhase = nil,
        currentPhaseStartedAt = 0,
        phases = {},
        signalGroups = {},
        pedestrianCrossings = {},
        signalGroupsBySignalUse = {},
        lanes = {},
        signals = {},
        greenReached = true,
        greenTimeFinished = true,
        greenTimeSeconds = greenTimeSeconds or 15,
        switchInStrictOrder = false,
        eepSaveId = -1,
        _scriptVariableName = nil,
        tippStructure = nil,
        staticCams = {}
    }
    self.__index = self
    setmetatable(o, self)
    Intersection.allIntersections[name] = o
    allIntersections[name] = o
    table.sort(allIntersections, function (name1, name2) return name1 < name2 end)
    return o
end

function Intersection:withStorage(eepSaveId)
    eepSaveId = eepSaveId or -1
    assert(type(eepSaveId) == "number")
    self.eepSaveId = eepSaveId
    if eepSaveId ~= -1 then StorageUtility.registerId(eepSaveId, "Intersection " .. self.name) end
    load(self)
    save(self)
    return self
end

function Intersection:setScriptVariableName(scriptVariableName)
    self._scriptVariableName = scriptVariableName
    save(self)
    return self
end

function Intersection:scriptVariableName(scriptVariableName) return self:setScriptVariableName(scriptVariableName) end

function Intersection:newSignalGroup(name)
    local signalGroup = SignalGroup:new(name)
    table.insert(self.signalGroups, signalGroup)
    return signalGroup
end

local function addLane(intersection, lane)
    for _, existingLane in ipairs(intersection.lanes) do
        if existingLane == lane or existingLane.name == lane.name then return lane end
    end
    table.insert(intersection.lanes, lane)
    lane._owningIntersection = intersection
    return lane
end

function Intersection:newLane(name, laneSignal)
    return addLane(self, Lane:new(name, laneSignal))
end

function Intersection:newPedestrianCrossing(name)
    local pedestrianCrossing = PedestrianCrossing:new(name)
    table.insert(self.pedestrianCrossings, pedestrianCrossing)
    return pedestrianCrossing
end

function Intersection:signalGroupForSignalUse(signalHead, signalType)
    local logicalUse = SignalGroup.logicalUseFor(signalType)
    self.signalGroupsBySignalUse = self.signalGroupsBySignalUse or {}
    self.signalGroupsBySignalUse[logicalUse] = self.signalGroupsBySignalUse[logicalUse] or {}
    local signalGroup = self.signalGroupsBySignalUse[logicalUse][signalHead]
    if not signalGroup then
        signalGroup = self:newSignalGroup(signalHead:signalNamesText() .. " " .. logicalUse)
        signalGroup:addSignals(signalType, signalHead)
        self.signalGroupsBySignalUse[logicalUse][signalHead] = signalGroup
    end
    return signalGroup
end

function Intersection:newPhase(name, greenTimeSeconds)
    local phase = TrafficPhase:new(name, greenTimeSeconds or self.greenTimeSeconds)
    self:addPhase(phase)
    return phase
end

function Intersection:addPhase(phase)
    phase.intersection = self
    table.insert(self.phases, phase)
    return phase
end

local function allSignalHeads(phases)
    local list = {}
    for _, phase in ipairs(phases) do
        assert(phase.getType() == "TrafficPhase", type(phase))
        for signalHead, signalType in pairs(phase.signalHeads) do list[signalHead] = signalType end
    end
    return list
end

local function switch(intersection)
    local TrafficLight = require("ce.mods.road.TrafficLight")

    if Intersection.debug then
        print(string.format("[#Intersection] Schalte Kreuzung %s: %s", intersection:getName(),
                            intersection:isGreenTimeFinished() and "Ja" or "Nein"))
    end

    if not intersection:isGreenTimeFinished() or not intersection.greenReached then do return true end end

    intersection.greenReached = false
    intersection:setGreenTimeFinished(false)

    local nextPhase = intersection:calculateNextPhase()
    local currentPhase = intersection:getCurrentPhase()
    intersection.nextPhase = nextPhase

    if Intersection.debug then
        print(string.format("[#Intersection] Schalte %s zu %s %s (%s)", intersection:getName(), intersection.name,
                            nextPhase:getName(), nextPhase:lanesNamesText()))
    end
    if not currentPhase then
        TrafficLight.switchAll(allSignalHeads(intersection.phases), SignalIndication.RED, "Schalte initial auf rot")
    end

    local switchedPhaseTask = Task:new(function () intersection:onSwitchedToPhase(nextPhase) end,
                                       intersection.name .. " verwendet nun Phase " .. nextPhase.name)

    local lastTask
    local tasks = nextPhase:tasksForPhaseChangeFrom(currentPhase, switchedPhaseTask)
    for _, t in ipairs(tasks) do
        Scheduler:scheduleTask(t.offset, t.task, t.precedingTask)
        lastTask = t.task
    end

    local greenReachedTask = Task:new(
        function ()
            if Intersection.debug then
                print(string.format(
                    "[#Intersection] %s: Kreuzung ist auf gruen geschaltet.",
                    intersection.name))
            end
            intersection.greenReached = true
        end, intersection.name .. " ist nun auf gruen geschaltet)")
    Scheduler:scheduleTask(0, greenReachedTask, lastTask)

    local greenTimeSeconds = nextPhase.greenTimeSeconds
    local intersectionFinishedTask = Task:new(
        function ()
            if Intersection.debug then
                print(string.format(
                    "[#Intersection] %s: Fahrzeuge sind gefahren, " ..
                    "kreuzung ist dann frei.",
                    intersection.name))
            end
            intersection:setGreenTimeFinished(true)
        end,
        intersection.name .. " ist nun bereit zum Umschalten (war " ..
        greenTimeSeconds .. "s auf gruen geschaltet)")
    Scheduler:scheduleTask(greenTimeSeconds, intersectionFinishedTask, greenReachedTask)
end

function Intersection.initPhases()
    for _, intersection in pairs(allIntersections) do
        local myLanes = {}
        for _, phase in ipairs(intersection.phases) do
            phase:initPhase()
            local laneFound = false
            for lane in pairs(phase.lanes) do
                myLanes[lane.name] = lane
                laneFound = true
            end
            if not laneFound then
                print(string.format("[#Intersection] No LANE found in phase %s (%s)", phase.name, intersection.name))
            end
            assert(laneFound)
            for signalHead in pairs(phase.signalHeads) do
                intersection.signals[signalHead.signalId] = signalHead
            end
            if Intersection.debug then
                print(string.format(
                    "[#Intersection] %s - %s: %s",
                    intersection.name,
                    phase.name,
                    phase:lanesNamesText()))
            end
        end

        for _, lane in pairs(myLanes) do
            if lane._owningIntersection == intersection then
                addLane(intersection, lane)
            else
                table.insert(intersection.lanes, lane)
            end
        end
        table.sort(intersection.lanes, function (a, b) return a.name < b.name end)
    end
end

function Intersection.refreshRoadState()
    for _, intersection in pairs(allIntersections) do
        for _, lane in pairs(intersection.lanes) do lane:checkRequests() end
    end
end

function Intersection.switchPhases()
    for _, intersection in pairs(allIntersections) do switch(intersection) end
end

return Intersection
