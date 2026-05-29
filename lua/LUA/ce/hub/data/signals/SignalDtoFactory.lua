-- TypeScript LuaDtos: apps/web-server/src/server/ce/dto/signals/SignalLuaDto.ts, WaitingOnSignalLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalDtoFactory ...") end

local DtoBuilder = require("ce.hub.data.DtoBuilder")
local DtoFieldAccess = require("ce.hub.data.DtoFieldAccess")
local peek = DtoFieldAccess.peek
local HubCeTypes = require("ce.hub.data.HubCeTypes")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

---@class SignalDtoFactory
---@field createSignalDto fun(signal: table, isSelected: boolean|nil):string,string,string|number,SignalDto
---@field createWaitingOnSignalDto fun(waitingOnSignal: table, isSelected: boolean|nil):string,string,
---string|number,WaitingOnSignalDto
---@field createWaitingOnSignalPatchDto fun(waitingOnSignal: table, dirtyFields: table<string, boolean>,
---isSelected: boolean|nil):string,string,
---string|number,WaitingOnSignalDto
---@field createWaitingOnSignalRemovalDto fun(waitingOnSignalId: string):string,string,string,table
---@field createSignalDtoList fun(signals: table, isSelectedByValue: function|nil):string,string,table
---@field createWaitingOnSignalDtoList fun(waitingOnSignals: table,
---    isSelectedByValue?: fun(value: table):boolean):string,string,table
local SignalDtoFactory = {}

local SIGNAL_CE_TYPE = HubCeTypes.Signal
local WAITING_CE_TYPE = HubCeTypes.WaitingOnSignal
local KEY_ID = "id"

-- DtoFields: class definition in SignalDtoTypes.d.lua
local signalDtoFields = {
    position = {
        getValue = peek(function (source) return source:peekPosition() end, "position"),
        placeholder = 0
    },
    waitingVehiclesCount = {
        getValue = peek(function (source) return source:peekWaitingVehiclesCount() end, "waitingVehiclesCount"),
        placeholder = 0
    },
    tag = {
        getValue = peek(function (source) return source:peekTag() end, "tag"),
        placeholder = ""
    },
    stopDistance = {
        getValue = peek(function (source) return source:peekStopDistance() end, "stopDistance"),
        placeholder = 0
    },
    itemName = {
        getValue = peek(function (source) return source:peekItemName() end, "itemName"),
        placeholder = ""
    },
    itemNameWithModelPath = {
        policyField = "itemName",
        getValue = peek(function (source) return source:peekItemNameWithModelPath() end, "itemNameWithModelPath"),
        placeholder = ""
    },
    signalFunctions = {
        policyField = "functions",
        getValue = peek(function (source) return source:peekSignalFunctions() end, "signalFunctions"),
        placeholder = {}
    },
    activeFunction = {
        policyField = "functions",
        getValue = peek(function (source) return source:peekActiveFunction() end, "activeFunction"),
        placeholder = ""
    },
}

-- DtoFields: class definition in SignalDtoTypes.d.lua
local waitingOnSignalDtoFields = {
    signalId = {
        getValue = peek(function (source) return source:peekSignalId() end, "signalId"),
        placeholder = 0
    },
    waitingPosition = {
        getValue = peek(function (source) return source:peekWaitingPosition() end, "waitingPosition"),
        placeholder = 0
    },
    vehicleName = {
        getValue = peek(function (source) return source:peekVehicleName() end, "vehicleName"),
        placeholder = ""
    },
    waitingCount = {
        getValue = peek(function (source) return source:peekWaitingCount() end, "waitingCount"),
        placeholder = 0
    },
}

local function createPatchDtoFields(dtoFields)
    local patchDtoFields = {}
    for fieldName, dtoField in pairs(dtoFields or {}) do
        patchDtoFields[fieldName] = {
            policyField = dtoField.policyField,
            getValue = dtoField.getValue
        }
    end
    return patchDtoFields
end

local waitingOnSignalPatchDtoFields = createPatchDtoFields(waitingOnSignalDtoFields)

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

local function buildWaitingOnSignalDto(waiting, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("waitingOnSignals")
    return DtoBuilder.buildFullDto({
                                       ceType = WAITING_CE_TYPE,
                                       id = waiting.id
                                   }, waiting, waitingOnSignalDtoFields, fieldPolicies, isSelected)
end

local function buildWaitingOnSignalPatchDto(waiting, dirtyFields, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("waitingOnSignals")
    return DtoBuilder.buildPatchDto({
                                        ceType = WAITING_CE_TYPE,
                                        id = waiting.id
                                    }, waiting, dirtyFields, waitingOnSignalPatchDtoFields, fieldPolicies, isSelected)
end

function SignalDtoFactory.createWaitingOnSignalDto(waiting, isSelected)
    local dto = buildWaitingOnSignalDto(waiting, isSelected == true)
    return WAITING_CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function SignalDtoFactory.createWaitingOnSignalPatchDto(waiting, dirtyFields, isSelected)
    local dto = buildWaitingOnSignalPatchDto(waiting, dirtyFields, isSelected == true)
    return WAITING_CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function SignalDtoFactory.createWaitingOnSignalRemovalDto(waitingOnSignalId)
    return WAITING_CE_TYPE, KEY_ID, waitingOnSignalId, { ceType = WAITING_CE_TYPE, id = waitingOnSignalId }
end

function SignalDtoFactory.createSignalDtoList(signals, isSelectedByValue)
    local signalDtos = {}
    for _, signal in pairs(signals or {}) do
        local _, _, _, dto = SignalDtoFactory.createSignalDto(signal,
                                                             isSelectedByValue and isSelectedByValue(signal) or false)
        signalDtos[#signalDtos + 1] = dto
    end
    return SIGNAL_CE_TYPE, KEY_ID, signalDtos
end

function SignalDtoFactory.createWaitingOnSignalDtoList(waitingOnSignals, isSelectedByValue)
    local waitingOnSignalDtos = {}
    for _, waitingOnSignal in pairs(waitingOnSignals or {}) do
        local _, _, _, dto = SignalDtoFactory.createWaitingOnSignalDto(
            waitingOnSignal, isSelectedByValue and isSelectedByValue(waitingOnSignal) or false)
        waitingOnSignalDtos[#waitingOnSignalDtos + 1] = dto
    end
    return WAITING_CE_TYPE, KEY_ID, waitingOnSignalDtos
end

return SignalDtoFactory
