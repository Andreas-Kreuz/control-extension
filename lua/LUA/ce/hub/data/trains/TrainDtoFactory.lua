 -- TypeScript LuaDto: apps/web-server/src/server/ce/dto/trains/TrainLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local TrainDtoFactory = {}

local CE_TYPE = HubCeTypes.Train
local KEY_ID = "id"

local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local function toFullDto(train, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("trains")
    local dto = {
        ceType = CE_TYPE,
        id = train:getName(),
        name = train:getName(),
    }
    if SyncPolicy.shouldPublishField(fieldPolicies, "route", isSelected) then dto.route = train:getRoute() end
    if SyncPolicy.shouldPublishField(fieldPolicies, "rollingStockCount", isSelected) then
        dto.rollingStockCount = train:getRollingStockCount()
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "length", isSelected) then dto.length = train:getLength() end
    if SyncPolicy.shouldPublishField(fieldPolicies, "line", isSelected) then dto.line = train:getLine() end
    if SyncPolicy.shouldPublishField(fieldPolicies, "destination", isSelected) then
        dto.destination = train:getDestination()
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "direction", isSelected) then
        dto.direction = train:getDirection()
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "trackType", isSelected) then
        dto.trackType = train:getTrackType()
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "movesForward", isSelected) then
        dto.movesForward = train:getMovesForward()
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "speed", isSelected) then
        dto.speed = train:getSpeed()
    elseif SyncPolicy.shouldPublishPlaceholder(fieldPolicies, "speed", isSelected) then
        dto.speed = 0
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "targetSpeed", isSelected) then
        dto.targetSpeed = train:getTargetSpeed()
    elseif SyncPolicy.shouldPublishPlaceholder(fieldPolicies, "targetSpeed", isSelected) then
        dto.targetSpeed = 0
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "couplingFront", isSelected) then
        dto.couplingFront = train:getCouplingFront()
    elseif SyncPolicy.shouldPublishPlaceholder(fieldPolicies, "couplingFront", isSelected) then
        dto.couplingFront = 0
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "couplingRear", isSelected) then
        dto.couplingRear = train:getCouplingRear()
    elseif SyncPolicy.shouldPublishPlaceholder(fieldPolicies, "couplingRear", isSelected) then
        dto.couplingRear = 0
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "active", isSelected) then
        dto.active = train:getActive()
    elseif SyncPolicy.shouldPublishPlaceholder(fieldPolicies, "active", isSelected) then
        dto.active = false
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "inTrainyard", isSelected) then
        dto.inTrainyard = train:getInTrainyard()
    elseif SyncPolicy.shouldPublishPlaceholder(fieldPolicies, "inTrainyard", isSelected) then
        dto.inTrainyard = false
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "trainyardId", isSelected) then
        dto.trainyardId = train:getTrainyardId()
    elseif SyncPolicy.shouldPublishPlaceholder(fieldPolicies, "trainyardId", isSelected) then
        dto.trainyardId = ""
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

local function toPatchDto(train, dirtyFields, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("trains")
    local dto = {
        ceType = CE_TYPE,
        id = train:getName(),
    }
    for field in pairs(dirtyFields) do
        local getter = fieldGetters[field]
        if getter and SyncPolicy.shouldPublishField(fieldPolicies, field, isSelected) then
            dto[field] = getter(train)
        elseif getter and placeHolders[field] ~= nil and SyncPolicy.shouldPublishPlaceholder(fieldPolicies, field,
                                                                                             isSelected) then
            dto[field] = placeHolders[field]
        end
    end
    return dto
end

function TrainDtoFactory.createFullDto(train, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = toFullDto(train, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TrainDtoFactory.createPatchDto(train, dirtyFields, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = toPatchDto(train, dirtyFields, isSelected)
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
