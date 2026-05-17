local TippTextFormatter = require("ce.hub.eep.TippTextFormatter")
if CeDebugLoad then print("[#Start] Loading ce.mods.road.Intersection ...") end

local Task = require("ce.hub.scheduler.Task")
local Scheduler = require("ce.hub.scheduler.Scheduler")
local TrafficPhase = require("ce.mods.road.TrafficPhase")
local SignalGroup = require("ce.mods.road.SignalGroup")
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
local SignalIndication = require("ce.mods.road.SignalIndication")
local fmt = require("ce.hub.eep.TippTextFormatter")
local StorageUtility = require("ce.hub.util.StorageUtility")

local allIntersections = {}
local Intersection = {}
Intersection.debug = CeStartWithDebug or false
Intersection.allIntersections = {}

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
    self.tippStructure = tippStructure
    return self
end

function Intersection:getStaticCams() return self.staticCams end

function Intersection:addStaticCam(cameraName) table.insert(self.staticCams, cameraName) end

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
        phases = {},
        signalGroups = {},
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

function Intersection:scriptVariableName(scriptVariableName)
    self._scriptVariableName = scriptVariableName
    save(self)
    return self
end

function Intersection:newSignalGroup(name)
    local signalGroup = SignalGroup:new(name)
    table.insert(self.signalGroups, signalGroup)
    return signalGroup
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

local function recalculateSignalInfo(intersection)
    for _, lane in pairs(intersection.lanes) do lane:checkRequests() end

    local signalHeads = {}
    local sortedPhases = {}
    for _, phase in ipairs(intersection:getPhases()) do table.insert(sortedPhases, phase) end
    table.sort(sortedPhases, function (s1, s2) return s1.name < s2.name end)

    for _, phase in ipairs(sortedPhases) do
        for signalHead, signalType in pairs(phase.signalHeads) do signalHeads[signalHead] = signalType end
    end

    local signalHeadsToRefresh = {}
    for _, lane in pairs(intersection.lanes) do
        local signalHead = lane.laneSignal
        signalHeadsToRefresh[signalHead.signalId] = signalHead
        signalHead:setLaneNameInfo(fmt.bgLightBlue(lane.name) .. ".")
        signalHead:setLaneInfo(lane:getRequestInfo())
    end

    for signalHead in pairs(signalHeads) do
        signalHeadsToRefresh[signalHead.signalId] = signalHead
        local text = {}
        for _, phase in ipairs(sortedPhases) do
            local highlighted = phase == intersection:getCurrentPhase()
            local signalType = phase.signalHeads[signalHead]
            if not signalType then
                table.insert(text, "<br><j>" ..
                    (highlighted and fmt.bgRed(phase.name .. " (Rot)") or (phase.name .. " " .. fmt.bgRed("(Rot)"))))
            elseif signalType == TrafficPhase.Type.CAR then
                table.insert(text, "<br><j>" ..
                    (highlighted and fmt.bgGreen(phase.name .. " (Gruen)") or
                        (phase.name .. " " .. fmt.bgGreen("(Gruen)"))))
            elseif signalType == TrafficPhase.Type.PEDESTRIAN then
                table.insert(text, "<br><j>" ..
                    (highlighted and fmt.bgYellow(phase.name .. " (FG)") or
                        (phase.name .. " " .. fmt.bgYellow("(FG)"))))
            elseif signalType == TrafficPhase.Type.TRAM then
                table.insert(text, "<br><j>" ..
                    (highlighted and fmt.bgBlue(phase.name .. " (Tram)") or
                        (phase.name .. " " .. fmt.bgBlue("(Tram)"))))
            else
                assert(false, signalType)
            end
        end
        table.insert(text, "<br>")
        signalHead:setPhaseInfo(table.concat(text, ""))
    end

    for _, signalHead in pairs(signalHeadsToRefresh) do signalHead:refreshInfo() end
end

local function getLaneRequestInfoBar(lane)
    local text = ""
    local max = 5
    if lane.tracksUsedForRequest or lane.signalUsedForRequest then
        text = text .. (lane.queue:isEmpty() and "#####" or "_____")
    else
        local requests = "X"
        local vehicles = math.min(lane.vehicleCount * lane.fahrzeugMultiplikator, max - 1)
        for _ = 1, vehicles do requests = requests .. "_" end
        if lane.currentIndication == SignalIndication.RED then
            text = text .. fmt.bgRed(requests)
        elseif lane.currentIndication == SignalIndication.YELLOW then
            text = text .. fmt.bgYellow(requests)
        else
            text = text .. fmt.bgGreen(requests)
        end

        local grey = ""
        for _ = vehicles + 1, max - 1 do grey = grey .. "_" end
        text = text .. grey
    end
    return text .. "  " .. lane.name
end

function Intersection:updateLaneTipText()
    local text = fmt.bold(self.name) .. "<br>" .. "_____"
    for _, lane in pairs(self.lanes) do
        text = TippTextFormatter.appendUpTo1023(text, "<br></j>" .. getLaneRequestInfoBar(lane))
    end

    if self.tippStructure then
        EEPShowInfoStructure(self.tippStructure, IntersectionSettings.showLanesOnStructure)
        EEPChangeInfoStructure(self.tippStructure, text)
    end
end

local setupHelpCreated = IntersectionSettings.showSignalIdOnSignal

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

        for _, lane in pairs(myLanes) do table.insert(intersection.lanes, lane) end
        table.sort(intersection.lanes, function (a, b) return a.name < b.name end)
    end
end

function Intersection.switchPhases()
    if setupHelpCreated ~= IntersectionSettings.showSignalIdOnSignal then
        setupHelpCreated = IntersectionSettings.showSignalIdOnSignal
        for signalId = 1, 1000 do
            EEPShowInfoSignal(signalId, IntersectionSettings.showSignalIdOnSignal)
            if IntersectionSettings.showSignalIdOnSignal then
                EEPChangeInfoSignal(signalId, "<j>Signal: " .. signalId)
            end
        end
    end

    for _, intersection in pairs(allIntersections) do
        switch(intersection)
        recalculateSignalInfo(intersection)
        intersection:updateLaneTipText()
    end
end

return Intersection
