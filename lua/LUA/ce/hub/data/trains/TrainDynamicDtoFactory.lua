-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/trains/TrainDynamicLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainDynamicDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TrainDynamicDtoFactory = {}

local CE_TYPE = HubCeTypes.TrainDynamic
local KEY_ID = "id"

local function toTrainDynamicDto(train)
    return {
        ceType = CE_TYPE,
        id = train:getName(),
        speed = train:getSpeed(),
        targetSpeed = train:getTargetSpeed(),
        couplingFront = train:getCouplingFront(),
        couplingRear = train:getCouplingRear(),
        active = train:getActive(),
        trainyardId = train:getTrainyardId(),
        inTrainyard = train:getInTrainyard()
    }
end

function TrainDynamicDtoFactory.createDto(train)
    local dto = toTrainDynamicDto(train)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TrainDynamicDtoFactory.createRefDto(trainId)
    local dto = { ceType = CE_TYPE, id = trainId }
    return CE_TYPE, KEY_ID, trainId, dto
end

return TrainDynamicDtoFactory
