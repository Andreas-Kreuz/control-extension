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
            signalGroupDefinitions = {
                {
                    name = "sgLane1Left",
                    scriptVariableName = "sgLane1Left",
                    approach = "WEST",
                    turnDirections = { "LEFT" },
                    trafficType = "CAR",
                    signalIds = { 1 },
                    pedestrianCrossingNames = { "Furt West" }
                }
            },
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
            kpId = "c1Lane1",
            scriptVariableName = "c1Lane1",
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
                        ready = false,     -- oninterest, never selected
                        greenTimeSeconds = 15,
                        switchInStrictOrder = false,
                        staticCams = { "Cam 1" },
                        signalGroupDefinitions = {
                            {
                                name = "sgLane1Left",
                                scriptVariableName = "sgLane1Left",
                                approach = "WEST",
                                turnDirections = { "LEFT" },
                                trafficType = "CAR",
                                signalIds = { 1 },
                                pedestrianCrossingNames = { "Furt West" }
                            }
                        },
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
                        signalGroupDefinitions = {
                            {
                                name = "sgLane1Left",
                                scriptVariableName = "sgLane1Left",
                                approach = "WEST",
                                turnDirections = { "LEFT" },
                                trafficType = "CAR",
                                signalIds = { 1 },
                                pedestrianCrossingNames = { "Furt West" }
                            }
                        },
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
                        kpId = "c1Lane1",
                        scriptVariableName = "c1Lane1",
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
                        kpId = "c1Lane1",
                        scriptVariableName = "c1Lane1",
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
            _kpId = "c1Lane1",
            getKpId = function (self) return self._kpId end,
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
            _scriptVariableName = "sgCombinedScript",
            approach = "WEST",
            turnDirections = { "LEFT" },
            getApproach = function (self) return self.approach end,
            getTurnDirections = function (self) return self.turnDirections end,
            getScriptVariableName = function (self) return self._scriptVariableName end,
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

        assert.same({ "sgCombinedScript" }, groupsByLane["Spur 1"])
        assert.same({ "sgCombinedScript" }, groupsByLane["Spur 2"])
        assert.same({ "sgCombinedScript" }, data.intersections[1].phases[1].signalGroups)
        assert.equals("sgCombinedScript", data.intersections[1].signalGroupDefinitions[1].scriptVariableName)
        assert.equals("WEST", data.intersections[1].signalGroupDefinitions[1].approach)
        assert.same({ "LEFT" }, data.intersections[1].signalGroupDefinitions[1].turnDirections)
        assert.equals("c1Lane1", data.intersectionLanes[1].kpId)
    end)

    it("collects duplicate signal group names through script-variable references", function ()
        require("ce.hub.eep.EepSimulator")
        local RoadDataCollector = require("ce.mods.road.data.RoadDataCollector")

        local signalHead1 = {
            signalId = 379,
            vehicleSignalName = "F3",
            use = "VEHICLE_ONLY",
            currentIndication = "RED",
            trafficLightModel = { name = "road" },
            axisStructures = {},
            lightStructures = {}
        }
        local signalHead2 = {
            signalId = 373,
            pedestrianSignalName = "F5",
            use = "PEDESTRIAN_ONLY",
            currentIndication = "RED",
            trafficLightModel = { name = "road" },
            axisStructures = {},
            lightStructures = {}
        }
        local crossing1 = {
            getName = function () return "sgNorthPed" end,
            getScriptVariableName = function () return "c3PedNorth" end,
            getApproach = function () return "NORTH" end
        }
        local crossing2 = {
            getName = function () return "sgNorthPed2" end,
            getScriptVariableName = function () return "c3PedNorth2" end,
            getApproach = function () return "NORTH" end
        }
        local signalGroup1 = {
            name = "sgNorthPed",
            getScriptVariableName = function () return "c3SgNorthPed" end,
            getSignalHeads = function () return { [signalHead1] = "PEDESTRIAN" } end,
            getPedestrianCrossings = function () return { crossing1 } end
        }
        local signalGroup2 = {
            name = "sgNorthPed",
            getScriptVariableName = function () return "c3SgNorthPed_2" end,
            getSignalHeads = function () return { [signalHead2] = "PEDESTRIAN" } end,
            getPedestrianCrossings = function () return { crossing2 } end
        }
        signalHead1.signalGroupsByUse = { PEDESTRIAN = signalGroup1 }
        signalHead2.signalGroupsByUse = { PEDESTRIAN = signalGroup2 }
        local phase = {
            name = "P1",
            prio = 4,
            greenTimeSeconds = 12,
            lanes = {},
            signalGroups = { signalGroup1, signalGroup2 },
            signalHeads = { [signalHead1] = "PEDESTRIAN", [signalHead2] = "PEDESTRIAN" }
        }
        local crossing = {
            name = "A",
            signalGroups = { signalGroup1, signalGroup2 },
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
        local signalById = {}
        for _, signal in ipairs(data.intersectionTrafficLights) do signalById[signal.signalId] = signal end

        assert.same({ "c3SgNorthPed", "c3SgNorthPed_2" }, data.intersections[1].phases[1].signalGroups)
        assert.same({ "c3SgNorthPed" }, data.intersections[1].pedestrianCrossings[1].signalGroups)
        assert.same({ "c3SgNorthPed_2" }, data.intersections[1].pedestrianCrossings[2].signalGroups)
        assert.equals("sgNorthPed", data.intersections[1].signalGroupDefinitions[1].name)
        assert.equals("c3SgNorthPed", data.intersections[1].signalGroupDefinitions[1].scriptVariableName)
        assert.equals("sgNorthPed", data.intersections[1].signalGroupDefinitions[2].name)
        assert.equals("c3SgNorthPed_2", data.intersections[1].signalGroupDefinitions[2].scriptVariableName)
        assert.equals("PEDESTRIAN_ONLY", signalById[379].use)
        assert.is_nil(signalById[379].vehicleSignalName)
        assert.equals("F3", signalById[379].pedestrianSignalName)
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
    it("does not publish scriptVariableName methods when metadata is unset", function ()
        require("ce.hub.eep.EepSimulator")
        local json = require("ce.third-party.json")
        local RoadDataCollector = require("ce.mods.road.data.RoadDataCollector")
        local RoadDtoFactory = require("ce.mods.road.data.RoadDtoFactory")

        local queue = { elements = function () return {} end }
        local lane = {
            name = "Spur 1",
            scriptVariableName = function () end,
            getScriptVariableName = function () return nil end,
            defaultDriveSignals = {},
            fahrzeugMultiplikator = 1,
            trafficType = "NORMAL",
            waitCount = 0,
            directions = { "STRAIGHT" },
            requestSignals = {},
            tracksForRequests = {},
            tracksForHighlighting = {},
            queue = queue
        }
        local phase = {
            name = "P1",
            prio = 1,
            greenTimeSeconds = 12,
            lanes = { [lane] = true },
            signalGroups = {},
            signalHeads = {}
        }
        local crossing = {
            name = "A",
            scriptVariableName = function () end,
            getScriptVariableName = function () return nil end,
            signalGroups = {},
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
        local _, _, intersections = RoadDtoFactory.createIntersectionDtoList(data.intersections)
        local _, _, lanes = RoadDtoFactory.createIntersectionLaneDtoList(data.intersectionLanes)

        assert.is_nil(intersections[1].scriptVariableName)
        assert.is_nil(lanes[1].scriptVariableName)
        assert.has_no.errors(function () json.encode({ intersections = intersections, lanes = lanes }) end)
    end)
end)
