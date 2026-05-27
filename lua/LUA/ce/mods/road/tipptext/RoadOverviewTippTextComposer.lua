if CeDebugLoad then print("[#Start] Loading ce.mods.road.tipptext.RoadOverviewTippTextComposer ...") end

local Intersection = require("ce.mods.road.Intersection")
local RoadTippTextOptions = require("ce.mods.road.tipptext.RoadTippTextOptions")
local TrafficPhase = require("ce.mods.road.TrafficPhase")
local fmt = require("ce.hub.eep.TippTextFormatter")

local RoadOverviewTippTextComposer = {}

local function repeatText(text, count)
    local result = ""
    for _ = 1, count do result = result .. text end
    return result
end

local function secondsSincePhaseStarted(intersection)
    local now = EEPTime or intersection:getCurrentPhaseStartedAt() or 0
    local startedAt = intersection:getCurrentPhaseStartedAt() or now
    if now < startedAt then return now + 24 * 60 * 60 - startedAt end
    return now - startedAt
end

local function currentPhaseColoredUnderscores(intersection, phase)
    local max = 5
    if phase ~= intersection:getCurrentPhase() then return max end
    local remainingSeconds = phase.greenTimeSeconds - secondsSincePhaseStarted(intersection)
    if remainingSeconds > 10 then return max end
    return math.max(0, math.min(max, math.ceil(remainingSeconds / 2)))
end

local function sortedPhases(intersection)
    local phases = {}
    for _, phase in ipairs(intersection:getPhases()) do table.insert(phases, phase) end
    table.sort(phases, function (phase1, phase2) return phase1.name < phase2.name end)
    return phases
end

function RoadOverviewTippTextComposer.sortedIntersections()
    local intersections = {}
    for _, intersection in pairs(Intersection.getAll()) do table.insert(intersections, intersection) end
    table.sort(intersections, function (intersection1, intersection2)
        return intersection1:getName() < intersection2:getName()
    end)
    return intersections
end

local function allSignalHeads(intersection)
    local signalHeads = {}
    for _, phase in ipairs(sortedPhases(intersection)) do
        for signalHead, signalType in pairs(phase.signalHeads) do signalHeads[signalHead] = signalType end
    end
    return signalHeads
end

local function phaseInfoText(intersection, signalHead)
    local text = {}
    for _, phase in ipairs(sortedPhases(intersection)) do
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
    return table.concat(text, "")
end

function RoadOverviewTippTextComposer.composeTippText(intersection)
    local currentPhase = intersection:getCurrentPhase()
    local phaseBarMax = 5

    local infoText = "<b>" .. intersection:getName() .. "</b>"

    -- Phase overview: each phase gets a bar and its name; the current phase name is bold.
    for _, phase in ipairs(intersection:getPhases()) do
        infoText = fmt.appendUpTo1023(infoText, "<br></j>")

        if phase == currentPhase then
            local coloredUnderscores = currentPhaseColoredUnderscores(intersection, phase)
            local colored = "X" .. repeatText("_", coloredUnderscores)
            local grey = repeatText("_", phaseBarMax - coloredUnderscores)

            infoText = fmt.appendUpTo1023(infoText, fmt.bgGreen(colored))
            infoText = fmt.appendUpTo1023(infoText, grey)
            infoText = fmt.appendUpTo1023(infoText, "  ")
            infoText = fmt.appendUpTo1023(infoText, "<b>" .. phase.name .. "</b>")
        else
            infoText = fmt.appendUpTo1023(infoText, fmt.grey("X" .. repeatText("_", phaseBarMax)))
            infoText = fmt.appendUpTo1023(infoText, "  ")
            infoText = fmt.appendUpTo1023(infoText, phase.name)
        end
    end

    return infoText
end

function RoadOverviewTippTextComposer.collectRoadFacts(options)
    local laneBySignal = {}
    local phasesBySignal = {}
    local overviewTargets = {}
    if not RoadTippTextOptions.needsIntersectionFacts(options) then
        return laneBySignal, phasesBySignal, overviewTargets
    end

    for _, intersection in ipairs(RoadOverviewTippTextComposer.sortedIntersections()) do
        if RoadTippTextOptions.needsLaneFacts(options) then
            for _, lane in ipairs(intersection:getLanes()) do
                laneBySignal[lane:getLaneSignal()] = lane
            end
        end
        if options.showPhaseOnSignal then
            for signalHead in pairs(allSignalHeads(intersection)) do
                phasesBySignal[signalHead] = phaseInfoText(intersection, signalHead)
            end
        end
        if options.showLanesOnStructure and intersection:getTippStructure() then
            table.insert(overviewTargets, {
                structureName = intersection:getTippStructure(),
                visible = true,
                text = RoadOverviewTippTextComposer.composeTippText(intersection)
            })
        end
    end
    return laneBySignal, phasesBySignal, overviewTargets
end

local function laneFingerprintPart(lane, options)
    local values = {
        lane:getName(),
        lane:getLaneSignal():getSignalId()
    }
    if options.showRequestsOnSignal then
        local state = lane:getRequestState()
        table.insert(values, tostring(state.occupied))
        table.insert(values, state.vehicleCount)
        table.insert(values, state.waitCount)
        table.insert(values, state.requestType)
        table.insert(values, state.source)
        table.insert(values, table.concat(state.queuedVehicleNames, "|"))
    end
    if options.showLaneNamesOnSignal then table.insert(values, lane:getKpId() or "") end
    return table.concat(values, ":")
end

function RoadOverviewTippTextComposer.fingerprint(intersection, options)
    local currentPhase = intersection:getCurrentPhase()
    local values = {
        intersection:getName()
    }
    if options.showLanesOnStructure then
        table.insert(values, intersection:getTippStructure() or "")
        table.insert(values, currentPhase and currentPhase.name or "")
        table.insert(values, currentPhase and currentPhaseColoredUnderscores(intersection, currentPhase) or -1)
    elseif options.showPhaseOnSignal then
        table.insert(values, currentPhase and currentPhase.name or "")
    end
    if RoadTippTextOptions.needsLaneFacts(options) then
        for _, lane in ipairs(intersection:getLanes()) do table.insert(values, laneFingerprintPart(lane, options)) end
    end
    if RoadTippTextOptions.needsPhaseFacts(options) then
        for _, phase in ipairs(intersection:getPhases()) do
            table.insert(values, phase.name)
            local signalHeads = {}
            for signalHead, signalType in pairs(phase.signalHeads) do
                table.insert(signalHeads, {
                    signalId = signalHead:getSignalId(),
                    signalType = signalType
                })
            end
            table.sort(signalHeads, function (signalHead1, signalHead2)
                return signalHead1.signalId < signalHead2.signalId
            end)
            for _, signalHead in ipairs(signalHeads) do
                table.insert(values, signalHead.signalId .. "=" .. signalHead.signalType)
            end
        end
    end
    return table.concat(values, ":")
end

return RoadOverviewTippTextComposer
