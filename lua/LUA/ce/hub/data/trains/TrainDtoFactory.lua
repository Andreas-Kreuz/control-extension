 -- TypeScript LuaDto: apps/web-server/src/server/ce/dto/trains/TrainLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

---@class TrainDtoFactory
---@field createFullDto fun(train: Train, isSubscribed: boolean|nil):string,string,string,TrainDto
---@field createPatchDto fun(train: Train, dirtyFields: table<string,boolean>, isSubscribed: boolean|nil):string,
---string,string,TrainDto
---@field createRemovalDto fun(trainId: string):string,string,string,table
local TrainDtoFactory = {}

local CE_TYPE = HubCeTypes.Train
local KEY_ID = "id"

-- DtoFields: class definition in TrainDtoTypes.d.lua
local dtoFields = {
    name = {
        getValue = function (train) return train:getName() end,
        placeholder = ""
    },
    route = {
        getValue = function (train) return train:getRoute() end,
        placeholder = ""
    },
    rollingStockCount = {
        getValue = function (train) return train:getRollingStockCount() end,
        placeholder = 0
    },
    length = {
        getValue = function (train) return train:getLength() end,
        placeholder = 0
    },
    trackType = {
        getValue = function (train) return train:getTrackType() end,
        placeholder = ""
    },
    movesForward = {
        getValue = function (train) return train:getMovesForward() end,
        placeholder = false
    },
    speed = {
        getValue = function (train) return train:getSpeed() end,
        placeholder = 0
    },
    targetSpeed = {
        getValue = function (train) return train:getTargetSpeed() end,
        placeholder = 0
    },
    couplingFront = {
        getValue = function (train) return train:getCouplingFront() end,
        placeholder = 0
    },
    couplingRear = {
        getValue = function (train) return train:getCouplingRear() end,
        placeholder = 0
    },
    lights = {
        getValue = function (train) return train:getLights() end,
        placeholder = { ["0"] = false, ["1"] = false, ["2"] = false, ["3"] = false }
    },
    active = {
        getValue = function (train) return train:getActive() end,
        placeholder = false
    },
    inTrainyard = {
        getValue = function (train) return train:getInTrainyard() end,
        placeholder = false
    },
    trainyardId = {
        getValue = function (train) return train:getTrainyardId() end,
        placeholder = ""
    },
}

local function baseDto(train)
    return {
        ceType = CE_TYPE,
        id = train:getName()
    }
end

local function buildFullDto(train, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("trains")
    return DtoBuilder.buildFullDto(baseDto(train), train, dtoFields, fieldPolicies, isSelected)
end

local function buildPatchDto(train, dirtyFields, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("trains")
    return DtoBuilder.buildPatchDto(baseDto(train), train, dirtyFields, dtoFields, fieldPolicies, isSelected)
end

function TrainDtoFactory.createFullDto(train, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = buildFullDto(train, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TrainDtoFactory.createPatchDto(train, dirtyFields, isSelected)
    if isSelected == nil then isSelected = true end
    local dto = buildPatchDto(train, dirtyFields, isSelected)
    return CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function TrainDtoFactory.createRemovalDto(trainId)
    local dto = { ceType = CE_TYPE, id = trainId }
    return CE_TYPE, KEY_ID, trainId, dto
end

return TrainDtoFactory
