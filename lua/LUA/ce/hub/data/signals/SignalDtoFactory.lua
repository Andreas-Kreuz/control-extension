-- TypeScript LuaDtos: apps/web-server/src/server/ce/dto/signals/SignalLuaDto.ts, WaitingOnSignalLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

---@class SignalDtoFactory
---@field createSignalDto fun(signal: table, isSelected: boolean|nil):string,string,string|number,SignalDto
---@field createWaitingOnSignalDto fun(waitingOnSignal: table):string,string,string|number,WaitingOnSignalDto
---@field createWaitingOnSignalPatchDto fun(waitingOnSignal: table, dirtyFields: table<string, boolean>):string,string,
---string|number,WaitingOnSignalDto
---@field createWaitingOnSignalRemovalDto fun(waitingOnSignalId: string):string,string,string,table
---@field createWaitingOnSignalDtoList fun(waitingOnSignals: table):string,string,table
local SignalDtoFactory = {}

local SIGNAL_CE_TYPE = HubCeTypes.Signal
local WAITING_CE_TYPE = HubCeTypes.WaitingOnSignal
local KEY_ID = "id"

-- DtoFields: class definition in SignalDtoTypes.d.lua
local signalDtoFields = {
    position = {
        getValue = function (signal) return signal.position end,
        placeholder = 0
    },
    waitingVehiclesCount = {
        getValue = function (signal) return signal.waitingVehiclesCount end,
        placeholder = 0
    },
    tag = {
        getValue = function (signal) return signal:getTag() end,
        placeholder = ""
    },
    stopDistance = {
        getValue = function (signal) return signal:getStopDistance() end,
        placeholder = 0
    },
    itemName = {
        getValue = function (signal) return signal:getItemName() end,
        placeholder = ""
    },
    itemNameWithModelPath = {
        policyField = "itemName",
        getValue = function (signal) return signal:getItemNameWithModelPath() end,
        placeholder = ""
    },
    signalFunctions = {
        policyField = "functions",
        getValue = function (signal) return signal:getSignalFunctions() end,
        placeholder = {}
    },
    activeFunction = {
        policyField = "functions",
        getValue = function (signal) return signal:getActiveFunction() end,
        placeholder = ""
    },
}

-- DtoFields: class definition in SignalDtoTypes.d.lua
local waitingOnSignalDtoFields = {
    signalId = {
        getValue = function (waiting) return waiting.signalId end,
        placeholder = 0
    },
    waitingPosition = {
        getValue = function (waiting) return waiting.waitingPosition end,
        placeholder = 0
    },
    vehicleName = {
        getValue = function (waiting) return waiting.vehicleName end,
        placeholder = ""
    },
    waitingCount = {
        getValue = function (waiting) return waiting.waitingCount end,
        placeholder = 0
    },
}

local function buildSignalDto(signal, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("signals")
    return DtoBuilder.buildFullDto({
                                       ceType = SIGNAL_CE_TYPE,
                                       id = signal.id
                                   }, signal, signalDtoFields, fieldPolicies, isSelected)
end

function SignalDtoFactory.createSignalDto(signal, isSelected)
    local dto = buildSignalDto(signal, isSelected == true)
    return SIGNAL_CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

local function buildWaitingOnSignalDto(waiting)
    return DtoBuilder.buildFullDto({
                                       ceType = WAITING_CE_TYPE,
                                       id = waiting.id
                                   }, waiting, waitingOnSignalDtoFields)
end

local function buildWaitingOnSignalPatchDto(waiting, dirtyFields)
    return DtoBuilder.buildPatchDto({
                                        ceType = WAITING_CE_TYPE,
                                        id = waiting.id
                                    }, waiting, dirtyFields, waitingOnSignalDtoFields)
end

function SignalDtoFactory.createWaitingOnSignalDto(waiting)
    local dto = buildWaitingOnSignalDto(waiting)
    return WAITING_CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function SignalDtoFactory.createWaitingOnSignalPatchDto(waiting, dirtyFields)
    local dto = buildWaitingOnSignalPatchDto(waiting, dirtyFields)
    return WAITING_CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function SignalDtoFactory.createWaitingOnSignalRemovalDto(waitingOnSignalId)
    return WAITING_CE_TYPE, KEY_ID, waitingOnSignalId, { ceType = WAITING_CE_TYPE, id = waitingOnSignalId }
end

function SignalDtoFactory.createWaitingOnSignalDtoList(waitingOnSignals)
    local waitingOnSignalDtos = {}
    for i = 1, #waitingOnSignals do
        local _, _, _, dto = SignalDtoFactory.createWaitingOnSignalDto(waitingOnSignals[i])
        waitingOnSignalDtos[i] = dto
    end
    return WAITING_CE_TYPE, KEY_ID, waitingOnSignalDtos
end

return SignalDtoFactory
