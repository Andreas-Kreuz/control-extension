if CeDebugLoad then print("[#Start] Loading ce.mods.road.TramCrossing ...") end

local Scheduler = require("ce.hub.scheduler.Scheduler")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local StorageUtility = require("ce.hub.util.StorageUtility")
local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
local Task = require("ce.hub.scheduler.Task")

---@class TramCrossingSignal
---Signal configuration used because one tram crossing can block several signals at once.
---@field signal number EEP signal ID
---@field signalPositionIfOccupied number Signal position used when at least one tram is inside the crossing
---@field signalPositionIfClear number Signal position used when the crossing is clear
---@field signalPositionYellow number Signal position used during the yellow phase

---@class TramCrossing
---Counts trams in one crossing so signals stay red while any tram is still inside.
---The count is persisted in the primary signal tag so a Lua reload does not make an occupied crossing look clear.
---@field name string Crossing name for diagnostics and scheduled task names
---@field primarySignal number EEP signal ID whose tag stores the train count
---@field signals TramCrossingSignal[] Signals switched by this crossing
---@field securedIndicators TramCrossingSecuredIndicator[] Structure axes showing secured crossing state
---@field count number Number of trams currently counted inside the crossing
---@field secured boolean Whether the crossing signals currently secure the crossing with red
---@field yellowPhaseSeconds number Duration of the yellow phase before changing to occupied
local TramCrossing = {}
TramCrossing.__index = TramCrossing
TramCrossing.defaultYellowPhaseSeconds = 2
local registry = {}

local countTagKey = "c"

---Reads the persisted crossing count from the primary signal tag.
---The tag uses StorageUtility table syntax with the compact key `c`.
---This is used on startup so the crossing can recover its occupied state after a Lua reload.
---@param signal number EEP signal ID
---@return number count persisted count, or 0 when the tag cannot be parsed
local function parseCount(signal)
    local tag = SignalRegistry.getOrCreate(signal):pullTag()

    local values = StorageUtility.parseTableFromString(tag)
    local count = tonumber(values[countTagKey])
    if not count or count < 0 then return 0 end

    return count
end

---Creates the internal signal configuration for one signal.
---This keeps the per-signal EEP positions together so all switch methods can treat every signal uniformly.
---@param signal number EEP signal ID
---@param signalPositionIfOccupied number Signal position for occupied/red
---@param signalPositionIfClear number Signal position for clear/green
---@param signalPositionYellow? number Signal position for yellow; defaults to occupied/red
---@return TramCrossingSignal
local function createSignal(signal, signalPositionIfOccupied, signalPositionIfClear, signalPositionYellow)
    assert(type(signal) == "number", "Need 'signal' as number")
    assert(type(signalPositionIfOccupied) == "number", "Need 'signalPositionIfOccupied' as number")
    assert(type(signalPositionIfClear) == "number", "Need 'signalPositionIfClear' as number")
    if signalPositionYellow ~= nil then
        assert(type(signalPositionYellow) == "number", "Need 'signalPositionYellow' as number")
    end

    return {
        signal = signal,
        signalPositionIfOccupied = signalPositionIfOccupied,
        signalPositionIfClear = signalPositionIfClear,
        signalPositionYellow = signalPositionYellow or signalPositionIfOccupied
    }
end

---@class TramCrossingSecuredIndicator
---@field structureId string EEP structure ID or Lua name
---@field axis number|string EEP structure axis number or name
---@field axisValueUnsecured number Axis value when the crossing is not secured by red signals
---@field axisValueSecured number Axis value when the crossing is secured by red signals

---@param structureId string EEP structure ID or Lua name
---@param axis number|string EEP structure axis number or name
---@param axisValueUnsecured number Axis value when the crossing is not secured
---@param axisValueSecured number Axis value when the crossing is secured
---@return TramCrossingSecuredIndicator
local function createSecuredIndicator(structureId, axis, axisValueUnsecured, axisValueSecured)
    assert(type(structureId) == "string", "Need 'structureId' as string")
    assert(type(axis) == "number" or type(axis) == "string", "Need 'axis' as number or string")
    assert(type(axisValueUnsecured) == "number", "Need 'axisValueUnsecured' as number")
    assert(type(axisValueSecured) == "number", "Need 'axisValueSecured' as number")

    local ok
    local structure = StructureRegistry.getOrCreate(structureId)
    if type(axis) == "number" then
        ok = structure:pullAxisByNumber(axis) ~= nil
    else
        ok = structure:pullAxis(axis) ~= nil
    end
    assert(ok, "Secured indicator structure axis not found: " .. structureId .. " axis " .. axis)

    return {
        structureId = structureId,
        axis = axis,
        axisValueUnsecured = axisValueUnsecured,
        axisValueSecured = axisValueSecured
    }
end

---Creates a tram crossing and loads the current train count from the primary signal tag.
---The constructor signal stores the count; additional signals only follow state changes.
---Use this once per physical tram crossing so each instance has independent state and signal control.
---@param crossingName string Name of the crossing
---@param signal number Primary EEP signal ID
---@param signalPositionIfOccupied number Signal position when count is greater than 0
---@param signalPositionIfClear number Signal position when count is 0
---@param signalPositionYellow? number Optional yellow phase signal position
---@return TramCrossing
function TramCrossing:new(crossingName, signal, signalPositionIfOccupied, signalPositionIfClear,
                          signalPositionYellow)
    assert(type(crossingName) == "string", "Need 'crossingName' as string")

    local o = {
        name = crossingName,
        primarySignal = signal,
        signals = {},
        securedIndicators = {},
        count = parseCount(signal),
        secured = false,
        yellowPhaseSeconds = TramCrossing.defaultYellowPhaseSeconds
    }
    self.__index = self
    o = setmetatable(o, self)

    o:addSignal(signal, signalPositionIfOccupied, signalPositionIfClear, signalPositionYellow)
    o:switchByCount()
    return o
end

---Adds another signal controlled by this crossing.
---The added signal is switched with the crossing but does not store the count in its tag.
---Use this when several signals must show the same crossing state without duplicating persistence.
---@param signal number EEP signal ID
---@param signalPositionIfOccupied number Signal position when count is greater than 0
---@param signalPositionIfClear number Signal position when count is 0
---@param signalPositionYellow? number Optional yellow phase signal position
---@return TramCrossing self for chained calls
function TramCrossing:addSignal(signal, signalPositionIfOccupied, signalPositionIfClear, signalPositionYellow)
    table.insert(self.signals, createSignal(signal, signalPositionIfOccupied, signalPositionIfClear,
                                            signalPositionYellow))
    self:switchByCount()
    return self
end

---Adds a structure axis that indicates when the crossing is secured by red signals.
---The secured value is set only after the crossing has switched to occupied/red.
---@param structureId string EEP structure ID or Lua name
---@param axis number|string EEP structure axis number or name
---@param axisValueUnsecured number Axis value when the crossing is clear or yellow
---@param axisValueSecured number Axis value when the crossing is occupied/red
---@return TramCrossing self for chained calls
function TramCrossing:addSecuredIndicator(structureId, axis, axisValueUnsecured, axisValueSecured)
    table.insert(self.securedIndicators,
                 createSecuredIndicator(structureId, axis, axisValueUnsecured, axisValueSecured))
    self:switchSecuredIndicators(self.secured)
    return self
end

---Configures the yellow phase duration before occupied/red.
---Use this when a layout needs a longer or shorter warning phase than the default two seconds.
---@param seconds number Duration in EEP seconds
---@return TramCrossing self for chained calls
function TramCrossing:setYellowPhaseSeconds(seconds)
    assert(type(seconds) == "number", "Need 'seconds' as number")
    assert(seconds >= 0, "Need 'seconds' >= 0")
    self.yellowPhaseSeconds = seconds
    return self
end

---Marks a train as having entered the crossing and updates persistence and signals.
---Use this from an entry contact point to reserve the crossing until the matching exit event arrives.
---@param trainName string EEP train name; accepted for contact point symmetry
function TramCrossing:trainEntered(trainName)
    assert(type(trainName) == "string", "Need 'trainName' as string")
    local oldCount = self.count
    self.count = self.count + 1
    self:saveCount()

    if oldCount == 0 and self.count > 0 then
        self:switchToYellowThenOccupied()
    else
        self:switchByCount()
    end
end

---Marks a train as having exited the crossing and updates persistence and signals.
---Counts below zero are clamped back to zero.
---Use this from an exit contact point to release the crossing once the last counted tram has left.
---@param trainName string EEP train name; accepted for contact point symmetry
function TramCrossing:trainExited(trainName)
    assert(type(trainName) == "string", "Need 'trainName' as string")
    self.count = self.count - 1
    if self.count < 0 then self.count = 0 end
    self:saveCount()
    self:switchByCount()
end

---Persists the current count to the primary signal tag.
---This is used after every count change because EEP signal tags survive Lua reloads with the layout.
function TramCrossing:saveCount()
    local tag = StorageUtility.encodeTable({ [countTagKey] = tostring(self.count) })
    SignalRegistry.getOrCreate(self.primarySignal):setTag(tag)
end

---Switches all signals according to the current count without a yellow phase.
---This is used for startup, added signals, and clear transitions where the final state must be applied immediately.
function TramCrossing:switchByCount()
    if self.count > 0 then
        self:switchToOccupied()
    else
        self:switchToClear()
    end
end

---Switches all signals to their configured clear/green position.
---This is used when no tram is inside the crossing so road traffic may proceed again.
function TramCrossing:switchToClear()
    self:switchSecuredIndicators(false)
    for _, signal in ipairs(self.signals) do
        SignalRegistry.getOrCreate(signal.signal):setPosition(signal.signalPositionIfClear)
    end
end

---Switches all signals to their configured yellow position.
---This is used as the warning phase before road traffic is stopped for an entering tram.
function TramCrossing:switchToYellow()
    self:switchSecuredIndicators(false)
    for _, signal in ipairs(self.signals) do
        SignalRegistry.getOrCreate(signal.signal):setPosition(signal.signalPositionYellow)
    end
end

---Switches all signals to their configured occupied/red position.
---This is used while at least one tram is inside the crossing so conflicting traffic stays stopped.
function TramCrossing:switchToOccupied()
    self:switchSecuredIndicators(true)
    for _, signal in ipairs(self.signals) do
        SignalRegistry.getOrCreate(signal.signal):setPosition(signal.signalPositionIfOccupied)
    end
end

---Switches all configured secured indicators to the requested secured state.
---@param isSecured boolean Whether the crossing is secured by red signals
function TramCrossing:switchSecuredIndicators(isSecured)
    self.secured = isSecured
    for _, indicator in ipairs(self.securedIndicators) do
        local axisValue = isSecured and indicator.axisValueSecured or indicator.axisValueUnsecured
        local structure = StructureRegistry.getOrCreate(indicator.structureId)
        if type(indicator.axis) == "number" then
            structure:setAxisByNumber(indicator.axis, axisValue)
        else
            structure:setAxis(indicator.axis, axisValue)
        end
    end
end

---Starts the yellow phase and schedules the final occupied/red switch.
---If the crossing clears before the task runs, the delayed task keeps the signals clear.
---This is used only on the transition from clear to occupied so already blocked crossings do not restart yellow.
function TramCrossing:switchToYellowThenOccupied()
    self:switchToYellow()

    local task = Task:new(function ()
                              if self.count > 0 then
                                  self:switchToOccupied()
                              else
                                  self:switchToClear()
                              end
                          end, "TramCrossing " .. self.name .. " occupied")
    Scheduler:scheduleTask(self.yellowPhaseSeconds, task)
end

function TramCrossing:setKpId(kpId)
    assert(type(kpId) == "string", "Need 'kpId' as string")
    if registry[kpId] and registry[kpId] ~= self then
        print("[WARNING] TramCrossing.setKpId: duplicate key '" .. kpId .. "'\n" .. debug.traceback())
    end
    self._kpId = kpId
    self.kpId = kpId
    registry[kpId] = self
    return self
end

function TramCrossing:getKpId() return self._kpId end

function TramCrossing:setScriptVariableName(name) return self:setKpId(name) end

function TramCrossing.resolve(kpId)
    assert(type(kpId) == "string", "Need kpId as string, got " .. type(kpId))
    local crossing = registry[kpId]
    assert(crossing, "No crossing registered for: " .. kpId)
    return crossing
end

return TramCrossing
