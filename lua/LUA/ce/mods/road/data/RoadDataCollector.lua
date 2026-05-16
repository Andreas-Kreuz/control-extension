if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadDataCollector ...") end
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
local Lane = require("ce.mods.road.Lane")
local SignalIndication = require("ce.mods.road.SignalIndication")

local RoadDataCollector = {}

local function padnum(d)
    local dec, n = string.match(d, "(%.?)0*(.+)")
    return #dec > 0 and ("%.12f"):format(d) or ("%s%03d%s"):format(dec, #n, n)
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
            currentPhase = type(currentPhase) == "table" and currentPhase.name or currentPhase,
            manualPhase = type(manualPhase) == "table" and manualPhase.name or manualPhase,
            nextPhase = type(nextPhase) == "table" and nextPhase.name or nextPhase,
            ready = intersection.isGreenTimeFinished and intersection:isGreenTimeFinished() or intersection.ready,
            greenTimeSeconds = intersection.getGreenTimeSeconds and
                intersection:getGreenTimeSeconds() or intersection.greenTimeSeconds,
            staticCams = intersection.getStaticCams and intersection:getStaticCams() or intersection.staticCams,
            phases = {}
        }
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
                modelId = signalHead.trafficLightModel.name,
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
                    structureRequest = lightStructure.requestStructure
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
            currentIndication = currentIndication,
            vehicleMultiplier = lane.fahrzeugMultiplikator,
            eepSaveId = lane.eepSaveId,
            type = laneType,
            countType = countType,
            waitingTrains = {},
            waitingForGreenCyclesCount = lane.waitCount,
            directions = lane.directions,
            phases = lanePhases[lane] or {},
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
            category = "Tipp-Texte fuer Signalgeber",
            name = "Wartende Fahrzeuge",
            description = "Jeder Signalgeber zeigt die wartenden Fahrzeuge",
            type = "boolean",
            value = IntersectionSettings.showRequestsOnSignal,
            eepFunction = "IntersectionSettings.setShowRequestsOnSignal"
        },
        {
            category = "Tipp-Texte fuer Signalgeber",
            name = "Modellinformation",
            description = "Zeigt das Signalgebermodell und seine Signalbilder",
            type = "boolean",
            value = IntersectionSettings.showModelInfoOnSignal,
            eepFunction = "IntersectionSettings.setShowModelInfoOnSignal"
        },
        {
            category = "Tipp-Texte fuer Signalgeber",
            name = "Kurzname und Farbe",
            description = "Zeigt den farbigen Signalnamen und das aktuelle Signalbild",
            type = "boolean",
            value = IntersectionSettings.showNameAndPhaseOnSignal,
            eepFunction = "IntersectionSettings.setShowNameAndPhaseOnSignal"
        },
        {
            category = "Tipp-Texte fuer Signalgeber",
            name = "Phasen",
            description = "Zeige die aktuelle Phase dieses Signalgebers",
            type = "boolean",
            value = IntersectionSettings.showPhaseOnSignal,
            eepFunction = "IntersectionSettings.setShowPhaseOnSignal"
        },
        {
            category = "Tipp-Texte fuer Kreuzungen",
            name = "Kreuzungsuebersicht einblenden",
            description = "Zeigt Fahrspuren und deren Phase",
            type = "boolean",
            value = IntersectionSettings.showLanesOnStructure,
            eepFunction = "IntersectionSettings.setShowLanesOnStructure"
        },
        {
            category = "Tipp-Texte fuer Signale (allgemein)",
            name = "Signal-ID einblenden",
            description = "Zeigt an jedem Signal dessen Nummer als TippText",
            type = "boolean",
            value = IntersectionSettings.showSignalIdOnSignal,
            eepFunction = "IntersectionSettings.setShowSignalIdOnSignal"
        }
    }
end

return RoadDataCollector
