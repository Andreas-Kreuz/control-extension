-- TypeScript LuaDtos: apps/web-server/src/server/ce/dto/roads/
--   IntersectionLuaDto, IntersectionLaneLuaDto, IntersectionPhaseLuaDto, IntersectionTrafficLightLuaDto
if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadDtoFactory ...") end

local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local RoadCeTypes = require("ce.mods.road.data.RoadCeTypes")

---@class RoadDtoFactory
---@field createIntersectionDto fun(intersection: table, isSelected?: boolean):string,string,string|number,IntersectionDto
---@field createIntersectionDtoList fun(intersections: table, isSelectedByValue?: fun(value: table): boolean):string,string,table
---@field createIntersectionLaneDto fun(lane: table, isSelected?: boolean):string,string,string|number,IntersectionLaneDto
---@field createIntersectionLaneDtoList fun(lanes: table, isSelectedByValue?: fun(value: table): boolean):string,string,table
---@field createIntersectionPhaseDto fun(phase: table, isSelected?: boolean):string,string,string|number,IntersectionPhaseDto
---@field createIntersectionPhaseDtoList fun(phases: table, isSelectedByValue?: fun(value: table): boolean):string,string,table
---@field createIntersectionTrafficLightDto fun(trafficLight: table, isSelected?: boolean):string,string,string|number,IntersectionTrafficLightDto
---@field createIntersectionTrafficLightDtoList fun(signals: table, isSelectedByValue?: fun(value: table): boolean):string,string,table
---@field createIntersectionModuleSettingDto fun(setting: table, isSelected?: boolean):string,string,string|number,IntersectionModuleSettingDto
---@field createIntersectionModuleSettingDtoList fun(settings: table, isSelectedByValue?: fun(value: table): boolean):string,string,table
---@field createCrossingDtos fun(allIntersections: table):table
---@field createModuleSettings fun():table
local RoadDtoFactory = {}

local SignalIndication = require("ce.mods.road.SignalIndication")


local function padnum(d)
    local dec, n = string.match(d, "(%.?)0*(.+)")
    return #dec > 0 and ("%.12f"):format(d) or ("%s%03d%s"):format(dec, #n, n)
end

local function optionalValueFromGetterOrField(value, getterName, fieldName)
    if value and type(value[getterName]) == "function" then return value[getterName](value) end
    return value and value[fieldName] or nil
end

local function signalGroupReference(signalGroup)
    return optionalValueFromGetterOrField(signalGroup, "getScriptVariableName", "_scriptVariableName") or
        signalGroup.name
end

local function signalHeadLogicalUses(signalHead)
    local groupsByUse = signalHead.getSignalGroupsByUse and signalHead:getSignalGroupsByUse() or
        signalHead.signalGroupsByUse or {}
    return {
        VEHICLE = groupsByUse.VEHICLE ~= nil,
        PEDESTRIAN = groupsByUse.PEDESTRIAN ~= nil
    }
end

local function signalHeadUse(signalHead)
    local logicalUses = signalHeadLogicalUses(signalHead)
    if logicalUses.VEHICLE and logicalUses.PEDESTRIAN then return "VEHICLE_AND_PEDESTRIAN" end
    if logicalUses.PEDESTRIAN then return "PEDESTRIAN_ONLY" end
    return signalHead.use
end

local function signalHeadVehicleSignalName(signalHead, use)
    if use == "PEDESTRIAN_ONLY" then return nil end
    return signalHead.vehicleSignalName
end

local function signalHeadPedestrianSignalName(signalHead, use)
    if use == "PEDESTRIAN_ONLY" then return signalHead.pedestrianSignalName or signalHead.vehicleSignalName end
    return signalHead.pedestrianSignalName
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
        if hasMatchingSignal then table.insert(signalGroupNames, signalGroupReference(signalGroup)) end
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
        if hasMatchingSignal then table.insert(signalGroupNames, signalGroupReference(signalGroup)) end
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
        table.insert(signalGroups, signalGroupReference(signalGroup))
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

local function collectCrossingDtos(allIntersections)
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
                table.insert(crossingEntry.signalGroups, signalGroupReference(signalGroup))
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
            local use = signalHeadUse(signalHead)
            local signalHeadDto = {
                id = signalHead.signalId,
                signalId = signalHead.signalId,
                vehicleSignalName = signalHeadVehicleSignalName(signalHead, use),
                pedestrianSignalName = signalHeadPedestrianSignalName(signalHead, use),
                use = use,
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
        if lane.requestType == "FUSSGAENGER" then
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

local function moduleSettings()
    local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
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


local function getFieldPublishPolicies(ceTypeKey)
    return require("ce.mods.road.options.RoadOptionsRegistry").getFieldPublishPolicies(ceTypeKey)
end

local function copyTable(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[key] = value end
    return copy
end

local function copyPhases(phases)
    local copy = {}
    for key, phase in pairs(phases or {}) do
        local signalHeads = {}
        for tlKey, signalHead in pairs(phase.signalHeads or {}) do
            signalHeads[tlKey] = {
                signalId = signalHead.signalId,
                signalHeadKind = signalHead.signalHeadKind,
                signalHeadKey = signalHead.signalHeadKey,
                signalHeadName = signalHead.signalHeadName,
                type = signalHead.type,
                vehicleSignalHeadName = signalHead.vehicleSignalHeadName,
                pedestrianSignalHeadName = signalHead.pedestrianSignalHeadName,
                use = signalHead.use
            }
        end
        copy[key] = {
            id = phase.id,
            name = phase.name,
            order = phase.order,
            prio = phase.prio,
            greenTimeSeconds = phase.greenTimeSeconds,
            signalGroups = copyTable(phase.signalGroups),
            signalHeads = signalHeads
        }
    end
    return copy
end

local function copySignalGroupDefinitions(signalGroupDefinitions)
    local copy = {}
    for key, signalGroup in pairs(signalGroupDefinitions or {}) do
        copy[key] = {
            name = signalGroup.name,
            scriptVariableName = signalGroup.scriptVariableName,
            approach = signalGroup.approach,
            turnDirections = copyTable(signalGroup.turnDirections),
            trafficType = signalGroup.trafficType,
            signalIds = copyTable(signalGroup.signalIds),
            pedestrianCrossingNames = copyTable(signalGroup.pedestrianCrossingNames)
        }
    end
    return copy
end

local function copyPedestrianCrossings(pedestrianCrossings)
    local copy = {}
    for key, crossing in pairs(pedestrianCrossings or {}) do
        copy[key] = {
            name = crossing.name,
            scriptVariableName = crossing.scriptVariableName,
            approach = crossing.approach,
            signalGroups = copyTable(crossing.signalGroups)
        }
    end
    return copy
end

local function copyLaneRouteRules(routeRules)
    local copy = {}
    for key, routeRule in pairs(routeRules or {}) do
        copy[key] = {
            routeNames = copyTable(routeRule.routeNames),
            signalGroups = copyTable(routeRule.signalGroups),
            mode = routeRule.mode,
            showRequests = routeRule.showRequests == true
        }
    end
    return copy
end

local function toIntersectionDto(intersection, isSelected)
    local fieldPolicies        = getFieldPublishPolicies("intersections")
    local dto                  = {
        ceType = RoadCeTypes.Intersection,
        id = intersection.id,
    }
    dto.name                   = SyncPolicy.shouldPublishField(fieldPolicies, "name", isSelected) and intersection.name or
        ""
    dto.eepSaveId              = SyncPolicy.shouldPublishField(fieldPolicies, "eepSaveId", isSelected) and
        intersection.eepSaveId or -1
    dto.scriptVariableName     = SyncPolicy.shouldPublishField(fieldPolicies, "scriptVariableName", isSelected) and
        intersection.scriptVariableName or nil
    dto.currentPhase           = SyncPolicy.shouldPublishField(fieldPolicies, "currentPhase", isSelected) and
        intersection.currentPhase or ""
    dto.manualPhase            = SyncPolicy.shouldPublishField(fieldPolicies, "manualPhase", isSelected) and
        intersection.manualPhase or ""
    dto.nextPhase              = SyncPolicy.shouldPublishField(fieldPolicies, "nextPhase", isSelected) and
        intersection.nextPhase or ""
    dto.greenTimeSeconds       = SyncPolicy.shouldPublishField(fieldPolicies, "greenTimeSeconds", isSelected) and
        intersection.greenTimeSeconds or 0
    dto.switchInStrictOrder    = SyncPolicy.shouldPublishField(fieldPolicies, "switchInStrictOrder", isSelected) and
        intersection.switchInStrictOrder or false
    dto.tippStructure          = SyncPolicy.shouldPublishField(fieldPolicies, "tippStructure", isSelected) and
        intersection.tippStructure or nil
    dto.staticCams             = SyncPolicy.shouldPublishField(fieldPolicies, "staticCams", isSelected) and
        copyTable(intersection.staticCams) or {}
    dto.phases                 = SyncPolicy.shouldPublishField(fieldPolicies, "phases", isSelected) and
        copyPhases(intersection.phases) or {}
    dto.signalGroupDefinitions = SyncPolicy.shouldPublishField(fieldPolicies, "signalGroupDefinitions", isSelected) and
        copySignalGroupDefinitions(intersection.signalGroupDefinitions) or {}
    dto.pedestrianCrossings    = SyncPolicy.shouldPublishField(fieldPolicies, "pedestrianCrossings", isSelected) and
        copyPedestrianCrossings(intersection.pedestrianCrossings) or {}
    if SyncPolicy.shouldPublishField(fieldPolicies, "ready", isSelected) then
        dto.ready = intersection.ready
    else
        dto.ready = false
    end
    return dto
end

local function toIntersectionLaneDto(lane, isSelected)
    local fieldPolicies            = getFieldPublishPolicies("intersectionLanes")
    local dto                      = {
        ceType = RoadCeTypes.IntersectionLane,
        id = lane.id,
    }
    dto.intersectionId             = SyncPolicy.shouldPublishField(fieldPolicies, "intersectionId", isSelected) and
        lane.intersectionId or 0
    dto.name                       = SyncPolicy.shouldPublishField(fieldPolicies, "name", isSelected) and
        lane.name or ""
    dto.kpId                       = lane.kpId or nil
    dto.scriptVariableName         = SyncPolicy.shouldPublishField(fieldPolicies, "scriptVariableName", isSelected) and
        lane.kpId or nil
    dto.currentIndication          = SyncPolicy.shouldPublishField(fieldPolicies, "currentIndication", isSelected) and
        lane.currentIndication or
        ""
    dto.vehicleMultiplier          = SyncPolicy.shouldPublishField(fieldPolicies, "vehicleMultiplier", isSelected) and
        lane.vehicleMultiplier or 0
    dto.laneSignalId               = SyncPolicy.shouldPublishField(fieldPolicies, "laneSignalId", isSelected) and
        lane.laneSignalId or nil
    dto.type                       = SyncPolicy.shouldPublishField(fieldPolicies, "type", isSelected) and
        lane.type or ""
    dto.countType                  = SyncPolicy.shouldPublishField(fieldPolicies, "countType", isSelected) and
        lane.countType or ""
    dto.waitingTrains              = SyncPolicy.shouldPublishField(fieldPolicies, "waitingTrains", isSelected) and
        copyTable(lane.waitingTrains) or {}
    dto.waitingForGreenCyclesCount = SyncPolicy.shouldPublishField(fieldPolicies, "waitingForGreenCyclesCount",
                                                                   isSelected) and lane.waitingForGreenCyclesCount or 0
    dto.approach                   = SyncPolicy.shouldPublishField(fieldPolicies, "approach", isSelected) and
        lane.approach or nil
    dto.directions                 = SyncPolicy.shouldPublishField(fieldPolicies, "directions", isSelected) and
        copyTable(lane.directions) or {}
    dto.phases                     = SyncPolicy.shouldPublishField(fieldPolicies, "phases", isSelected) and
        copyTable(lane.phases) or {}
    dto.defaultSignalGroups        = SyncPolicy.shouldPublishField(fieldPolicies, "defaultSignalGroups", isSelected) and
        copyTable(lane.defaultSignalGroups) or {}
    dto.routeRules                 = SyncPolicy.shouldPublishField(fieldPolicies, "routeRules", isSelected) and
        copyLaneRouteRules(lane.routeRules) or {}
    dto.defaultRequestSignalGroups = SyncPolicy.shouldPublishField(fieldPolicies, "defaultRequestSignalGroups",
                                                                   isSelected) and
        copyTable(lane.defaultRequestSignalGroups) or {}
    dto.requestTrackIds            = SyncPolicy.shouldPublishField(fieldPolicies, "requestTrackIds", isSelected) and
        copyTable(lane.requestTrackIds) or {}
    dto.highlightTrackIds          = SyncPolicy.shouldPublishField(fieldPolicies, "highlightTrackIds", isSelected) and
        copyTable(lane.highlightTrackIds) or {}
    dto.tracks                     = SyncPolicy.shouldPublishField(fieldPolicies, "tracks", isSelected) and
        copyTable(lane.tracks) or {}
    return dto
end

local function toIntersectionPhaseDto(phase, isSelected)
    local fieldPolicies = getFieldPublishPolicies("intersectionPhases")
    local dto           = {
        ceType = RoadCeTypes.IntersectionPhase,
        id = phase.id,
    }
    dto.intersectionId  = SyncPolicy.shouldPublishField(fieldPolicies, "intersectionId", isSelected) and
        phase.intersectionId or ""
    dto.name            = SyncPolicy.shouldPublishField(fieldPolicies, "name", isSelected) and phase.name or ""
    dto.prio            = SyncPolicy.shouldPublishField(fieldPolicies, "prio", isSelected) and phase.prio or 0
    return dto
end

local function toIntersectionTrafficLightStructureDto(lightStructure)
    return {
        structureRed = lightStructure.structureRed,
        structureGreen = lightStructure.structureGreen,
        structureYellow = lightStructure.structureYellow,
        structureRequest = lightStructure.structureRequest,
        structureHousing = lightStructure.structureHousing,
        structureBlend = lightStructure.structureBlend
    }
end

local function toIntersectionTrafficLightAxisStructureDto(axisStructure)
    return {
        structureName = axisStructure.structureName,
        axisName = axisStructure.axisName,
        positionDefault = axisStructure.positionDefault,
        positionRed = axisStructure.positionRed,
        positionGreen = axisStructure.positionGreen,
        positionYellow = axisStructure.positionYellow,
        positionPedestrian = axisStructure.positionPedestrian,
        positionRedYellow = axisStructure.positionRedYellow
    }
end

local function toIntersectionTrafficLightDto(signal, isSelected)
    local fieldPolicies      = getFieldPublishPolicies("intersectionTrafficLights")
    local dto                = {
        ceType = RoadCeTypes.IntersectionTrafficLight,
        id = signal.id,
    }
    dto.signalId             = SyncPolicy.shouldPublishField(fieldPolicies, "signalId", isSelected) and
        signal.signalId or 0
    dto.vehicleSignalName    = SyncPolicy.shouldPublishField(fieldPolicies, "vehicleSignalName", isSelected) and
        signal.vehicleSignalName or ""
    dto.pedestrianSignalName = SyncPolicy.shouldPublishField(fieldPolicies, "pedestrianSignalName", isSelected) and
        signal.pedestrianSignalName or ""
    dto.use                  = SyncPolicy.shouldPublishField(fieldPolicies, "use", isSelected) and
        signal.use or ""
    dto.modelId              = SyncPolicy.shouldPublishField(fieldPolicies, "modelId", isSelected) and
        signal.modelId or ""
    dto.currentIndication    = SyncPolicy.shouldPublishField(fieldPolicies, "currentIndication", isSelected) and
        signal.currentIndication or ""
    dto.intersectionId       = SyncPolicy.shouldPublishField(fieldPolicies, "intersectionId", isSelected) and
        signal.intersectionId or 0
    if SyncPolicy.shouldPublishField(fieldPolicies, "lightStructures", isSelected) then
        local lightStructures = {}
        for key, lightStructure in pairs(signal.lightStructures or {}) do
            lightStructures[key] = toIntersectionTrafficLightStructureDto(lightStructure)
        end
        dto.lightStructures = lightStructures
    else
        dto.lightStructures = {}
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "axisStructures", isSelected) then
        local axisStructures = {}
        for key, axisStructure in pairs(signal.axisStructures or {}) do
            axisStructures[key] = toIntersectionTrafficLightAxisStructureDto(axisStructure)
        end
        dto.axisStructures = axisStructures
    else
        dto.axisStructures = {}
    end
    return dto
end

local function toIntersectionModuleSettingDto(setting, isSelected)
    local fieldPolicies = getFieldPublishPolicies("moduleSettings")
    local dto           = {
        ceType = RoadCeTypes.ModuleSetting,
        name = setting.name,
    }
    dto.category        = SyncPolicy.shouldPublishField(fieldPolicies, "category", isSelected) and
        setting.category or ""
    dto.description     = SyncPolicy.shouldPublishField(fieldPolicies, "description", isSelected) and setting
        .description or ""
    dto.eepFunction     = SyncPolicy.shouldPublishField(fieldPolicies, "eepFunction", isSelected) and setting
        .eepFunction or ""
    dto.type            = SyncPolicy.shouldPublishField(fieldPolicies, "type", isSelected) and setting.type or ""
    if SyncPolicy.shouldPublishField(fieldPolicies, "value", isSelected) then
        dto.value = setting.value
    else
        dto.value = false
    end
    return dto
end

local function createDto(ceType, keyId, value, toDto, isSelected)
    local dto = toDto(value, isSelected == true)
    return ceType, keyId, dto[keyId], dto
end

local function createDtoList(ceType, keyId, values, createSingleDto, isSelectedByValue)
    local dtos = {}
    for key, value in pairs(values) do
        local _, _, _, dto = createSingleDto(value, isSelectedByValue and isSelectedByValue(value) or false)
        dtos[key] = dto
    end
    return ceType, keyId, dtos
end

function RoadDtoFactory.createIntersectionDto(intersection, isSelected)
    return createDto(RoadCeTypes.Intersection, "id", intersection, toIntersectionDto, isSelected)
end

function RoadDtoFactory.createIntersectionDtoList(intersections, isSelectedByValue)
    return createDtoList(RoadCeTypes.Intersection, "id", intersections, RoadDtoFactory.createIntersectionDto,
                         isSelectedByValue)
end

function RoadDtoFactory.createIntersectionLaneDto(lane, isSelected)
    return createDto(RoadCeTypes.IntersectionLane, "id", lane, toIntersectionLaneDto, isSelected)
end

function RoadDtoFactory.createIntersectionLaneDtoList(lanes, isSelectedByValue)
    return createDtoList(RoadCeTypes.IntersectionLane, "id", lanes, RoadDtoFactory.createIntersectionLaneDto,
                         isSelectedByValue)
end

function RoadDtoFactory.createIntersectionPhaseDto(phase, isSelected)
    return createDto(RoadCeTypes.IntersectionPhase, "id", phase, toIntersectionPhaseDto, isSelected)
end

function RoadDtoFactory.createIntersectionPhaseDtoList(phases, isSelectedByValue)
    return createDtoList(RoadCeTypes.IntersectionPhase, "id", phases,
                         RoadDtoFactory.createIntersectionPhaseDto, isSelectedByValue)
end

function RoadDtoFactory.createIntersectionTrafficLightDto(signal, isSelected)
    return createDto(RoadCeTypes.IntersectionTrafficLight, "id", signal, toIntersectionTrafficLightDto,
                     isSelected)
end

function RoadDtoFactory.createIntersectionTrafficLightDtoList(signals, isSelectedByValue)
    return createDtoList(RoadCeTypes.IntersectionTrafficLight, "id", signals,
                         RoadDtoFactory.createIntersectionTrafficLightDto, isSelectedByValue)
end

function RoadDtoFactory.createIntersectionModuleSettingDto(setting, isSelected)
    return createDto(RoadCeTypes.ModuleSetting, "name", setting, toIntersectionModuleSettingDto, isSelected)
end

function RoadDtoFactory.createIntersectionModuleSettingDtoList(settings, isSelectedByValue)
    return createDtoList(RoadCeTypes.ModuleSetting, "name", settings,
                         RoadDtoFactory.createIntersectionModuleSettingDto, isSelectedByValue)
end

function RoadDtoFactory.createCrossingDtos(allIntersections)
    return collectCrossingDtos(allIntersections)
end

function RoadDtoFactory.createModuleSettings()
    return moduleSettings()
end

return RoadDtoFactory