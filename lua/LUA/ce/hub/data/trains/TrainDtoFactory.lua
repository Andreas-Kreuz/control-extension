-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/trains/TrainLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TrainDtoFactory = {}

local CE_TYPE = HubCeTypes.Train
local KEY_ID = "id"

-- ondemand fields use typed zero-value placeholders when isSubscribed is false
local function toFullDto(train, isSubscribed)
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
        speed = isSubscribed and train:getSpeed() or 0,
        targetSpeed = isSubscribed and train:getTargetSpeed() or 0,
        couplingFront = isSubscribed and train:getCouplingFront() or 0,
        couplingRear = isSubscribed and train:getCouplingRear() or 0,
        active = isSubscribed and train:getActive() or false,
        inTrainyard = isSubscribed and train:getInTrainyard() or false,
        trainyardId = isSubscribed and train:getTrainyardId() or "",
    }
end

local placeHolders = {
    speed = 0,
    targetSpeed = 0,
    couplingFront = 0,
    couplingRear = 0,
    active = false,
    inTrainyard = false,
    trainyardId = "",
}

local fieldGetters = {
    name = function (t) return t:getName() end,
    route = function (t) return t:getRoute() end,
    rollingStockCount = function (t) return t:getRollingStockCount() end,
    length = function (t) return t:getLength() end,
    line = function (t) return t:getLine() end,
    destination = function (t) return t:getDestination() end,
    direction = function (t) return t:getDirection() end,
    trackType = function (t) return t:getTrackType() end,
    movesForward = function (t) return t:getMovesForward() end,
    speed = function (t) return t:getSpeed() end,
    targetSpeed = function (t) return t:getTargetSpeed() end,
    couplingFront = function (t) return t:getCouplingFront() end,
    couplingRear = function (t) return t:getCouplingRear() end,
    active = function (t) return t:getActive() end,
    inTrainyard = function (t) return t:getInTrainyard() end,
    trainyardId = function (t) return t:getTrainyardId() end,
}

local function toPatchDto(train, dirtyFields, isSubscribed)
    local dto = {
        ceType = CE_TYPE,
        id = train:getName(),
    }
    for field in pairs(dirtyFields) do
        local getter = fieldGetters[field]
        if getter then
            if placeHolders[field] ~= nil then
                dto[field] = isSubscribed and getter(train) or placeHolders[field]
            else
                dto[field] = getter(train)
            end
        end
    end
    return dto
end

function TrainDtoFactory.createFullDto(train, isSubscribed)
    if isSubscribed == nil then isSubscribed = true end
    local dto = toFullDto(train, isSubscribed)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TrainDtoFactory.createPatchDto(train, dirtyFields, isSubscribed)
    if isSubscribed == nil then isSubscribed = true end
    local dto = toPatchDto(train, dirtyFields, isSubscribed)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TrainDtoFactory.createOndemandPlaceholderPatch(train)
    local dto = {
        ceType = CE_TYPE,
        id = train:getName(),
    }
    for field, placeholder in pairs(placeHolders) do
        dto[field] = placeholder
    end
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TrainDtoFactory.createRefDto(trainId)
    local dto = { ceType = CE_TYPE, id = trainId }
    return CE_TYPE, KEY_ID, trainId, dto
end

return TrainDtoFactory
