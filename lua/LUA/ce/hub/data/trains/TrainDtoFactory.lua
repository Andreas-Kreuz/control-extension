-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/trains/TrainLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TrainDtoFactory = {}

local CE_TYPE = HubCeTypes.Train
local KEY_ID = "id"

local function copyTable(values)
    local copy = {}
    for key, value in pairs(values or {}) do copy[key] = value end
    return copy
end

local function toTrainDto(train)
    return {
        ceType = CE_TYPE,
        id = train:getName(),
        name = train:getName(),
        route = train:getRoute(),
        rollingStockCount = train:getRollingStockCount(),
        length = train:getLength(),
        line = train:getLine(),
        destination = train:getDestination(),
        direction = train:getDirection(),
        trackType = train:getTrackType(),
        movesForward = train:getMovesForward(),
        speed = train:getSpeed(),
        targetSpeed = train:getTargetSpeed(),
        couplingFront = train:getCouplingFront(),
        couplingRear = train:getCouplingRear(),
        active = train:getActive(),
        trainyardId = train:getTrainyardId(),
        inTrainyard = train:getInTrainyard(),
        occupiedTacks = copyTable(train:getOnTrack())
    }
end

function TrainDtoFactory.createTrainDto(train)
    local dto = toTrainDto(train)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TrainDtoFactory.createTrainDtoList(trains)
    local trainDtos = {}
    for trainId, train in pairs(trains) do
        local _, _, _, dto = TrainDtoFactory.createTrainDto(train)
        trainDtos[trainId] = dto
    end
    return CE_TYPE, KEY_ID, trainDtos
end

function TrainDtoFactory.createTrainReferenceDto(trainId)
    local dto = { ceType = CE_TYPE, id = trainId }
    return CE_TYPE, KEY_ID, trainId, dto
end

return TrainDtoFactory
