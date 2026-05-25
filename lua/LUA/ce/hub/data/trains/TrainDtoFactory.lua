-- TypeScript LuaDto: apps/web-server/src/server/ce/dto/trains/TrainLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.trains.TrainDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local cached = DtoFieldAccess.cached
local peek = DtoFieldAccess.peek
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
        getValue = peek(function (source) return source:peekName() end, "name"),
        placeholder = ""
    },
    route = {
        getValue = peek(function (source) return source:peekRoute() end, "route"),
        placeholder = ""
    },
    rollingStockCount = {
        getValue = peek(function (source) return source:peekRollingStockCount() end, "rollingStockCount"),
        placeholder = 0
    },
    length = {
        getValue = peek(function (source) return source:peekLength() end, "length"),
        placeholder = 0
    },
    trackType = {
        getValue = peek(function (source) return source:peekTrackType() end, "trackType"),
        placeholder = ""
    },
    movesForward = {
        getValue = peek(function (source) return source:peekMovesForward() end, "movesForward"),
        placeholder = false
    },
    speed = {
        getValue = peek(function (source) return source:peekSpeed() end, "speed"),
        placeholder = 0
    },
    targetSpeed = {
        getValue = peek(function (source) return source:peekTargetSpeed() end, "targetSpeed"),
        placeholder = 0
    },
    couplingFront = {
        getValue = peek(function (source) return source:peekCouplingFront() end, "couplingFront"),
        placeholder = 0
    },
    couplingRear = {
        getValue = peek(function (source) return source:peekCouplingRear() end, "couplingRear"),
        placeholder = 0
    },
    lights = {
        getValue = peek(function (source) return source:peekLights() end, "lights"),
        placeholder = { ["0"] = false, ["1"] = false, ["2"] = false, ["3"] = false }
    },
    active = {
        getValue = peek(function (source) return source:peekActive() end, "active"),
        placeholder = false
    },
    inTrainyard = {
        getValue = peek(function (source) return source:peekInTrainyard() end, "inTrainyard"),
        placeholder = false
    },
    trainyardId = {
        getValue = peek(function (source) return source:peekTrainyardId() end, "trainyardId"),
        placeholder = ""
    },
}

local function baseDto(train)
    return {
        ceType = CE_TYPE,
        id = cached(train, function (source) return source:peekName() end, "name")
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
