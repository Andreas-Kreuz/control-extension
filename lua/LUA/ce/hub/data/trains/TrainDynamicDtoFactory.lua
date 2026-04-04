-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/trains/TrainDynamicLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainDynamicDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TrainDynamicDtoFactory = {}

local CE_TYPE = HubCeTypes.TrainDynamic
local KEY_ID = "id"

-- ondemand fields use typed zero-value placeholders when isSubscribed is false
local function toTrainDynamicDto(train, isSubscribed)
    return {
        ceType = CE_TYPE,
        id = train:getName(),
        speed = isSubscribed and train:getSpeed() or 0,
        targetSpeed = isSubscribed and train:getTargetSpeed() or 0,
        couplingFront = isSubscribed and train:getCouplingFront() or 0,
        couplingRear = isSubscribed and train:getCouplingRear() or 0,
        active = isSubscribed and train:getActive() or false,
        inTrainyard = isSubscribed and train:getInTrainyard() or false,
        trainyardId = isSubscribed and train:getTrainyardId() or "",
    }
end

function TrainDynamicDtoFactory.createDto(train, isSubscribed)
    if isSubscribed == nil then isSubscribed = true end
    local dto = toTrainDynamicDto(train, isSubscribed)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TrainDynamicDtoFactory.createRefDto(trainId)
    local dto = { ceType = CE_TYPE, id = trainId }
    return CE_TYPE, KEY_ID, trainId, dto
end

return TrainDynamicDtoFactory
