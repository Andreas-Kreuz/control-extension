if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadDataCollector ...") end
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
local Lane = require("ce.mods.road.Lane")
local SignalIndication = require("ce.mods.road.SignalIndication")

local RoadDataCollector = {}

local function padnum(d)
    local dec, n = string.match(d, "(%.?)0*(.+)")
    return #dec > 0 and ("%.12f"):format(d) or ("%s%03d%s"):format(dec, #n, n)
end

local function optionalValueFromGetterOrField(value, getterName, fieldName)
    if value and type(value[getterName]) == "function" then return value[getterName](value) end
    return value and value[fieldName] or nil
end
local function createSignalGroupDto(signalGroup)
    local signalIds = {}
    local trafficType = "CAR"
    local pedestrianCrossingNames = {}
    for signalHead, signalType in pairs(signalGroup:getSignalHeads()) do
        table.insert(signalIds, signalHead.signalId)
        trafficType = signalType
    end
    for _, crossing in ipairs(signalGroup.getPedestrianCrossings and signalGroup:getPedestrianCrossings() or {}) do
        table.insert(pedestrianCrossingNames, crossing:getName())
    end
    table.sort(signalIds)
    table.sort(pedestrianCrossingNames)
    return {
        name = signalGroup.name,
        scriptVariableName = optionalValueFromGetterOrField(signalGroup, "getScriptVariableName",
                                                            "_scriptVariableName"),
        approach = optionalValueFromGetterOrField(signalGroup, "getApproach", "approach"),
        turnDirections = optionalValueFromGetterOrField(signalGroup, "getTurnDirections", "turnDirections"),
        trafficType = trafficType,
        signalIds = signalIds,
        pedestrianCrossingNames = pedestrianCrossingNames
    }
end

local function createPedestrianCrossingDto(crossing, signalGroupNames)
    return {
        name = crossing:getName(),
        scriptVariableName = crossing:getScriptVariableName(),
        approach = crossing:getApproach(),
        signalGroups = signalGroupNames
    }
end

local function defaultSignalGroupsForLane(intersection, lane)
    local signalGroupNames = {}
    local defaultDriveSignals = lane.defaultDriveSignals or {}
    for _, signalGroup in ipairs(intersection.signalGroups or {}) do
        local hasMatchingSignal = false
        for signalHead, signalType in pairs(signalGroup:getSignalHeads()) do
            if signalType ~= "PEDESTRIAN" and (defaultDriveSignals[signalHead] or signalHead == lane.laneSignal) then
                hasMatchingSignal = true
            end
        end
        if hasMatchingSignal then table.insert(signalGroupNames, signalGroup.name) end
    end
    return signalGroupNames
end

local function signalGroupsForSignals(intersection, signals)
    local signalGroupNames = {}
    for _, signalGroup in ipairs(intersection.signalGroups or {}) do
        local hasMatchingSignal = false
        for signalHead, signalType in pairs(signalGroup:getSignalHeads()) do
            if signalType ~= "PEDESTRIAN" and signals[signalHead] then hasMatchingSignal = true end
        end
        if hasMatchingSignal then table.insert(signalGroupNames, signalGroup.name) end
    end
    table.sort(signalGroupNames)
    return signalGroupNames
end

local function sortedNumberKeys(values)
    local keys = {}
    for value in pairs(values or {}) do table.insert(keys, value) end
    table.sort(keys)
    return keys
end

local function sortedNumberValues(values)
    local sortedValues = {}
    for _, value in ipairs(values or {}) do table.insert(sortedValues, value) end
    table.sort(sortedValues)
    return sortedValues
end

local function requestSignalsForRoute(lane, route)
    local requestSignals = lane.requestSignals and lane.requestSignals[route]
    local signals = {}
    for _, signal in ipairs(requestSignals or {}) do signals[signal] = true end
    return signals
end

local function defaultRequestSignalGroupsForLane(intersection, lane)
    return signalGroupsForSignals(intersection, requestSignalsForRoute(lane, "!ALL!"))
end

local function hasRequestOnRouteGroups(intersection, lane, route, signalGroupNames)
    local requestGroupNames = signalGroupsForSignals(intersection, requestSignalsForRoute(lane, route))
    local requestGroupSet = {}
    for _, name in ipairs(requestGroupNames) do requestGroupSet[name] = true end
    for _, name in ipairs(signalGroupNames) do
        if requestGroupSet[name] then return true end
    end
    return false
end

local function routeRulesForLane(intersection, lane)
    local rulesByKey = {}
    for route, routeRules in pairs(lane.routeDriveRules or {}) do
        for mode, signals in pairs(routeRules) do
            local signalGroupNames = signalGroupsForSignals(intersection, signals)
            if #signalGroupNames > 0 then
                local showRequests = hasRequestOnRouteGroups(intersection, lane, route, signalGroupNames)
                local key = mode .. "|" .. table.concat(signalGroupNames, ",") .. "|" .. tostring(showRequests)
                rulesByKey[key] = rulesByKey[key] or {
                    routeNames = {},
                    signalGroups = signalGroupNames,
                    mode = mode,
                    showRequests = showRequests
                }
                table.insert(rulesByKey[key].routeNames, route)
            end
        end
    end

    local rules = {}
    for _, rule in pairs(rulesByKey) do
        table.sort(rule.routeNames)
        table.insert(rules, rule)
    end
    table.sort(rules, function (a, b)
        return table.concat(a.routeNames, ",") < table.concat(b.routeNames, ",")
    end)
    return rules
end
local function createPhaseDto(intersection, phase, order)
    local signalHeads = {}
    local signalGroups = {}
    for _, signalGroup in ipairs(phase.signalGroups or {}) do
        table.insert(signalGroups, signalGroup.name)
    end
    for signalHead, signalType in pairs(phase.signalHeads) do
        local signalHeadKind = signalType == "PEDESTRIAN" and "PEDESTRIAN" or "VEHICLE"
        local signalHeadName = signalHeadKind == "PEDESTRIAN" and
            signalHead.pedestrianSignalName or signalHead.vehicleSignalName
        table.insert(signalHeads, {
            signalId = signalHead.signalId,
            signalHeadKind = signalHeadKind,
            signalHeadKey = tostring(signalHead.signalId) .. ":" .. signalHeadKind,
            signalHeadName = signalHeadName,
            type = signalType,
            vehicleSignalHeadName = signalHead.vehicleSignalName,
            pedestrianSignalHeadName = signalHead.pedestrianSignalName,
            use = signalHead.use
        })
    end
    table.sort(signalHeads, function (a, b)
        if (a.signalHeadName or "") ~= (b.signalHeadName or "") then
            return (a.signalHeadName or "") < (b.signalHeadName or "")
        end
        if a.signalId ~= b.signalId then return a.signalId < b.signalId end
        return a.signalHeadKind < b.signalHeadKind
    end)

    return {
        id = intersection.name .. "-" .. phase.name,
        name = phase.name,
        order = order,
        prio = phase.prio,
        greenTimeSeconds = phase.greenTimeSeconds,
        signalGroups = signalGroups,
        signalHeads = signalHeads
    }
end

function RoadDataCollector.collectCrossings(allIntersections)
    local intersections = {}
    local intersectionLanes = {}
    local intersectionPhases = {}
    local intersectionTrafficLights = {}
    local allLanes = {}
    local laneIntersections = {}
    local lanePhases = {}

    local intersectionIdCounter = 0
    local sortedNames = {}
    for name in pairs(allIntersections) do table.insert(sortedNames, name) end
    table.sort(sortedNames, function (a, b) return a < b end)

    for _, name in ipairs(sortedNames) do
        local intersection = allIntersections[name]
        intersectionIdCounter = intersectionIdCounter + 1
        local currentPhase = intersection.getCurrentPhase and
            intersection:getCurrentPhase() or intersection.currentPhase
        local manualPhase = intersection.getManualPhase and intersection:getManualPhase() or intersection.manualPhase
        local nextPhase = intersection.getNextPhase and intersection:getNextPhase() or intersection.nextPhase
        local dto = {
            id = intersectionIdCounter,
            name = intersection.name,
            eepSaveId = intersection.eepSaveId or -1,
            scriptVariableName = optionalValueFromGetterOrField(intersection, "getScriptVariableName",
                                                                "scriptVariableName"),
            currentPhase = type(currentPhase) == "table" and currentPhase.name or currentPhase,
            manualPhase = type(manualPhase) == "table" and manualPhase.name or manualPhase,
            nextPhase = type(nextPhase) == "table" and nextPhase.name or nextPhase,
            ready = intersection.isGreenTimeFinished and intersection:isGreenTimeFinished() or intersection.ready,
            greenTimeSeconds = intersection.getGreenTimeSeconds and
                intersection:getGreenTimeSeconds() or intersection.greenTimeSeconds,
            switchInStrictOrder = intersection.switchInStrictOrder == true,
            tippStructure = intersection.tippStructure,
            staticCams = intersection.getStaticCams and intersection:getStaticCams() or intersection.staticCams,
            phases = {},
            signalGroupDefinitions = {},
            pedestrianCrossings = {}
        }
        local pedestrianCrossingsByName = {}
        for _, signalGroup in ipairs(intersection.signalGroups or {}) do
            table.insert(dto.signalGroupDefinitions, createSignalGroupDto(signalGroup))
            local pedestrianCrossings = signalGroup.getPedestrianCrossings and
                signalGroup:getPedestrianCrossings() or {}
            for _, crossing in ipairs(pedestrianCrossings) do
                local crossingEntry = pedestrianCrossingsByName[crossing:getName()]
                if not crossingEntry then
                    crossingEntry = {
                        crossing = crossing,
                        signalGroups = {}
                    }
                    pedestrianCrossingsByName[crossing:getName()] = crossingEntry
                end
                table.insert(crossingEntry.signalGroups, signalGroup.name)
            end
        end
        for _, crossingEntry in pairs(pedestrianCrossingsByName) do
            table.sort(crossingEntry.signalGroups)
            table.insert(dto.pedestrianCrossings,
                         createPedestrianCrossingDto(crossingEntry.crossing, crossingEntry.signalGroups))
        end
        table.sort(dto.pedestrianCrossings, function (a, b) return a.name < b.name end)
        table.insert(intersections, dto)

        local signalHeads = {}
        for order, phase in ipairs(intersection.getPhases and intersection:getPhases() or intersection.phases or {}) do
            table.insert(dto.phases, createPhaseDto(intersection, phase, order))
            table.insert(intersectionPhases, {
                id = intersection.name .. "-" .. phase.name,
                intersectionId = intersection.name,
                name = phase.name,
                prio = phase.prio
            })

            for lane in pairs(phase.lanes) do
                allLanes[lane] = dto.id
                laneIntersections[lane] = intersection
                lanePhases[lane] = lanePhases[lane] or {}
                table.insert(lanePhases[lane], phase.name)
            end

            for signalHead in pairs(phase.signalHeads) do signalHeads[signalHead] = true end
        end

        for signalHead in pairs(signalHeads) do
            local signalHeadDto = {
                id = signalHead.signalId,
                signalId = signalHead.signalId,
                vehicleSignalName = signalHead.vehicleSignalName,
                pedestrianSignalName = signalHead.pedestrianSignalName,
                use = signalHead.use,
                modelId = signalHead.trafficLightModel.id,
                currentIndication = signalHead.currentIndication,
                intersectionId = intersectionIdCounter,
                lightStructures = {},
                axisStructures = {}
            }

            for axisStructure in pairs(signalHead.axisStructures) do
                table.insert(signalHeadDto.axisStructures, {
                    structureName = axisStructure.structureName,
                    axisName = axisStructure.axisName,
                    positionDefault = axisStructure.positionDefault,
                    positionRed = axisStructure.positionRed,
                    positionGreen = axisStructure.positionGreen,
                    positionYellow = axisStructure.positionYellow,
                    positionPedestrian = axisStructure.positionPedestrian,
                    positionRedYellow = axisStructure.positionRedYellow
                })
            end

            local lightStructureId = 0
            for lightStructure in pairs(signalHead.lightStructures) do
                signalHeadDto.lightStructures[tostring(lightStructureId)] = {
                    structureRed = lightStructure.redStructure,
                    structureGreen = lightStructure.greenStructure,
                    structureYellow = lightStructure.yellowStructure or lightStructure.redStructure,
                    structureRequest = lightStructure.requestStructure,
                    structureHousing = lightStructure.housingStructure,
                    structureBlend = lightStructure.blendStructure
                }
                lightStructureId = lightStructureId + 1
            end

            table.insert(intersectionTrafficLights, signalHeadDto)
        end
    end

    for lane, intersectionId in pairs(allLanes) do
        local laneType
        if lane.requestType == Lane.RequestType.FUSSGAENGER then
            laneType = "PEDESTRIAN"
        elseif lane.trafficType == "TRAM" then
            laneType = "TRAM"
        else
            laneType = "NORMAL"
        end

        local currentIndication = "NONE"
        if lane.currentIndication == SignalIndication.YELLOW then
            currentIndication = "YELLOW"
        elseif lane.currentIndication == SignalIndication.RED then
            currentIndication = "RED"
        elseif lane.currentIndication == SignalIndication.REDYELLOW then
            currentIndication = "RED_YELLOW"
        elseif lane.currentIndication == SignalIndication.GREEN then
            currentIndication = "GREEN"
        elseif lane.currentIndication == SignalIndication.PEDESTRIAN then
            currentIndication = "PEDESTRIAN"
        end

        local countType = "CONTACTS"
        if lane.signalUsedForRequest then
            countType = "SIGNALS"
        elseif lane.tracksUsedForRequest then
            countType = "TRACKS"
        end

        local dto = {
            id = intersectionId .. "-" .. lane.name,
            intersectionId = intersectionId,
            name = lane.name,
            kpId = optionalValueFromGetterOrField(lane, "getKpId", "_kpId"),
            currentIndication = currentIndication,
            vehicleMultiplier = lane.fahrzeugMultiplikator,
            laneSignalId = lane.laneSignal and lane.laneSignal.signalId or nil,
            type = laneType,
            countType = countType,
            waitingTrains = {},
            waitingForGreenCyclesCount = lane.waitCount,
            approach = lane.approach,
            directions = lane.directions,
            phases = lanePhases[lane] or {},
            defaultSignalGroups = defaultSignalGroupsForLane(laneIntersections[lane], lane),
            routeRules = routeRulesForLane(laneIntersections[lane], lane),
            defaultRequestSignalGroups = defaultRequestSignalGroupsForLane(laneIntersections[lane], lane),
            requestTrackIds = sortedNumberKeys(lane.tracksForRequests),
            highlightTrackIds = sortedNumberValues(lane.tracksForHighlighting),
            tracks = lane.tracksForHighlighting or {}
        }
        for i, value in pairs(lane.queue:elements()) do dto.waitingTrains[i] = value end
        table.insert(intersectionLanes, dto)
    end

    table.sort(intersectionLanes, function (a, b)
        return tostring(a.name):gsub("%.?%d+", padnum) .. ("%3d"):format(#b.name) <
            tostring(b.name):gsub("%.?%d+", padnum) .. ("%3d"):format(#a.name)
    end)

    return {
        intersections = intersections,
        intersectionLanes = intersectionLanes,
        intersectionPhases = intersectionPhases,
        intersectionTrafficLights = intersectionTrafficLights
    }
end

function RoadDataCollector.collectModuleSettings()
    return {
        {
            category = "Tipp-Texte für Signale (allgemein)",
            name = "Signal-ID",
            description = "Zeigt an jedem Signal dessen Nummer als TippText",
            type = "boolean",
            value = IntersectionSettings.showSignalIdOnSignal,
            eepFunction = "IntersectionSettings.setShowSignalIdOnSignal"
        },
        {
            category = "Tipp-Texte für Signale (allgemein)",
            name = "Modellinformation",
            description = "Zeigt das Signalgebermodell und seine Signalbilder",
            type = "boolean",
            value = IntersectionSettings.showModelInfoOnSignal,
            eepFunction = "IntersectionSettings.setShowModelInfoOnSignal"
        },
        {
            category = "Tipp-Texte für Ampeln",
            name = "Fahrspursignale einblenden",
            description = "Zeigt an Fahrspur-Signalen Kurzname, Farbe und Fahrspurname",
            type = "boolean",
            value = IntersectionSettings.showLaneNamesOnSignal,
            eepFunction = "IntersectionSettings.setShowLaneNamesOnSignal"
        },
        {
            category = "Tipp-Texte für Ampeln",
            name = "Kurzname und Farbe",
            description = "Zeigt den farbigen Signalnamen an Ampeln und Immobilienampel-Gehaeusen",
            type = "boolean",
            value = IntersectionSettings.showNameAndPhaseOnSignal,
            eepFunction = "IntersectionSettings.setShowNameAndPhaseOnSignal"
        },
        {
            category = "Tipp-Texte für Ampeln",
            name = "Wartende Fahrzeuge",
            description = "Fahrspur-Signale zeigen wartende Fahrzeuge",
            type = "boolean",
            value = IntersectionSettings.showRequestsOnSignal,
            eepFunction = "IntersectionSettings.setShowRequestsOnSignal"
        },
        {
            category = "Tipp-Texte für Ampeln",
            name = "Phasen",
            description = "Zeige die aktuelle Phase dieses Signalgebers",
            type = "boolean",
            value = IntersectionSettings.showPhaseOnSignal,
            eepFunction = "IntersectionSettings.setShowPhaseOnSignal"
        },
        {
            category = "Tipp-Texte für Kreuzungen",
            name = "Kreuzungsübersicht einblenden",
            description = "Zeigt Phasen und markiert die aktuelle Phase",
            type = "boolean",
            value = IntersectionSettings.showLanesOnStructure,
            eepFunction = "IntersectionSettings.setShowLanesOnStructure"
        }
    }
end

return RoadDataCollector
