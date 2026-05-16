if CeDebugLoad then print("[#Start] Loading ce.mods.road.TrafficPhase ...") end

local Task = require("ce.hub.scheduler.Task")
local SignalGroup = require("ce.mods.road.SignalGroup")

local TrafficPhase = {}
TrafficPhase.debug = CeStartWithDebug or false
TrafficPhase.Type = SignalGroup.Type

function TrafficPhase.getType() return "TrafficPhase" end

function TrafficPhase:getName() return self.name end

function TrafficPhase:new(name, greenTimeSeconds)
    local o = {
        type = "TrafficPhase",
        name = name,
        intersection = nil,
        prio = 0,
        signalGroups = {},
        signalHeads = {},
        greenTimeSeconds = greenTimeSeconds or 15
    }
    self.__index = self
    return setmetatable(o, self)
end

local function assertNoVehiclePedestrianConflict(phase, signalHead, signalType)
    local logicalUse = SignalGroup.logicalUseFor(signalType)
    phase.signalUsesBySignalHead = phase.signalUsesBySignalHead or {}
    local useSet = phase.signalUsesBySignalHead[signalHead] or {}
    useSet[logicalUse] = true
    phase.signalUsesBySignalHead[signalHead] = useSet
    assert(not (useSet.VEHICLE and useSet.PEDESTRIAN),
           "Ein Signal darf in derselben Phase nicht gleichzeitig Fahrzeug- und Fu\223g\228ngerverkehr freigeben.")
end

function TrafficPhase:addSignalGroup(...)
    for _, signalGroup in ipairs({ ... }) do
        assert(signalGroup and signalGroup.getType and signalGroup:getType() == "SignalGroup",
               "Specify SignalGroup instances")
        table.insert(self.signalGroups, signalGroup)
        for signalHead, signalType in pairs(signalGroup:getSignalHeads()) do
            assertNoVehiclePedestrianConflict(self, signalHead, signalType)
            self.signalHeads[signalHead] = signalType
        end
    end
    return self
end

function TrafficPhase:initPhase()
    self.lanes = {}
    for signalHead, signalType in pairs(self.signalHeads) do
        if signalType ~= TrafficPhase.Type.PEDESTRIAN then
            for lane in pairs(signalHead.lanes) do self.lanes[lane] = true end
        end
    end
end

function TrafficPhase:signalHeadsToTurnRedAndGreen(oldPhase)
    local turnRed = {}
    local turnGreen = {}

    if oldPhase then
        for signalHead, oldType in pairs(oldPhase.signalHeads) do
            local newType = self.signalHeads[signalHead]
            if not newType or newType ~= oldType then
                assert(signalHead.type == "TrafficLight")
                turnRed[signalHead] = oldType
            end
        end
    end
    for signalHead, newType in pairs(self.signalHeads) do
        local oldType = oldPhase and oldPhase.signalHeads[signalHead] or nil
        if not oldType or newType ~= oldType then
            assert(signalHead.type == "TrafficLight")
            turnGreen[signalHead] = newType
        end
    end

    return turnRed, turnGreen
end

local function switchTask(signalHeads, signalTypeFilter, indication, reason)
    local TrafficLight = require("ce.mods.road.TrafficLight")
    local toTurn = {}
    for signalHead, signalType in pairs(signalHeads) do
        if signalType == signalTypeFilter then toTurn[signalHead] = true end
    end
    return Task:new(function () TrafficLight.switchAll(toTurn, indication, reason) end, reason)
end

function TrafficPhase:tasksForPhaseChangeFrom(oldPhase, afterRedTask)
    local SignalIndication = require("ce.mods.road.SignalIndication")
    local taskList = {}
    local toRed, toGreen = self:signalHeadsToTurnRedAndGreen(oldPhase)
    local oldRedCars

    if oldPhase then
        local oldRedPedestrian = switchTask(toRed, TrafficPhase.Type.PEDESTRIAN, SignalIndication.RED,
                                            "Schalte " .. oldPhase.name .. " auf Fussgaenger Rot")
        table.insert(taskList, { offset = 0, task = oldRedPedestrian, precedingTask = nil })

        local oldYellowTram = switchTask(toRed, TrafficPhase.Type.TRAM, SignalIndication.YELLOW,
                                         "Schalte " .. oldPhase.name .. " auf gelb (Tram)")
        table.insert(taskList, { offset = 0, task = oldYellowTram, precedingTask = oldRedPedestrian })

        local oldYellowCars = switchTask(toRed, TrafficPhase.Type.CAR, SignalIndication.YELLOW,
                                         "Schalte " .. oldPhase.name .. " auf gelb (Auto)")
        table.insert(taskList, { offset = 0, task = oldYellowCars, precedingTask = oldRedPedestrian })

        oldRedCars = switchTask(toRed, TrafficPhase.Type.CAR, SignalIndication.RED,
                                "Schalte " .. oldPhase.name .. " auf rot (Auto)")
        table.insert(taskList, { offset = 2, task = oldRedCars, precedingTask = oldYellowCars })

        local oldRedTram = switchTask(toRed, TrafficPhase.Type.TRAM, SignalIndication.RED,
                                      "Schalte " .. oldPhase.name .. " auf rot (Tram)")
        table.insert(taskList, { offset = 2, task = oldRedTram, precedingTask = oldYellowCars })
    else
        oldRedCars = Task:new(function () end, "clear intersection")
        table.insert(taskList, { offset = 4, task = oldRedCars, precedingTask = nil })
    end

    table.insert(taskList, { offset = 0, task = afterRedTask, precedingTask = oldRedCars })

    local nextRedYellow = switchTask(toGreen, TrafficPhase.Type.CAR, SignalIndication.REDYELLOW,
                                     "Schalte " .. self.name .. " auf rot-gelb")
    table.insert(taskList, { offset = 3, task = nextRedYellow, precedingTask = oldRedCars })

    local nextGreenTram = switchTask(toGreen, TrafficPhase.Type.TRAM, SignalIndication.GREEN,
                                     "Schalte " .. self.name .. " auf gruen (Tram)")
    table.insert(taskList, { offset = 1, task = nextGreenTram, precedingTask = nextRedYellow })

    local nextPedestrian = switchTask(toGreen, TrafficPhase.Type.PEDESTRIAN, SignalIndication.PEDESTRIAN,
                                      "Schalte " .. self.name .. " auf Fussgaenger gruen")
    table.insert(taskList, { offset = 3, task = nextPedestrian, precedingTask = oldRedCars })

    local nextGreenCars = switchTask(toGreen, TrafficPhase.Type.CAR, SignalIndication.GREEN,
                                     "Schalte " .. self.name .. " auf gruen (Auto)")
    table.insert(taskList, { offset = 1, task = nextGreenCars, precedingTask = nextRedYellow })

    return taskList
end

function TrafficPhase:getLanes() return self.lanes end

function TrafficPhase:lanesNamesText()
    local s = ""
    for lane in pairs(self.lanes) do s = s .. ", " .. lane.name end
    return s:sub(3)
end

function TrafficPhase:lanesSortedByPriority()
    local signalHeadArray = {}
    for signalHead, signalType in pairs(self.signalHeads) do
        if signalType ~= TrafficPhase.Type.PEDESTRIAN then table.insert(signalHeadArray, signalHead) end
    end

    local sortedLanes = {}
    local laneCount = 0
    local prioritySum = 0
    for lane in pairs(self.lanes) do
        table.insert(sortedLanes, lane)
        laneCount = laneCount + 1
        prioritySum = prioritySum + lane:calculatePriority(signalHeadArray)
    end
    local averagePrio = prioritySum / laneCount
    table.sort(sortedLanes, function (lane1, lane2)
        local prio1 = lane1:calculatePriority(signalHeadArray)
        local prio2 = lane2:calculatePriority(signalHeadArray)
        if prio1 ~= prio2 then return prio1 > prio2 end
        return lane1.name < lane2.name
    end)
    self.prio = averagePrio
    return sortedLanes, laneCount, averagePrio
end

function TrafficPhase:lanesSortedByName()
    local sortedLanes = {}
    for lane in pairs(self.lanes) do table.insert(sortedLanes, lane) end
    table.sort(sortedLanes, function (a, b) return a.name < b.name end)
    return sortedLanes
end

function TrafficPhase.phasePriorityComparator(phase1, phase2)
    if phase1 and phase2 then
        local _, laneCount1, avg1 = phase1:lanesSortedByPriority()
        local _, laneCount2, avg2 = phase2:lanesSortedByPriority()
        if avg1 ~= avg2 then return avg1 > avg2 end
        if laneCount1 ~= laneCount2 then return laneCount1 > laneCount2 end
        return phase1.name > phase2.name
    end
end

function TrafficPhase:calculatePriority()
    local _, _, prio = self:lanesSortedByPriority()
    return prio
end

function TrafficPhase:resetWaitCount() for lane in pairs(self.lanes) do lane:resetWaitCount() end end

return TrafficPhase
