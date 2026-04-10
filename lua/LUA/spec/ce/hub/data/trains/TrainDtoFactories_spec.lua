insulate("ce.hub.data.trains.TrainDtoFactory and RollingStockDtoFactory", function ()
    local function clearModule(name) package.loaded[name] = nil end

    before_each(function ()
        clearModule("ce.hub.data.trains.TrainDtoFactory")
        clearModule("ce.hub.data.rollingstock.RollingStockDtoFactory")
    end)

    it("provides unified full DTOs for train and rolling stock", function ()
        local TrainDtoFactory = require("ce.hub.data.trains.TrainDtoFactory")
        local RollingStockDtoFactory = require("ce.hub.data.rollingstock.RollingStockDtoFactory")

        local train = {
            getName = function () return "T1" end,
            getRoute = function () return "R" end,
            getRollingStockCount = function () return 1 end,
            getLength = function () return 2 end,
            getTrackType = function () return "rail" end,
            getMovesForward = function () return true end,
            getSpeed = function () return 3 end,
            getTargetSpeed = function () return 4 end,
            getCouplingFront = function () return 1 end,
            getCouplingRear = function () return 2 end,
            getActive = function () return true end,
            getTrainyardId = function () return 9 end,
            getInTrainyard = function () return false end,
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
        }

        local trainCeType, trainKeyId, trainKey, trainDto =
            TrainDtoFactory.createFullDto(train, true)

        assert.equals("ce.hub.Train", trainCeType)
        assert.equals("id", trainKeyId)
        assert.equals("T1", trainKey)
        assert.same({
                        ceType = "ce.hub.Train",
                        id = "T1",
                        name = "T1",
                        route = "R",
                        rollingStockCount = 1,
                        length = 2,
                        trackType = "rail",
                        movesForward = true,
                        speed = 3,
                        targetSpeed = 4,
                        couplingFront = 1,
                        couplingRear = 2,
                        active = true,
                        trainyardId = 9,
                        inTrainyard = false,
                    }, trainDto)

        local rsCeType, rsKeyId, rsKey, rsDto =
            RollingStockDtoFactory.createFullDto(rollingStock, true)

        assert.equals("ce.hub.RollingStock", rsCeType)
        assert.equals("id", rsKeyId)
        assert.equals("RS1", rsKey)
        assert.equals("ce.hub.RollingStock", rsDto.ceType)
        assert.equals("RS1", rsDto.id)
        assert.equals("T1", rsDto.trainName)
        assert.equals(0, rsDto.positionInTrain)
        assert.equals(12.5, rsDto.length)
        assert.equals(true, rsDto.propelled)
        assert.equals(8, rsDto.modelType)
        assert.equals("Tram", rsDto.modelTypeText)
        assert.equals("tag", rsDto.tag)
        assert.equals("42", rsDto.nr)
        assert.equals("road", rsDto.trackType)
        assert.equals(2, rsDto.hookStatus)
        assert.equals(3, rsDto.hookGlueMode)
        assert.same({ ["1"] = "Line", ["2"] = "" }, rsDto.surfaceTexts)
        assert.equals(99, rsDto.trackId)
        assert.equals(10.5, rsDto.trackDistance)
        assert.equals(1, rsDto.trackDirection)
        assert.equals(3, rsDto.trackSystem)
        assert.equals(1, rsDto.posX)
        assert.equals(2, rsDto.posY)
        assert.equals(3, rsDto.posZ)
        assert.equals(4, rsDto.mileage)
        assert.equals(true, rsDto.orientationForward)
        assert.equals(1, rsDto.smoke)
        assert.equals(false, rsDto.active)
        assert.equals(1.23, rsDto.rotX)
        assert.equals(2.35, rsDto.rotY)
        assert.equals(3.46, rsDto.rotZ)
    end)

    it("uses placeholder values for ondemand fields when not subscribed", function ()
        local TrainDtoFactory = require("ce.hub.data.trains.TrainDtoFactory")

        local train = {
            getName = function () return "T1" end,
            getRoute = function () return "R" end,
            getRollingStockCount = function () return 1 end,
            getLength = function () return 2 end,
            getTrackType = function () return "rail" end,
            getMovesForward = function () return true end,
            getSpeed = function () return 99 end,
            getTargetSpeed = function () return 88 end,
            getCouplingFront = function () return 5 end,
            getCouplingRear = function () return 6 end,
            getActive = function () return true end,
            getTrainyardId = function () return 7 end,
            getInTrainyard = function () return true end,
        }

        local _, _, _, dto = TrainDtoFactory.createFullDto(train, false)

        -- Ondemand fields should use placeholders when not subscribed
        assert.equals(0, dto.speed)
        assert.equals(0, dto.targetSpeed)
        assert.equals(0, dto.couplingFront)
        assert.equals(0, dto.couplingRear)
        assert.equals(false, dto.active)
        assert.equals(false, dto.inTrainyard)
        assert.equals("", dto.trainyardId)
    end)
end)
