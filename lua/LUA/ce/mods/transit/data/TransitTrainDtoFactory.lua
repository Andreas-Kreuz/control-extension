if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitTrainDtoFactory ...") end

local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")
local TransitOptionsRegistry = require("ce.mods.transit.options.TransitOptionsRegistry")

local TransitTrainDtoFactory = {}

local CE_TYPE = TransitCeTypes.TransitTrain
local KEY_ID = "id"

local fieldGetters = {
    line = function (t) return t:getLine() end,
    destination = function (t) return t:getDestination() end,
    direction = function (t) return t:getDirection() end,
}

local fieldPlaceholders = {
    line = "",
    destination = "",
    direction = "",
}

function TransitTrainDtoFactory.createFullDto(transitTrain, isSelected)
    local fieldPolicies = TransitOptionsRegistry.getFieldPublishPolicies("transitTrains")
    local dto = {
        ceType = CE_TYPE,
        id = transitTrain.id,
    }
    for field, getter in pairs(fieldGetters) do
        if SyncPolicy.shouldPublishField(fieldPolicies, field, isSelected == true) then
            dto[field] = getter(transitTrain) or fieldPlaceholders[field]
        else
            dto[field] = fieldPlaceholders[field]
        end
    end
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TransitTrainDtoFactory.createPatchDto(transitTrain, dirtyFields, isSelected)
    local fieldPolicies = TransitOptionsRegistry.getFieldPublishPolicies("transitTrains")
    local dto = {
        ceType = CE_TYPE,
        id = transitTrain.id,
    }
    for field in pairs(dirtyFields) do
        local getter = fieldGetters[field]
        if getter and SyncPolicy.shouldPublishField(fieldPolicies, field, isSelected == true) then
            dto[field] = getter(transitTrain)
        end
    end
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TransitTrainDtoFactory.createRefDto(trainId)
    local dto = { ceType = CE_TYPE, id = trainId }
    return CE_TYPE, KEY_ID, trainId, dto
end

return TransitTrainDtoFactory
