-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/trains/TrainStaticLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainStaticDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TrainStaticDtoFactory = {}

local CE_TYPE = HubCeTypes.TrainStatic
local KEY_ID = "id"

local function toTrainStaticDto(train)
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
        movesForward = train:getMovesForward()
    }
end

function TrainStaticDtoFactory.createDto(train)
    local dto = toTrainStaticDto(train)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TrainStaticDtoFactory.createDtoList(trains)
    local trainDtos = {}
    for trainId, train in pairs(trains) do
        local _, _, _, dto = TrainStaticDtoFactory.createDto(train)
        trainDtos[trainId] = dto
    end
    return CE_TYPE, KEY_ID, trainDtos
end

function TrainStaticDtoFactory.createRefDto(trainId)
    local dto = { ceType = CE_TYPE, id = trainId }
    return CE_TYPE, KEY_ID, trainId, dto
end

return TrainStaticDtoFactory
