insulate("ce.hub.data.trains.TrainDtoFactories", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.trains.TrainStaticDtoFactory")
        clearModule("ce.hub.data.trains.TrainDynamicDtoFactory")
        clearModule("ce.hub.data.rollingstock.RollingStockStaticDtoFactory")
        clearModule("ce.hub.data.rollingstock.RollingStockDynamicDtoFactory")
        clearModule("ce.hub.data.rollingstock.RollingStockTexturesDtoFactory")
        clearModule("ce.hub.data.rollingstock.RollingStockRotationDtoFactory")
    end)

    it("provides metadata for static and dynamic train and rolling stock DTOs", function ()
        local TrainStaticDtoFactory = require("ce.hub.data.trains.TrainStaticDtoFactory")
        local TrainDynamicDtoFactory = require("ce.hub.data.trains.TrainDynamicDtoFactory")
        local RollingStockStaticDtoFactory = require("ce.hub.data.rollingstock.RollingStockStaticDtoFactory")
        local RollingStockDynamicDtoFactory = require("ce.hub.data.rollingstock.RollingStockDynamicDtoFactory")
        local TexturesDtoFactory = require("ce.hub.data.rollingstock.RollingStockTexturesDtoFactory")
        local RotationDtoFactory = require("ce.hub.data.rollingstock.RollingStockRotationDtoFactory")

        local train = {
            getName = function () return "T1" end,
            getRoute = function () return "R" end,
            getRollingStockCount = function () return 1 end,
            getLength = function () return 2 end,
            getLine = function () return "L1" end,
            getDestination = function () return "Depot" end,
            getDirection = function () return "North" end,
            getTrackType = function () return "rail" end,
            getMovesForward = function () return true end,
            getSpeed = function () return 3 end,
            getTargetSpeed = function () return 4 end,
            getCouplingFront = function () return 1 end,
            getCouplingRear = function () return 2 end,
            getActive = function () return true end,
            getTrainyardId = function () return 9 end,
            getInTrainyard = function () return false end,
            toJsonStatic = function () error("createDto should not use toJsonStatic") end
        }
        local rollingStock = {
            rollingStockName = "RS1",
            getTrainName = function () return "T1" end,
            getPositionInTrain = function () return 0 end,
            getCouplingFront = function () return 2 end,
            getCouplingRear = function () return 3 end,
            getLength = function () return 12.5 end,
            getPropelled = function () return true end,
            getModelType = function () return 8 end,
            getModelTypeText = function () return "Tram" end,
            getTag = function () return "tag" end,
            getOrientationForward = function () return true end,
            getSmoke = function () return 1 end,
            getHookStatus = function () return 2 end,
            getHookGlueMode = function () return 3 end,
            getActive = function () return false end,
            getTextureTexts = function () return { ["1"] = "Line", ["2"] = "" } end,
            getRotX = function () return 1.23 end,
            getRotY = function () return 2.35 end,
            getRotZ = function () return 3.46 end,
            getWagonNr = function () return "42" end,
            getTrackId = function () return 99 end,
            getTrackDistance = function () return 10.5 end,
            getTrackDirection = function () return 1 end,
            getTrackSystem = function () return 3 end,
            getTrackType = function () return "road" end,
            getX = function () return 1 end,
            getY = function () return 2 end,
            getZ = function () return 3 end,
            getMileage = function () return 4 end,
            toJsonStatic = function () error("createDto should not use toJsonStatic") end
        }

        local trainStaticRoom, trainStaticKeyId, trainStaticKey, trainStaticDto =
            TrainStaticDtoFactory.createDto(train)
        local trainDynamicRoom, trainDynamicKeyId, trainDynamicKey, trainDynamicDto =
            TrainDynamicDtoFactory.createDto(train)
        local rsStaticRoom, rsStaticKeyId, rsStaticKey, rsStaticDto =
            RollingStockStaticDtoFactory.createDto(rollingStock)
        local rsDynamicRoom, rsDynamicKeyId, rsDynamicKey, rsDynamicDto =
            RollingStockDynamicDtoFactory.createDto(rollingStock)
        local rsTexturesRoom, rsTexturesKeyId, rsTexturesKey, rsTexturesDto =
            TexturesDtoFactory.createDto(rollingStock)
        local rsRotationRoom, rsRotationKeyId, rsRotationKey, rsRotationDto =
            RotationDtoFactory.createDto(rollingStock)

        assert.equals("ce.hub.TrainStatic", trainStaticRoom)
        assert.equals("id", trainStaticKeyId)
        assert.equals("T1", trainStaticKey)
        assert.same({
                        ceType = "ce.hub.TrainStatic",
                        id = "T1",
                        name = "T1",
                        route = "R",
                        rollingStockCount = 1,
                        length = 2,
                        line = "L1",
                        destination = "Depot",
                        direction = "North",
                        trackType = "rail",
                        movesForward = true
                    }, trainStaticDto)

        assert.equals("ce.hub.TrainDynamic", trainDynamicRoom)
        assert.equals("id", trainDynamicKeyId)
        assert.equals("T1", trainDynamicKey)
        assert.same({
                        ceType = "ce.hub.TrainDynamic",
                        id = "T1",
                        speed = 3,
                        targetSpeed = 4,
                        couplingFront = 1,
                        couplingRear = 2,
                        active = true,
                        trainyardId = 9,
                        inTrainyard = false
                    }, trainDynamicDto)

        assert.equals("ce.hub.RollingStockStatic", rsStaticRoom)
        assert.equals("id", rsStaticKeyId)
        assert.equals("RS1", rsStaticKey)
        assert.same({
                        ceType = "ce.hub.RollingStockStatic",
                        id = "RS1",
                        name = "RS1",
                        trainName = "T1",
                        positionInTrain = 0,
                        couplingFront = 2,
                        couplingRear = 3,
                        length = 12.5,
                        propelled = true,
                        modelType = 8,
                        modelTypeText = "Tram",
                        tag = "tag",
                        nr = "42",
                        trackType = "road",
                        hookStatus = 2,
                        hookGlueMode = 3
                    }, rsStaticDto)

        assert.equals("ce.hub.RollingStockDynamic", rsDynamicRoom)
        assert.equals("id", rsDynamicKeyId)
        assert.equals("RS1", rsDynamicKey)
        assert.same({
                        ceType = "ce.hub.RollingStockDynamic",
                        id = "RS1",
                        trackId = 99,
                        trackDistance = 10.5,
                        trackDirection = 1,
                        trackSystem = 3,
                        posX = 1,
                        posY = 2,
                        posZ = 3,
                        mileage = 4,
                        orientationForward = true,
                        smoke = 1,
                        active = false
                    }, rsDynamicDto)

        assert.equals("ce.hub.RollingStockTextures", rsTexturesRoom)
        assert.equals("id", rsTexturesKeyId)
        assert.equals("RS1", rsTexturesKey)
        assert.same({
                        ceType = "ce.hub.RollingStockTextures",
                        id = "RS1",
                        surfaceTexts = { ["1"] = "Line", ["2"] = "" }
                    }, rsTexturesDto)
        assert.equals("ce.hub.RollingStockRotation", rsRotationRoom)
        assert.equals("id", rsRotationKeyId)
        assert.equals("RS1", rsRotationKey)
        assert.same({
                        ceType = "ce.hub.RollingStockRotation",
                        id = "RS1",
                        rotX = 1.23,
                        rotY = 2.35,
                        rotZ = 3.46
                    }, rsRotationDto)
    end)
end)
