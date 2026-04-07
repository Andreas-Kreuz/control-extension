-- TypeScript LuaDtos: apps/web-server/src/server/ce/dto/signals/SignalLuaDto.ts, WaitingOnSignalLuaDto.ts
if CeDebugLoad then print("[#Start] Loading ce.hub.data.signals.SignalDtoFactory ...") end

local HubCeTypes = require("ce.hub.data.HubCeTypes")
local SignalDtoFactory = {}

local SIGNAL_CE_TYPE = HubCeTypes.Signal
local WAITING_CE_TYPE = HubCeTypes.WaitingOnSignal
local KEY_ID = "id"
local SyncPolicy = require("ce.hub.sync.SyncPolicy")
local HubOptionsRegistry = require("ce.hub.options.HubOptionsRegistry")

local function toSignalDto(signal, isSelected)
    local fieldPolicies = HubOptionsRegistry.getFieldPublishPolicies("signals")
    local dto = {
        ceType = SIGNAL_CE_TYPE,
        id = signal.id,
        position = signal.position,
        waitingVehiclesCount = signal.waitingVehiclesCount,
    }
    if SyncPolicy.shouldPublishField(fieldPolicies, "tag", isSelected) then dto.tag = signal:getTag() end
    if SyncPolicy.shouldPublishField(fieldPolicies, "stopDistance", isSelected) then
        dto.stopDistance = signal:getStopDistance()
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "itemName", isSelected) then
        dto.itemName = signal:getItemName()
        dto.itemNameWithModelPath = signal:getItemNameWithModelPath()
    end
    if SyncPolicy.shouldPublishField(fieldPolicies, "functions", isSelected) then
        dto.signalFunctions = signal:getSignalFunctions()
        dto.activeFunction = signal:getActiveFunction()
    end
    return dto
end

function SignalDtoFactory.createSignalDto(signal, isSelected)
    local dto = toSignalDto(signal, isSelected == true)
    return SIGNAL_CE_TYPE, KEY_ID, dto[KEY_ID], dto
end

function SignalDtoFactory.createSignalDtoList(signals)
    local signalDtos = {}
    for i = 1, #signals do
        local _, _, _, dto = SignalDtoFactory.createSignalDto(signals[i])
        signalDtos[i] = dto
    end
    return SIGNAL_CE_TYPE, KEY_ID, signalDtos
end

local function toWaitingOnSignalDto(waiting)
    return {
        ceType = WAITING_CE_TYPE,
        id = waiting.id,
        signalId = waiting.signalId,
        waitingPosition = waiting.waitingPosition,
        vehicleName = waiting.vehicleName,
        waitingCount = waiting.waitingCount
    }
end

function SignalDtoFactory.createWaitingOnSignalDto(waiting)
    local dto = toWaitingOnSignalDto(waiting)
    return WAITING_CE_TYPE, KEY_ID, dto[KEY_ID], dto
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
