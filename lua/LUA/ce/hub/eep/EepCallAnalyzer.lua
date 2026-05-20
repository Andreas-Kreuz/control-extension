if CeDebugLoad then print("[#Start] Loading ce.hub.eep.EepCallAnalyzer ...") end

local ExchangeDirRegistry = require("ce.databridge.ExchangeDirRegistry")
local json = require("ce.third-party.json")

---@class EepCallAnalyzer
local EepCallAnalyzer = {}

local DEFAULT_RUNS = 100

local state = {
    enabled = false,
    active = false,
    completed = false,
    runsTarget = DEFAULT_RUNS,
    runsObserved = 0,
    discoveryDepth = 0,
    calls = {},
    callbacks = {},
    discoveryCalls = {},
    stackTraces = {},
    wrappers = {},
    originals = {},
    wrapperLookup = {}
}

local function resetCounters()
    state.calls = {}
    state.callbacks = {}
    state.discoveryCalls = {}
    state.stackTraces = {
        calls = {},
        callbacks = {},
        discoveryCalls = {}
    }
end

local function resetSession(runsTarget)
    resetCounters()
    state.enabled = true
    state.active = false
    state.completed = false
    state.runsTarget = runsTarget
    state.runsObserved = 0
    state.discoveryDepth = 0
end

local function isEepFunctionName(name)
    return type(name) == "string" and string.find(name, "^EEP") ~= nil
end

local function isCallbackName(name)
    return name == "EEPMain" or string.find(name, "^EEPOn") ~= nil
end

local function incrementCounter(target, name)
    target[name] = (target[name] or 0) + 1
end

local function incrementStackTrace(target, name, stackTrace)
    target[name] = target[name] or {}
    target[name][stackTrace] = (target[name][stackTrace] or 0) + 1
end

local function collectStackTrace()
    if debug and debug.traceback then return debug.traceback("", 4) end
    return "debug.traceback unavailable"
end

local function countInvocation(name)
    if not state.active then return end

    local stackTrace = collectStackTrace()
    if isCallbackName(name) then
        incrementCounter(state.callbacks, name)
        incrementStackTrace(state.stackTraces.callbacks, name, stackTrace)
    else
        incrementCounter(state.calls, name)
        incrementStackTrace(state.stackTraces.calls, name, stackTrace)
        if state.discoveryDepth > 0 then
            incrementCounter(state.discoveryCalls, name)
            incrementStackTrace(state.stackTraces.discoveryCalls, name, stackTrace)
        end
    end
end

local function makeWrapper(name, original)
    local function wrapper(...)
        countInvocation(name)
        return original(...)
    end
    state.wrapperLookup[wrapper] = true
    return wrapper
end

local function wrapFunction(name, fn)
    if state.wrapperLookup[fn] then return end

    if state.wrappers[name] then state.wrapperLookup[state.wrappers[name]] = nil end
    local wrapper = makeWrapper(name, fn)
    state.originals[name] = fn
    state.wrappers[name] = wrapper
    rawset(_G, name, wrapper)
end

local function restoreWrappers()
    for name, wrapper in pairs(state.wrappers) do
        if rawget(_G, name) == wrapper then rawset(_G, name, state.originals[name]) end
        state.wrapperLookup[wrapper] = nil
    end
    state.wrappers = {}
    state.originals = {}
end

local function sumValues(values)
    local sum = 0
    for _, value in pairs(values) do sum = sum + value end
    return sum
end

local function copyCounts(values)
    local copy = {}
    for key, value in pairs(values) do copy[key] = value end
    return copy
end

local function copyNestedCounts(values)
    local copy = {}
    for key, nestedValues in pairs(values) do copy[key] = copyCounts(nestedValues) end
    return copy
end

local function buildResult()
    return {
        status = state.completed and "completed" or state.active and "running" or "disabled",
        runsTarget = state.runsTarget,
        runsObserved = state.runsObserved,
        totals = {
            calls = sumValues(state.calls),
            callbacks = sumValues(state.callbacks),
            discoveryCalls = sumValues(state.discoveryCalls)
        },
        calls = copyCounts(state.calls),
        callbacks = copyCounts(state.callbacks),
        discoveryCalls = copyCounts(state.discoveryCalls),
        stackTraces = {
            calls = copyNestedCounts(state.stackTraces.calls),
            callbacks = copyNestedCounts(state.stackTraces.callbacks),
            discoveryCalls = copyNestedCounts(state.stackTraces.discoveryCalls)
        }
    }
end

local function outputFileName()
    return ExchangeDirRegistry.getExchangeDirectory() .. "/eep-call-analysis.json"
end

local function writeResult()
    local content = json.encode(buildResult())
    local fileName = outputFileName()
    local file = io.open(fileName, "w")
    assert(file, fileName)
    file:write(content)
    file:flush()
    file:close()
    return content, fileName
end

local function scanGlobalsInternal()
    if not state.enabled or state.completed then return end

    for name, value in pairs(_G) do
        if isEepFunctionName(name) and type(value) == "function" then wrapFunction(name, value) end
    end
end

function EepCallAnalyzer.configure(options)
    if options == nil then return end
    assert(type(options) == "table", "eepCallAnalysis must be a table")

    if options.enabled == false then
        state.enabled = false
        state.active = false
        state.completed = false
        state.discoveryDepth = 0
        restoreWrappers()
        return
    end

    if options.enabled ~= true then
        assert(options.enabled == nil, "eepCallAnalysis.enabled must be true or false")
        return
    end

    local runs = options.runs or DEFAULT_RUNS
    assert(type(runs) == "number" and runs >= 1 and runs == math.floor(runs),
           "eepCallAnalysis.runs must be a positive integer")

    restoreWrappers()
    resetSession(runs)
    scanGlobalsInternal()
    print(string.format("[#EepCallAnalyzer] EEP call analysis enabled for %d ControlExtension runs", runs))
end

function EepCallAnalyzer.scanGlobals()
    scanGlobalsInternal()
end

function EepCallAnalyzer.beginRun()
    if not state.enabled or state.completed then return end
    state.active = true
    EepCallAnalyzer.scanGlobals()
end

function EepCallAnalyzer.endRun()
    if not state.active then return end

    state.runsObserved = state.runsObserved + 1
    EepCallAnalyzer.scanGlobals()

    if state.runsObserved >= state.runsTarget then
        state.active = false
        state.completed = true
        state.discoveryDepth = 0
        restoreWrappers()
        local ok, resultOrError, fileName = pcall(writeResult)
        if ok then
            print("[#EepCallAnalyzer] Wrote EEP call analysis to " .. tostring(fileName))
        else
            print("[#EepCallAnalyzer] FILE ERROR: " .. tostring(resultOrError))
        end
    end
end

function EepCallAnalyzer.beginDiscovery()
    if not state.active then return end
    EepCallAnalyzer.scanGlobals()
    state.discoveryDepth = state.discoveryDepth + 1
end

function EepCallAnalyzer.endDiscovery()
    if state.discoveryDepth > 0 then state.discoveryDepth = state.discoveryDepth - 1 end
end

function EepCallAnalyzer.runInDiscovery(fn)
    EepCallAnalyzer.beginDiscovery()
    local result = { fn() }
    EepCallAnalyzer.endDiscovery()
    return table.unpack(result)
end

function EepCallAnalyzer.getResult()
    return buildResult()
end

function EepCallAnalyzer.reset()
    restoreWrappers()
    state.enabled = false
    state.active = false
    state.completed = false
    state.runsTarget = DEFAULT_RUNS
    state.runsObserved = 0
    state.discoveryDepth = 0
    resetCounters()
end

return EepCallAnalyzer
