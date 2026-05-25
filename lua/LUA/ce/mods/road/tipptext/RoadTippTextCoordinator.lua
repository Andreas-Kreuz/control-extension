if CeDebugLoad then print("[#Start] Loading ce.mods.road.tipptext.RoadTippTextCoordinator ...") end

local Intersection = require("ce.mods.road.Intersection")
local RoadTippTextGenerator = require("ce.mods.road.tipptext.RoadTippTextGenerator")
local Signal = require("ce.hub.data.signals.Signal")
local Structure = require("ce.hub.data.structures.Structure")

local RoadTippTextCoordinator = {}
local lastFingerprint = nil
local lastSignalTargets = {}
local lastStructureTargets = {}

local function addMissingClears(states, lastTargets)
    for target in pairs(lastTargets) do
        if states[target] == nil then
            states[target] = {
                visible = false,
                text = ""
            }
        end
    end
end

local function targetSet(states)
    local targets = {}
    for target in pairs(states) do targets[target] = true end
    return targets
end

local function applySignalStates(signalStates)
    for signalId, state in pairs(signalStates) do
        Signal.showTippTextById(signalId, state.visible)
        Signal.setTippTextById(signalId, state.text)
    end
end

local function applyStructureStates(structureStates)
    for structureName, state in pairs(structureStates) do
        Structure.showTippTextByName(structureName, state.visible)
        Structure.setTippTextByName(structureName, state.text)
    end
end

function RoadTippTextCoordinator.run()
    if RoadTippTextGenerator.needsRoadStateRefresh() then Intersection.refreshRoadState() end

    local fingerprint = RoadTippTextGenerator.fingerprint()
    if fingerprint == lastFingerprint then return end

    local desired = RoadTippTextGenerator.generate()
    addMissingClears(desired.signals, lastSignalTargets)
    addMissingClears(desired.structures, lastStructureTargets)
    applySignalStates(desired.signals)
    applyStructureStates(desired.structures)

    lastSignalTargets = targetSet(desired.signals)
    lastStructureTargets = targetSet(desired.structures)
    lastFingerprint = fingerprint
end

return RoadTippTextCoordinator
