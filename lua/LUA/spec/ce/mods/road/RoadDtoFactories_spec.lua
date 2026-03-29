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
            currentSwitching = "S1",
            manualSwitching = "S2",
            nextSwitching = "S3",
            ready = true,
            timeForGreen = 15,
            staticCams = { "Cam 1" },
            hidden = true
        }
        local lane = {
            id = "1-L1",
            intersectionId = 1,
            name = "L1",
            phase = "GREEN",
            vehicleMultiplier = 2,
            eepSaveId = 5,
            type = "NORMAL",
            countType = "TRACKS",
            waitingTrains = { "T1" },
            waitingForGreenCyclesCount = 4,
            directions = { "LEFT" },
            switchings = { "S1" },
            tracks = { 10 },
            hidden = true
        }
        local switching = { id = "A-S1", intersectionId = "A", name = "S1", prio = 1, hidden = true }
        local trafficLight = {
            id = 2,
            signalId = 2,
            modelId = "road",
            currentPhase = "GREEN",
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
        local laneCeType, laneKeyId, laneKey, laneDto = RoadDtoFactory.createIntersectionLaneDto(lane)
        local switchingCeType, switchingKeyId, switchingKey, switchingDto =
            RoadDtoFactory.createIntersectionSwitchingDto(switching)
        local tlCeType, tlKeyId, tlKey, trafficLightDto =
            RoadDtoFactory.createIntersectionTrafficLightDto(trafficLight)
        local moduleCeType, moduleKeyId, moduleKey, moduleDto =
            RoadDtoFactory.createIntersectionModuleSettingDto(moduleSetting)
        local defsCeType, defsKeyId, defs =
            TrafficLightModelDtoFactory.createSignalTypeDefinitionDtoList({
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
                        currentSwitching = "S1",
                        manualSwitching = "S2",
                        nextSwitching = "S3",
                        ready = true,
                        timeForGreen = 15,
                        staticCams = { "Cam 1" }
                    }, intersectionDto)
        assert.equals("ce.mods.road.IntersectionLane", laneCeType)
        assert.equals("id", laneKeyId)
        assert.equals("1-L1", laneKey)
        assert.same({
                        ceType = "ce.mods.road.IntersectionLane",
                        id = "1-L1",
                        intersectionId = 1,
                        name = "L1",
                        phase = "GREEN",
                        vehicleMultiplier = 2,
                        eepSaveId = 5,
                        type = "NORMAL",
                        countType = "TRACKS",
                        waitingTrains = { "T1" },
                        waitingForGreenCyclesCount = 4,
                        directions = { "LEFT" },
                        switchings = { "S1" },
                        tracks = { 10 }
                    }, laneDto)
        assert.equals("ce.mods.road.IntersectionSwitching", switchingCeType)
        assert.equals("id", switchingKeyId)
        assert.equals("A-S1", switchingKey)
        assert.same({
                        ceType = "ce.mods.road.IntersectionSwitching",
                        id = "A-S1",
                        intersectionId = "A",
                        name = "S1",
                        prio = 1
                    }, switchingDto)
        assert.equals("ce.mods.road.IntersectionTrafficLight", tlCeType)
        assert.equals("id", tlKeyId)
        assert.equals(2, tlKey)
        assert.same({
                        ceType = "ce.mods.road.IntersectionTrafficLight",
                        id = 2,
                        signalId = 2,
                        modelId = "road",
                        currentPhase = "GREEN",
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
                    }, trafficLightDto)
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
        assert.equals("ce.mods.road.SignalTypeDefinition", defsCeType)
        assert.equals("id", defsKeyId)
        assert.same({
                        {
                            ceType = "ce.mods.road.SignalTypeDefinition",
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
end)
