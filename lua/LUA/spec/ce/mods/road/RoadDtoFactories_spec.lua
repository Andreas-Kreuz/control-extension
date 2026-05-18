insulate("ce.mods.road.RoadDtoFactories", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.mods.road.data.RoadDtoFactory")
        clearModule("ce.mods.road.data.TrafficLightModelDtoFactory")
    end)

    it("provides metadata for road DTO lists", function ()
        local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")
        local TrafficLightModelDtoFactory = require("ce.mods.road.data.TrafficLightModelDtoFactory")

        local intersection = {
            id = 1,
            name = "A",
            eepSaveId = 77,
            scriptVariableName = "c1",
            currentPhase = "P1",
            manualPhase = "P2",
            nextPhase = "P3",
            ready = true,
            greenTimeSeconds = 15,
            staticCams = { "Cam 1" },
            phases = {
                {
                    id = "A-P1",
                    name = "P1",
                    order = 1,
                    prio = 2,
                    greenTimeSeconds = 15,
                    signalGroups = { "sgLane1Straight" },
                    signalHeads = {
                        {
                            signalId = 1,
                            signalHeadKind = "VEHICLE",
                            signalHeadKey = "1:VEHICLE",
                            signalHeadName = "K1",
                            type = "CAR",
                            vehicleSignalHeadName = "K1",
                            use = "VEHICLE_ONLY"
                        },
                        {
                            signalId = 3,
                            signalHeadKind = "PEDESTRIAN",
                            signalHeadKey = "3:PEDESTRIAN",
                            signalHeadName = "F1",
                            type = "PEDESTRIAN",
                            pedestrianSignalHeadName = "F1",
                            use = "PEDESTRIAN_ONLY"
                        }
                    }
                }
            },
            hidden = true
        }
        local lane = {
            id = "1-L1",
            intersectionId = 1,
            name = "L1",
            currentIndication = "GREEN",
            vehicleMultiplier = 2,
            type = "NORMAL",
            countType = "TRACKS",
            waitingTrains = { "T1" },
            waitingForGreenCyclesCount = 4,
            approach = "SOUTH",
            directions = { "LEFT" },
            phases = { "P1" },
            defaultRequestSignalGroups = { "sgLane1Straight" },
            requestTrackIds = { 11, 12 },
            highlightTrackIds = { 10 },
            tracks = { 10 },
            hidden = true
        }
        local phase = { id = "A-P1", intersectionId = "A", name = "P1", prio = 1, hidden = true }
        local signal = {
            id = 2,
            signalId = 2,
            vehicleSignalName = "K2",
            pedestrianSignalName = "F2",
            use = "VEHICLE_AND_PEDESTRIAN",
            modelId = "road",
            currentIndication = "GREEN",
            intersectionId = 1,
            lightStructures = {
                ["0"] = {
                    structureRed = "Red",
                    structureGreen = "Green",
                    structureYellow = "Yellow",
                    structureRequest = "Request",
                    hidden = true
                }
            },
            axisStructures = {
                {
                    structureName = "Axis",
                    axisName = "Signal",
                    positionDefault = 0,
                    positionRed = 1,
                    positionGreen = 2,
                    positionYellow = 3,
                    positionPedestrian = 4,
                    positionRedYellow = 5,
                    hidden = true
                }
            },
            hidden = true
        }
        local moduleSetting = {
            category = "Display",
            name = "Show",
            description = "Show requests",
            type = "boolean",
            value = true,
            eepFunction = "IntersectionSettings.setShowRequestsOnSignal",
            hidden = true
        }
        local ceType, keyId, key, intersectionDto = RoadDtoFactory.createIntersectionDto(intersection)
        local _, _, _, selectedIntersectionDto = RoadDtoFactory.createIntersectionDto(intersection, true)
        local laneCeType, laneKeyId, laneKey, laneDto = RoadDtoFactory.createIntersectionLaneDto(lane)
        local _, _, _, selectedLaneDto = RoadDtoFactory.createIntersectionLaneDto(lane, true)
        local phaseCeType, phaseKeyId, phaseKey, phaseDto =
            RoadDtoFactory.createIntersectionPhaseDto(phase)
        local tlCeType, tlKeyId, tlKey, signalDto =
            RoadDtoFactory.createIntersectionTrafficLightDto(signal)
        local _, _, _, selectedSignalDto =
            RoadDtoFactory.createIntersectionTrafficLightDto(signal, true)
        local moduleCeType, moduleKeyId, moduleKey, moduleDto =
            RoadDtoFactory.createIntersectionModuleSettingDto(moduleSetting)
        local defsCeType, defsKeyId, defs =
            TrafficLightModelDtoFactory.createTrafficLightModelDtoList({
                {
                    id = "road",
                    name = "road",
                    type = "road",
                    positions = {
                        positionRed = 1,
                        positionGreen = 2,
                        positionYellow = 3,
                        positionRedYellow = 4,
                        positionPedestrians = 5,
                        positionOff = 6,
                        positionOffBlinking = 7,
                        hidden = true
                    },
                    hidden = true
                }
            })

        intersection.name = "B"
        intersection.staticCams[2] = "Cam 2"

        assert.equals("ce.mods.road.Intersection", ceType)
        assert.equals("id", keyId)
        assert.equals(1, key)
        assert.same({
                        ceType = "ce.mods.road.Intersection",
                        id = 1,
                        name = "A",
                        eepSaveId = 77,
                        scriptVariableName = "c1",
                        currentPhase = "", -- oninterest, never selected
                        manualPhase = "",  -- oninterest, never selected
                        nextPhase = "",    -- oninterest, never selected
                        ready = false,         -- oninterest, never selected
                        greenTimeSeconds = 15,
                        switchInStrictOrder = false,
                        staticCams = { "Cam 1" },
                        signalGroupDefinitions = {},
                        pedestrianCrossings = {},
                        phases = {
                            {
                                id = "A-P1",
                                name = "P1",
                                order = 1,
                                prio = 2,
                                greenTimeSeconds = 15,
                                signalGroups = { "sgLane1Straight" },
                                signalHeads = {
                                    {
                                        signalId = 1,
                                        signalHeadKind = "VEHICLE",
                                        signalHeadKey = "1:VEHICLE",
                                        signalHeadName = "K1",
                                        type = "CAR",
                                        vehicleSignalHeadName = "K1",
                                        use = "VEHICLE_ONLY"
                                    },
                                    {
                                        signalId = 3,
                                        signalHeadKind = "PEDESTRIAN",
                                        signalHeadKey = "3:PEDESTRIAN",
                                        signalHeadName = "F1",
                                        type = "PEDESTRIAN",
                                        pedestrianSignalHeadName = "F1",
                                        use = "PEDESTRIAN_ONLY"
                                    }
                                }
                            }
                        }
                    }, intersectionDto)
        assert.same({
                        ceType = "ce.mods.road.Intersection",
                        id = 1,
                        name = "A",
            eepSaveId = 77,
            scriptVariableName = "c1",
            currentPhase = "P1",
                        manualPhase = "P2",
                        nextPhase = "P3",
                        ready = true,
                        greenTimeSeconds = 15,
                        switchInStrictOrder = false,
                        staticCams = { "Cam 1" },
                        signalGroupDefinitions = {},
                        pedestrianCrossings = {},
                        phases = {
                            {
                                id = "A-P1",
                                name = "P1",
                                order = 1,
                                prio = 2,
                                greenTimeSeconds = 15,
                                signalGroups = { "sgLane1Straight" },
                                signalHeads = {
                                    {
                                        signalId = 1,
                                        signalHeadKind = "VEHICLE",
                                        signalHeadKey = "1:VEHICLE",
                                        signalHeadName = "K1",
                                        type = "CAR",
                                        vehicleSignalHeadName = "K1",
                                        use = "VEHICLE_ONLY"
                                    },
                                    {
                                        signalId = 3,
                                        signalHeadKind = "PEDESTRIAN",
                                        signalHeadKey = "3:PEDESTRIAN",
                                        signalHeadName = "F1",
                                        type = "PEDESTRIAN",
                                        pedestrianSignalHeadName = "F1",
                                        use = "PEDESTRIAN_ONLY"
                                    }
                                }
                            }
                        }
                    }, selectedIntersectionDto)
        assert.equals("ce.mods.road.IntersectionLane", laneCeType)
        assert.equals("id", laneKeyId)
        assert.equals("1-L1", laneKey)
        assert.same({
                        ceType = "ce.mods.road.IntersectionLane",
                        id = "1-L1",
                        intersectionId = 1,
                        name = "L1",
                        currentIndication = "", -- oninterest, never selected
                        vehicleMultiplier = 2,
                        type = "NORMAL",
                        countType = "TRACKS",
                        waitingTrains = {},             -- oninterest, never selected
                        waitingForGreenCyclesCount = 0, -- oninterest, never selected
                        approach = "SOUTH",
                        directions = { "LEFT" },
                        phases = { "P1" },
                        defaultSignalGroups = {},
                        routeRules = {},
                        defaultRequestSignalGroups = { "sgLane1Straight" },
                        requestTrackIds = { 11, 12 },
                        highlightTrackIds = { 10 },
                        tracks = { 10 }
                    }, laneDto)
        assert.same({
                        ceType = "ce.mods.road.IntersectionLane",
                        id = "1-L1",
                        intersectionId = 1,
                        name = "L1",
                        currentIndication = "GREEN",
                        vehicleMultiplier = 2,
                        type = "NORMAL",
                        countType = "TRACKS",
                        waitingTrains = { "T1" },
                        waitingForGreenCyclesCount = 4,
                        approach = "SOUTH",
                        directions = { "LEFT" },
                        phases = { "P1" },
                        defaultSignalGroups = {},
                        routeRules = {},
                        defaultRequestSignalGroups = { "sgLane1Straight" },
                        requestTrackIds = { 11, 12 },
                        highlightTrackIds = { 10 },
                        tracks = { 10 }
                    }, selectedLaneDto)
        assert.equals("ce.mods.road.IntersectionPhase", phaseCeType)
        assert.equals("id", phaseKeyId)
        assert.equals("A-P1", phaseKey)
        assert.same({
                        ceType = "ce.mods.road.IntersectionPhase",
                        id = "A-P1",
                        intersectionId = "A",
                        name = "P1",
                        prio = 1
                    }, phaseDto)
        assert.equals("ce.mods.road.IntersectionTrafficLight", tlCeType)
        assert.equals("id", tlKeyId)
        assert.equals(2, tlKey)
        assert.same({
                        ceType = "ce.mods.road.IntersectionTrafficLight",
                        id = 2,
                        signalId = 2,
                        vehicleSignalName = "K2",
                        pedestrianSignalName = "F2",
                        use = "VEHICLE_AND_PEDESTRIAN",
                        modelId = "road",
                        currentIndication = "", -- oninterest, never selected
                        intersectionId = 1,
                        lightStructures = {
                            ["0"] = {
                                structureRed = "Red",
                                structureGreen = "Green",
                                structureYellow = "Yellow",
                                structureRequest = "Request"
                            }
                        },
                        axisStructures = {
                            {
                                structureName = "Axis",
                                axisName = "Signal",
                                positionDefault = 0,
                                positionRed = 1,
                                positionGreen = 2,
                                positionYellow = 3,
                                positionPedestrian = 4,
                                positionRedYellow = 5
                            }
                        }
                    }, signalDto)
        assert.same({
                        ceType = "ce.mods.road.IntersectionTrafficLight",
                        id = 2,
                        signalId = 2,
                        vehicleSignalName = "K2",
                        pedestrianSignalName = "F2",
                        use = "VEHICLE_AND_PEDESTRIAN",
                        modelId = "road",
                        currentIndication = "GREEN",
                        intersectionId = 1,
                        lightStructures = {
                            ["0"] = {
                                structureRed = "Red",
                                structureGreen = "Green",
                                structureYellow = "Yellow",
                                structureRequest = "Request"
                            }
                        },
                        axisStructures = {
                            {
                                structureName = "Axis",
                                axisName = "Signal",
                                positionDefault = 0,
                                positionRed = 1,
                                positionGreen = 2,
                                positionYellow = 3,
                                positionPedestrian = 4,
                                positionRedYellow = 5
                            }
                        }
                    }, selectedSignalDto)
        assert.equals("ce.mods.road.ModuleSetting", moduleCeType)
        assert.equals("name", moduleKeyId)
        assert.equals("Show", moduleKey)
        assert.same({
                        ceType = "ce.mods.road.ModuleSetting",
                        category = "Display",
                        name = "Show",
                        description = "Show requests",
                        type = "boolean",
                        value = true,
                        eepFunction = "IntersectionSettings.setShowRequestsOnSignal"
                    }, moduleDto)
        assert.equals("ce.mods.road.TrafficLightModel", defsCeType)
        assert.equals("id", defsKeyId)
        assert.same({
                        {
                            ceType = "ce.mods.road.TrafficLightModel",
                            id = "road",
                            name = "road",
                            type = "road",
                            positionRed = 1,
                            positionGreen = 2,
                            positionYellow = 3,
                            positionRedYellow = 4,
                            positionPedestrians = 5,
                            positionOff = 6,
                            positionOffBlinking = 7,
                            positions = {
                                positionRed = 1,
                                positionGreen = 2,
                                positionYellow = 3,
                                positionRedYellow = 4,
                                positionPedestrians = 5,
                                positionOff = 6,
                                positionOffBlinking = 7
                            }
                        }
                    }, defs)
    end)

    it("applies per-entry selection when creating road DTO lists", function ()
        local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")

        local _, _, dtos = RoadDtoFactory.createIntersectionDtoList({
                                                                        [1] = {
                                                                            id = 1,
                                                                            name = "A",
            eepSaveId = 77,
            scriptVariableName = "c1",
            currentPhase = "P1",
                                                                            manualPhase = "P2",
                                                                            nextPhase = "P3",
                                                                            ready = true,
                                                                            greenTimeSeconds = 15,
                                                                            staticCams = { "Cam 1" },
                                                                            phases = {}
                                                                        }
                                                                    }, function (intersection)
                                                                        return intersection.id == 1
                                                                    end)

        assert.same("P1", dtos[1].currentPhase)
        assert.same("P2", dtos[1].manualPhase)
        assert.same("P3", dtos[1].nextPhase)
        assert.is_true(dtos[1].ready)
    end)

    it("collects ordered intersection phases with sorted signal heads", function ()
        require("ce.hub.eep.EepSimulator")
        local RoadDataCollector = require("ce.mods.road.data.RoadDataCollector")

        local signalHead1 = {
            signalId = 1,
            vehicleSignalName = "K1",
            use = "VEHICLE_ONLY",
            currentIndication = "RED",
            trafficLightModel = { name = "road" },
            axisStructures = {},
            lightStructures = {}
        }
        local signalHead3 = {
            signalId = 3,
            pedestrianSignalName = "F1",
            use = "PEDESTRIAN_ONLY",
            currentIndication = "GREEN",
            trafficLightModel = { name = "road" },
            axisStructures = {},
            lightStructures = {}
        }
        local phase = {
            name = "P1",
            prio = 4,
            greenTimeSeconds = 12,
            lanes = {},
            signalHeads = {
                [signalHead3] = "PEDESTRIAN",
                [signalHead1] = "CAR"
            }
        }
        local crossing = {
            name = "A",
            staticCams = { "Cam 1" },
            getCurrentPhase = function () return nil end,
            getManualPhase = function () return nil end,
            getNextPhase = function () return nil end,
            isGreenTimeFinished = function () return true end,
            getGreenTimeSeconds = function () return 15 end,
            getStaticCams = function (self) return self.staticCams end,
            getPhases = function () return { phase } end
        }

        local data = RoadDataCollector.collectCrossings({ A = crossing })

        assert.same({
                        id = "A-P1",
                        name = "P1",
                        order = 1,
                        prio = 4,
                        greenTimeSeconds = 12,
                        signalGroups = {},
                        signalHeads = {
                            {
                                signalId = 3,
                                signalHeadKind = "PEDESTRIAN",
                                signalHeadKey = "3:PEDESTRIAN",
                                signalHeadName = "F1",
                                type = "PEDESTRIAN",
                                pedestrianSignalHeadName = "F1",
                                use = "PEDESTRIAN_ONLY"
                            },
                            {
                                signalId = 1,
                                signalHeadKind = "VEHICLE",
                                signalHeadKey = "1:VEHICLE",
                                signalHeadName = "K1",
                                type = "CAR",
                                vehicleSignalHeadName = "K1",
                                use = "VEHICLE_ONLY"
                            }
                        }
                    }, data.intersections[1].phases[1])
    end)

    it("collects lane signal group links when one default drive signal belongs to a combined group", function ()
        require("ce.hub.eep.EepSimulator")
        local RoadDataCollector = require("ce.mods.road.data.RoadDataCollector")

        local signalHead1 = {
            signalId = 1,
            vehicleSignalName = "K1",
            use = "VEHICLE_ONLY",
            currentIndication = "RED",
            trafficLightModel = { name = "road" },
            axisStructures = {},
            lightStructures = {}
        }
        local signalHead2 = {
            signalId = 2,
            vehicleSignalName = "K2",
            use = "VEHICLE_ONLY",
            currentIndication = "RED",
            trafficLightModel = { name = "road" },
            axisStructures = {},
            lightStructures = {}
        }
        local queue = { elements = function () return {} end }
        local lane1 = {
            name = "Spur 1",
            laneSignal = signalHead1,
            defaultDriveSignals = { [signalHead1] = true },
            fahrzeugMultiplikator = 1,
            trafficType = "NORMAL",
            waitCount = 0,
            directions = { "STRAIGHT" },
            requestSignals = { ["!ALL!"] = { signalHead1 } },
            tracksForRequests = { [17] = true, [11] = true },
            tracksForHighlighting = { 23, 24 },
            queue = queue
        }
        local lane2 = {
            name = "Spur 2",
            laneSignal = signalHead2,
            defaultDriveSignals = { [signalHead2] = true },
            fahrzeugMultiplikator = 1,
            trafficType = "NORMAL",
            waitCount = 0,
            directions = { "STRAIGHT" },
            queue = queue
        }
        local signalGroup = {
            name = "sgCombined",
            getSignalHeads = function () return { [signalHead1] = "CAR", [signalHead2] = "CAR" } end
        }
        local phase = {
            name = "P1",
            prio = 4,
            greenTimeSeconds = 12,
            lanes = { [lane1] = true, [lane2] = true },
            signalGroups = { signalGroup },
            signalHeads = { [signalHead1] = "CAR", [signalHead2] = "CAR" }
        }
        local crossing = {
            name = "A",
            signalGroups = { signalGroup },
            staticCams = {},
            getCurrentPhase = function () return nil end,
            getManualPhase = function () return nil end,
            getNextPhase = function () return nil end,
            isGreenTimeFinished = function () return true end,
            getGreenTimeSeconds = function () return 15 end,
            getStaticCams = function (self) return self.staticCams end,
            getPhases = function () return { phase } end
        }

        local data = RoadDataCollector.collectCrossings({ A = crossing })
        local groupsByLane = {}
        for _, laneDto in ipairs(data.intersectionLanes) do groupsByLane[laneDto.name] = laneDto.defaultSignalGroups end

        assert.same({ "sgCombined" }, groupsByLane["Spur 1"])
        assert.same({ "sgCombined" }, groupsByLane["Spur 2"])
    end)

    it("collects implicit lane signal group links from the lane signal", function ()
        require("ce.hub.eep.EepSimulator")
        local RoadDataCollector = require("ce.mods.road.data.RoadDataCollector")

        local laneSignal = {
            signalId = 92,
            vehicleSignalName = "K1",
            use = "VEHICLE_AND_PEDESTRIAN",
            currentIndication = "RED",
            trafficLightModel = { name = "road" },
            axisStructures = {},
            lightStructures = {}
        }
        local queue = { elements = function () return {} end }
        local lane = {
            name = "Spur 1",
            laneSignal = laneSignal,
            fahrzeugMultiplikator = 1,
            trafficType = "NORMAL",
            waitCount = 0,
            directions = { "STRAIGHT" },
            queue = queue
        }
        lane.requestSignals = { ["!ALL!"] = { laneSignal } }
        lane.tracksForRequests = { [17] = true, [11] = true }
        lane.tracksForHighlighting = { 23, 24 }
        local vehicleGroup = {
            name = "sgLane1Straight",
            getSignalHeads = function () return { [laneSignal] = "CAR" } end
        }
        local pedestrianGroup = {
            name = "sgPedWestEast",
            getSignalHeads = function () return { [laneSignal] = "PEDESTRIAN" } end
        }
        local phase = {
            name = "P1",
            prio = 4,
            greenTimeSeconds = 12,
            lanes = { [lane] = true },
            signalGroups = { vehicleGroup, pedestrianGroup },
            signalHeads = { [laneSignal] = "CAR" }
        }
        local crossing = {
            name = "A",
            signalGroups = { vehicleGroup, pedestrianGroup },
            staticCams = {},
            getCurrentPhase = function () return nil end,
            getManualPhase = function () return nil end,
            getNextPhase = function () return nil end,
            isGreenTimeFinished = function () return true end,
            getGreenTimeSeconds = function () return 15 end,
            getStaticCams = function (self) return self.staticCams end,
            getPhases = function () return { phase } end
        }

        local data = RoadDataCollector.collectCrossings({ A = crossing })

        assert.same({ "sgLane1Straight" }, data.intersectionLanes[1].defaultSignalGroups)
        assert.same({ "sgLane1Straight" }, data.intersectionLanes[1].defaultRequestSignalGroups)
        assert.same({ 11, 17 }, data.intersectionLanes[1].requestTrackIds)
        assert.same({ 23, 24 }, data.intersectionLanes[1].highlightTrackIds)
        assert.same({ 23, 24 }, data.intersectionLanes[1].tracks)
    end)
end)
