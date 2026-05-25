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
            peekName = function () return "T1" end,
            peekRoute = function () return "R" end,
            peekRollingStockCount = function () return 1 end,
            peekLength = function () return 2 end,
            peekTrackType = function () return "rail" end,
            peekMovesForward = function () return true end,
            peekSpeed = function () return 3 end,
            peekTargetSpeed = function () return 4 end,
            peekCouplingFront = function () return 1 end,
            peekCouplingRear = function () return 2 end,
            peekLights = function () return { ["0"] = true, ["1"] = false, ["2"] = true, ["3"] = false } end,
            peekActive = function () return true end,
            peekTrainyardId = function () return 9 end,
            peekInTrainyard = function () return false end,
        }
        local rollingStock = {
            rollingStockName = "RS1",
            peekTrainName = function () return "T1" end,
            peekPositionInTrain = function () return 0 end,
            peekCouplingFront = function () return 2 end,
            peekCouplingRear = function () return 3 end,
            peekLength = function () return 12.5 end,
            peekPropelled = function () return true end,
            peekModelType = function () return 8 end,
            peekModelTypeText = function () return "Tram" end,
            peekTag = function () return "tag" end,
            peekOrientationForward = function () return true end,
            peekSmoke = function () return 1 end,
            peekHookStatus = function () return 2 end,
            peekHookGlueMode = function () return 3 end,
            peekActive = function () return false end,
            peekTextureTexts = function () return { ["1"] = "Line", ["2"] = "" } end,
            peekAxisNames = function () return { ["2"] = "Fahrer" } end,
            peekAxisValues = function () return { ["2"] = 75 } end,
            peekTextureNames = function () return { ["1"] = "Fahrziel" } end,
            peekRotX = function () return 1.23 end,
            peekRotY = function () return 2.35 end,
            peekRotZ = function () return 3.46 end,
            peekWagonNr = function () return "42" end,
            peekTrackId = function () return 99 end,
            peekTrackDistance = function () return 10.5 end,
            peekTrackDirection = function () return 1 end,
            peekTrackSystem = function () return 3 end,
            peekTrackType = function () return "road" end,
            peekX = function () return 1 end,
            peekY = function () return 2 end,
            peekZ = function () return 3 end,
            peekMileage = function () return 4 end,
            peekXmlModel = function () return "SCHIENE\\STRASSENBAHN\\GT4_WG_A_01_MA1.3dm" end,
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
                        lights = { ["0"] = true, ["1"] = false, ["2"] = true, ["3"] = false },
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
        assert.same({ ["2"] = "Fahrer" }, rsDto.axisNames)
        assert.same({ ["2"] = 75 }, rsDto.axisValues)
        assert.same({ ["1"] = "Fahrziel" }, rsDto.textureNames)
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
        assert.equals("SCHIENE\\STRASSENBAHN\\GT4_WG_A_01_MA1.3dm", rsDto.xmlModel)
    end)

    it("uses placeholder values for ondemand fields when not subscribed", function ()
        local TrainDtoFactory = require("ce.hub.data.trains.TrainDtoFactory")

        local train = {
            peekName = function () return "T1" end,
            peekRoute = function () return "R" end,
            peekRollingStockCount = function () return 1 end,
            peekLength = function () return 2 end,
            peekTrackType = function () return "rail" end,
            peekMovesForward = function () return true end,
            peekSpeed = function () return 99 end,
            peekTargetSpeed = function () return 88 end,
            peekCouplingFront = function () return 5 end,
            peekCouplingRear = function () return 6 end,
            peekLights = function () return { ["0"] = true, ["1"] = true, ["2"] = true, ["3"] = true } end,
            peekActive = function () return true end,
            peekTrainyardId = function () return 7 end,
            peekInTrainyard = function () return true end,
        }

        local _, _, _, dto = TrainDtoFactory.createFullDto(train, false)

        -- Ondemand fields should use placeholders when not subscribed
        assert.equals(0, dto.speed)
        assert.equals(0, dto.targetSpeed)
        assert.equals(0, dto.couplingFront)
        assert.equals(0, dto.couplingRear)
        assert.same({ ["0"] = false, ["1"] = false, ["2"] = false, ["3"] = false }, dto.lights)
        assert.equals(false, dto.active)
        assert.equals(false, dto.inTrainyard)
        assert.equals("", dto.trainyardId)
    end)
end)
