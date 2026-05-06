if CeDebugLoad then print("[#Start] Loading ce.mods.road.data.RoadDataCollector ...") end
local IntersectionSettings = require("ce.mods.road.IntersectionSettings")
local Lane = require("ce.mods.road.Lane")
local TrafficLightState = require("ce.mods.road.TrafficLightState")

local RoadDataCollector = {}

local function padnum(d)
    local dec, n = string.match(d, "(%.?)0*(.+)")
    return #dec > 0 and ("%.12f"):format(d) or ("%s%03d%s"):format(dec, #n, n)
end

local function createPhaseDto(crossing, sequence, order)
    local trafficLights = {}
    for trafficLight, type in pairs(sequence.trafficLights) do
        local signalKind = type == "PEDESTRIAN" and "PEDESTRIAN" or "TRAFFIC"
        local signalName = signalKind == "PEDESTRIAN" and trafficLight.pedestrianSignalName or
            trafficLight.trafficSignalName
        table.insert(trafficLights, {
            signalId = trafficLight.signalId,
            signalKind = signalKind,
            signalKey = tostring(trafficLight.signalId) .. ":" .. signalKind,
            signalName = signalName,
            type = type,
            trafficSignalName = trafficLight.trafficSignalName,
            pedestrianSignalName = trafficLight.pedestrianSignalName,
            use = trafficLight.use
        })
    end
    table.sort(trafficLights, function (a, b)
        if (a.signalName or "") ~= (b.signalName or "") then return (a.signalName or "") < (b.signalName or "") end
        if a.signalId ~= b.signalId then return a.signalId < b.signalId end
        return a.signalKind < b.signalKind
    end)

    return {
        id = crossing.name .. "-" .. sequence.name,
        name = sequence.name,
        order = order,
        prio = sequence.prio,
        greenPhaseSeconds = sequence.greenPhaseSeconds,
        trafficLights = trafficLights
    }
end

function RoadDataCollector.collectCrossings(allCrossings)
    local intersections = {}
    local intersectionLanes = {}
    local intersectionSwitchings = {}
    local intersectionTrafficLights = {}
    local allLanes = {}
    local laneSwitchings = {}

    local intersectionIdCounter = 0
    local sortedNames = {}
    for name in pairs(allCrossings) do table.insert(sortedNames, name) end
    table.sort(sortedNames, function (a, b) return a < b end)

    for _, name in ipairs(sortedNames) do
        local crossing = allCrossings[name]
        intersectionIdCounter = intersectionIdCounter + 1
        local intersection = {
            id = intersectionIdCounter,
            name = crossing.name,
            currentSwitching = crossing:getCurrentSequence() and crossing:getCurrentSequence().name or nil,
            manualSwitching = crossing:getManualSequence() and crossing:getManualSequence().name or nil,
            nextSwitching = crossing:getNextSequence() and crossing:getNextSequence().name or nil,
            ready = crossing:isGreenPhaseFinished(),
            timeForGreen = crossing:getGreenPhaseSeconds(),
            staticCams = crossing:getStaticCams(),
            phases = {}
        }
        table.insert(intersections, intersection)

        local trafficLights = {}
        for order, switching in ipairs(crossing:getSequences()) do
            table.insert(intersection.phases, createPhaseDto(crossing, switching, order))
            table.insert(intersectionSwitchings, {
                id = crossing.name .. "-" .. switching.name,
                intersectionId = crossing.name,
                name = switching.name,
                prio = switching.prio
            })

            for lane in pairs(switching.lanes) do
                allLanes[lane] = intersection.id
                laneSwitchings[lane] = laneSwitchings[lane] or {}
                table.insert(laneSwitchings[lane], switching.name)
            end

            for trafficLight in pairs(switching.trafficLights) do trafficLights[trafficLight] = true end
        end

        for tl in pairs(trafficLights) do
            local trafficLight = {
                id = tl.signalId,
                signalId = tl.signalId,
                trafficSignalName = tl.trafficSignalName,
                pedestrianSignalName = tl.pedestrianSignalName,
                use = tl.use,
                modelId = tl.trafficLightModel.name,
                currentPhase = tl.phase,
                intersectionId = intersectionIdCounter,
                lightStructures = {},
                axisStructures = {}
            }

            for axisStructure in pairs(tl.axisStructures) do
                table.insert(trafficLight.axisStructures, {
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
            for lightStructure in pairs(tl.lightStructures) do
                trafficLight.lightStructures[tostring(lightStructureId)] = {
                    structureRed = lightStructure.redStructure,
                    structureGreen = lightStructure.greenStructure,
                    structureYellow = lightStructure.yellowStructure or lightStructure.redStructure,
                    structureRequest = lightStructure.requestStructure
                }
                lightStructureId = lightStructureId + 1
            end

            table.insert(intersectionTrafficLights, trafficLight)
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

        local phase = "NONE"
        if lane.phase == TrafficLightState.YELLOW then
            phase = "YELLOW"
        elseif lane.phase == TrafficLightState.RED then
            phase = "RED"
        elseif lane.phase == TrafficLightState.REDYELLOW then
            phase = "RED_YELLOW"
        elseif lane.phase == TrafficLightState.GREEN then
            phase = "GREEN"
        elseif lane.phase == TrafficLightState.PEDESTRIAN then
            phase = "PEDESTRIAN"
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
            phase = phase,
            vehicleMultiplier = lane.fahrzeugMultiplikator,
            eepSaveId = lane.eepSaveId,
            type = laneType,
            countType = countType,
            waitingTrains = {},
            waitingForGreenCyclesCount = lane.waitCount,
            directions = lane.directions,
            switchings = laneSwitchings[lane] or {},
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
        intersectionSwitchings = intersectionSwitchings,
        intersectionTrafficLights = intersectionTrafficLights
    }
end

function RoadDataCollector.collectModuleSettings()
    return {
        {
            category = "Tipp-Texte für Ampeln",
            name = "Wartende Fahrzeuge",
            description = "Jede Ampel zeigt die wartenden Fahrzeuge",
            type = "boolean",
            value = IntersectionSettings.showRequestsOnSignal,
            eepFunction = "IntersectionSettings.setShowRequestsOnSignal"
        },
        {
            category = "Tipp-Texte für Ampeln",
            name = "Modellinformation",
            description = "Zeigt das Ampelmodell und seine Schaltungen",
            type = "boolean",
            value = IntersectionSettings.showModelInfoOnSignal,
            eepFunction = "IntersectionSettings.setShowModelInfoOnSignal"
        },
        {
            category = "Tipp-Texte für Ampeln",
            name = "Kurzname und Farbe",
            description = "Zeigt den farbigen Ampelnamen und die aktuelle Farbe",
            type = "boolean",
            value = IntersectionSettings.showNameAndSequenceOnSignal,
            eepFunction = "IntersectionSettings.setShowNameAndSequenceOnSignal"
        },
        {
            category = "Tipp-Texte für Ampeln",
            name = "Phasen",
            description = "Zeige die aktuelle Schaltung dieser Ampel in den Ampelphasen",
            type = "boolean",
            value = IntersectionSettings.showSequenceOnSignal,
            eepFunction = "IntersectionSettings.setShowSequenceOnSignal"
        },
        {
            category = "Tipp-Texte für Kreuzungen",
            name = "Kreuzungsübersicht einblenden",
            description = "Zeigt Fahrspuren und deren Schaltung",
            type = "boolean",
            value = IntersectionSettings.showLanesOnStructure,
            eepFunction = "IntersectionSettings.setShowLanesOnStructure"
        },
        {
            category = "Tipp-Texte für Signale (allgemein)",
            name = "Signal-ID einblenden",
            description = "Zeigt an jedem Signal dessen Nummer als TippText",
            type = "boolean",
            value = IntersectionSettings.showSignalIdOnSignal,
            eepFunction = "IntersectionSettings.setShowSignalIdOnSignal"
        }
    }
end

return RoadDataCollector
