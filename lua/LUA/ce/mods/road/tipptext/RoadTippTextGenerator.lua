if CeDebugLoad then print("[#Start] Loading ce.mods.road.tipptext.RoadTippTextGenerator ...") end

local RoadOverviewTippTextComposer = require("ce.mods.road.tipptext.RoadOverviewTippTextComposer")
local RoadSignalTippTextComposer = require("ce.mods.road.tipptext.RoadSignalTippTextComposer")
local RoadTippTextOptions = require("ce.mods.road.tipptext.RoadTippTextOptions")
local SignalHousingStructure = require("ce.hub.data.structures.SignalHousingStructure")
local SignalRegistry = require("ce.hub.data.signals.SignalRegistry")
local StructureRegistry = require("ce.hub.data.structures.StructureRegistry")
local TrafficLight = require("ce.mods.road.TrafficLight")

local RoadTippTextGenerator = {}

function RoadTippTextGenerator.needsRoadStateRefresh()
    return RoadTippTextOptions.needsRoadStateRefresh()
end

function RoadTippTextGenerator.fingerprint()
    local options = RoadTippTextOptions.read()
    local values = {
        RoadTippTextOptions.fingerprint(options),
        SignalRegistry.getRevision(),
        StructureRegistry.getRevision()
    }
    if RoadTippTextOptions.needsTrafficLightFacts(options) then
        for _, trafficLight in ipairs(TrafficLight.getAll()) do
            table.insert(values, RoadSignalTippTextComposer.fingerprint(trafficLight, options))
        end
    end
    if RoadTippTextOptions.needsIntersectionFacts(options) then
        for _, intersection in ipairs(RoadOverviewTippTextComposer.sortedIntersections()) do
            table.insert(values, RoadOverviewTippTextComposer.fingerprint(intersection, options))
        end
    end
    return table.concat(values, "|")
end

local function addSignalState(states, signalId, visible, text)
    if not signalId then return end
    states[signalId] = {
        visible = visible == true,
        text = text or ""
    }
end

local function addStructureState(states, structureName, visible, text)
    if not structureName then return end
    states[structureName] = {
        visible = visible == true,
        text = text or ""
    }
end

local function shortTippName(name)
    return name and string.match(name, "^([^_]+)") or nil
end

local function addManagedClears(desired)
    for signalId in pairs(SignalRegistry.getAll()) do
        addSignalState(desired.signals, signalId, false, "")
    end
    for _, trafficLight in ipairs(TrafficLight.getAll()) do
        for _, structureName in ipairs(trafficLight:getAllTippTextStructures()) do
            addStructureState(desired.structures, structureName, false, "")
        end
    end
    StructureRegistry.forEach(function (structure, structureId)
        local structureName = structure.name or structureId
        if SignalHousingStructure.isSignalHousing(structure) then
            addStructureState(desired.structures, structureName, false, "")
        end
    end)
    for _, intersection in ipairs(RoadOverviewTippTextComposer.sortedIntersections()) do
        if intersection:getTippStructure() then
            addStructureState(desired.structures, intersection:getTippStructure(), false, "")
        end
    end
end

local function addTrafficLightState(desired, trafficLight, state)
    if trafficLight:getSignalId() > 0 then
        addSignalState(desired.signals, trafficLight:getSignalId(), state.visible, state.text)
    elseif state.visible then
        local primaryTargets = {}
        for _, structureName in ipairs(trafficLight:getPrimaryTippTextStructures()) do
            primaryTargets[structureName] = true
            addStructureState(desired.structures, structureName, true, state.text)
        end
        for _, structureName in ipairs(trafficLight:getAllTippTextStructures()) do
            if not primaryTargets[structureName] then
                addStructureState(desired.structures, structureName, false, "")
            end
        end
    else
        for _, structureName in ipairs(trafficLight:getAllTippTextStructures()) do
            addStructureState(desired.structures, structureName, false, "")
        end
    end
end

function RoadTippTextGenerator.generate()
    local options = RoadTippTextOptions.read()
    local laneBySignal, phasesBySignal, overviewTargets = RoadOverviewTippTextComposer.collectRoadFacts(options)
    local desired = {
        signals = {},
        structures = {}
    }
    addManagedClears(desired)

    if RoadTippTextOptions.needsTrafficLightFacts(options) then
        for _, trafficLight in ipairs(TrafficLight.getAll()) do
            local state = RoadSignalTippTextComposer.state(trafficLight, laneBySignal[trafficLight],
                                                           phasesBySignal[trafficLight], options)
            addTrafficLightState(desired, trafficLight, state)
        end
    end

    if options.showSignalIdOnSignal then
        for signalId in pairs(SignalRegistry.getAll()) do
            if desired.signals[signalId] == nil or not desired.signals[signalId].visible then
                addSignalState(desired.signals, signalId, true, "<j>Signal: " .. signalId)
            end
        end
        StructureRegistry.forEach(function (structure, structureId)
            local structureName = structure.name or structureId
            if SignalHousingStructure.isSignalHousing(structure) and
                (desired.structures[structureName] == nil or not desired.structures[structureName].visible) then
                addStructureState(desired.structures, structureName, true, "<j>Immo: " .. shortTippName(structureName))
            end
        end)
    end

    for _, target in ipairs(overviewTargets) do
        addStructureState(desired.structures, target.structureName, target.visible, target.text)
    end

    return desired
end

return RoadTippTextGenerator
