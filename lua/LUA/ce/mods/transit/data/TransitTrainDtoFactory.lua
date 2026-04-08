if CeDebugLoad then print("[#Start] Loading ce.mods.transit.data.TransitTrainDtoFactory ...") end

local TransitCeTypes = require("ce.mods.transit.data.TransitCeTypes")

local TransitTrainDtoFactory = {}

local CE_TYPE = TransitCeTypes.TransitTrain
local KEY_ID = "id"

local fieldGetters = {
    line = function (t) return t:getLine() end,
    destination = function (t) return t:getDestination() end,
    direction = function (t) return t:getDirection() end,
}

function TransitTrainDtoFactory.createFullDto(transitTrain)
    local dto = {
        ceType = CE_TYPE,
        id = transitTrain.id,
        line = transitTrain:getLine(),
        destination = transitTrain:getDestination(),
        direction = transitTrain:getDirection(),
    }
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TransitTrainDtoFactory.createPatchDto(transitTrain, dirtyFields)
    local dto = {
        ceType = CE_TYPE,
        id = transitTrain.id,
    }
    for field in pairs(dirtyFields) do
        local getter = fieldGetters[field]
        if getter then dto[field] = getter(transitTrain) end
    end
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TransitTrainDtoFactory.createRefDto(trainId)
    local dto = { ceType = CE_TYPE, id = trainId }
    return CE_TYPE, KEY_ID, trainId, dto
end

return TransitTrainDtoFactory
