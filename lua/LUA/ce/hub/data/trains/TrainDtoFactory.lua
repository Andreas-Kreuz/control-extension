-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/trains/TrainLuaDto.ts
if AkDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TrainDtoFactory = {}

local CE_TYPE = HubCeTypes.Train
local KEY_ID = "id"

local function shouldInclude(fieldOptions, fieldName)
    local field = fieldOptions and fieldOptions[fieldName] or nil
    return field == nil or field.collect ~= false
end

local function toFullDto(train, isSubscribed, fieldOptions)
    local dto = {
        ceType = CE_TYPE,
        id = train:getName(),
        name = train:getName(),
    }
    if shouldInclude(fieldOptions, "route") then dto.route = train:getRoute() end
    if shouldInclude(fieldOptions, "rollingStockCount") then dto.rollingStockCount = train:getRollingStockCount() end
    if shouldInclude(fieldOptions, "length") then dto.length = train:getLength() end
    if shouldInclude(fieldOptions, "line") then dto.line = train:getLine() end
    if shouldInclude(fieldOptions, "destination") then dto.destination = train:getDestination() end
    if shouldInclude(fieldOptions, "direction") then dto.direction = train:getDirection() end
    if shouldInclude(fieldOptions, "trackType") then dto.trackType = train:getTrackType() end
    if shouldInclude(fieldOptions, "movesForward") then dto.movesForward = train:getMovesForward() end
    if shouldInclude(fieldOptions, "speed") then dto.speed = isSubscribed and train:getSpeed() or 0 end
    if shouldInclude(fieldOptions, "targetSpeed") then
        dto.targetSpeed = isSubscribed and train:getTargetSpeed() or 0
    end
    if shouldInclude(fieldOptions, "couplingFront") then
        dto.couplingFront = isSubscribed and train:getCouplingFront() or 0
    end
    if shouldInclude(fieldOptions, "couplingRear") then
        dto.couplingRear = isSubscribed and train:getCouplingRear() or 0
    end
    if shouldInclude(fieldOptions, "active") then
        dto.active = isSubscribed and train:getActive() or false
    end
    if shouldInclude(fieldOptions, "inTrainyard") then
        dto.inTrainyard = isSubscribed and train:getInTrainyard() or false
    end
    if shouldInclude(fieldOptions, "trainyardId") then
        dto.trainyardId = isSubscribed and train:getTrainyardId() or ""
    end
    return dto
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

local function toPatchDto(train, dirtyFields, isSubscribed, fieldOptions)
    local dto = {
        ceType = CE_TYPE,
        id = train:getName(),
    }
    for field in pairs(dirtyFields) do
        local getter = shouldInclude(fieldOptions, field) and fieldGetters[field] or nil
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

function TrainDtoFactory.createFullDto(train, isSubscribed, fieldOptions)
    if isSubscribed == nil then isSubscribed = true end
    local dto = toFullDto(train, isSubscribed, fieldOptions)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TrainDtoFactory.createPatchDto(train, dirtyFields, isSubscribed, fieldOptions)
    if isSubscribed == nil then isSubscribed = true end
    local dto = toPatchDto(train, dirtyFields, isSubscribed, fieldOptions)
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
